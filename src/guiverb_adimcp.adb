--  ---------------------------------------------------------------------------
--  GuiVerb (https://github.com/LionelDraghi/GuiVerb)
--  SPDX-License-Identifier: Apache-2.0
--  SPDX-FileCopyrightText: 2026, Lionel Draghi
--  ---------------------------------------------------------------------------

with Ada.Calendar;
with Ada.Directories;
with Ada.Environment_Variables;
with Ada.Strings.Fixed;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO;
with GNAT.OS_Lib;

package body Guiverb_AdiMCP is

   --  Bounded wait for the probe session and for each command answer:
   --  the bridge processes commands once per frame, so an alive
   --  application answers in tens of milliseconds; 15 s is a ceiling
   --  that still fails fast for the failures the diagnostics report.

   Launch_Deadline_S  : constant := 15.0;
   Command_Deadline_S : constant := 15.0;

   --  <system temp>/adi_mcp — both sides of the protocol must resolve
   --  the system temp the same way. The bridge reads TMPDIR, else
   --  TEMP, else TMP, else /tmp; this client follows the bridge.

   function Session_Base_Dir return String is
      use Ada.Environment_Variables;
   begin
      if Exists ("TMPDIR") then
         return Value ("TMPDIR");
      elsif Exists ("TEMP") then
         return Value ("TEMP");
      elsif Exists ("TMP") then
         return Value ("TMP");
      else
         return "/tmp";
      end if;
   end Session_Base_Dir;

   Session_Base : constant String := Session_Base_Dir & "/adi_mcp";

   Spawned_Pid   : Unbounded_String := Null_Unbounded_String;
   Spawned_Set   : Boolean := False;
   Spawned_Id    : GNAT.OS_Lib.Process_Id;
   Session_Dir   : Unbounded_String := Null_Unbounded_String;
   Last_Snapshot : Unbounded_String := Null_Unbounded_String;

   procedure Clear is
   begin
      Spawned_Pid := Null_Unbounded_String;
      Spawned_Set := False;
      Session_Dir := Null_Unbounded_String;
   end Clear;

   procedure Launch (Binary_Path : String) is
      use type Ada.Calendar.Time;
   begin
      if Spawned_Set then
         Shutdown;
      end if;

      if not Ada.Directories.Exists (Binary_Path) then
         raise Launch_Failed with
           "application binary not found: " & Binary_Path;
      end if;

      Spawned_Id := GNAT.OS_Lib.Non_Blocking_Spawn
        (Binary_Path, (1 .. 0 => null));
      Spawned_Set := True;
      Spawned_Pid := To_Unbounded_String
        (Ada.Strings.Fixed.Trim
           (GNAT.OS_Lib.Pid_To_Integer (Spawned_Id)'Image,
            Ada.Strings.Both));

      --  The probe session appears once the application calls
      --  Adi.MCP.Initialize, on (or just before) its first frame. A
      --  probe-less build never creates one: this deadline then names
      --  a build problem, which is what the diagnostic says.

      declare
         Deadline : constant Ada.Calendar.Time :=
           Ada.Calendar.Clock + Launch_Deadline_S;
      begin
         loop
            declare
               Dir : constant String :=
                 Session_Base & "/" & To_String (Spawned_Pid);
            begin
               if Ada.Directories.Exists (Dir & "/ready") then
                  Session_Dir := To_Unbounded_String (Dir);
                  return;
               end if;
            end;
            exit when Ada.Calendar.Clock > Deadline;
            delay 0.1;
         end loop;
      end;

      Clear;
      raise Launch_Failed with
        "no probe session appeared under " & Session_Base & "/<pid> within"
        & Integer'Image (Integer (Launch_Deadline_S))
        & " s: is " & Binary_Path
        & " a development-profile (probe-enabled) build?";
   end Launch;

   --  One command to a live session: write cmd_<id>.json, wait for
   --  resp_<id>.json. Single flight — the bridge processes commands
   --  once per frame and its client contract allows one in-flight
   --  command per session.

   Request_Counter : Natural := 0;

   function Run_Command (Command, Parameters : String) return String;
   --  Parameters: the JSON members after the command name (may be
   --  ""). Returns the response body, or "" when no answer came in
   --  time (dead session, bridge stopped answering).

   function Run_Command (Command, Parameters : String) return String is
      use Ada.Text_IO;
      Req_Id : constant String :=
        Ada.Strings.Fixed.Trim (Natural'Image (Request_Counter),
                                Ada.Strings.Both);
      Cmd_File  : constant String :=
        To_String (Session_Dir) & "/cmd_" & Req_Id & ".json";
      Resp_File : constant String :=
        To_String (Session_Dir) & "/resp_" & Req_Id & ".json";
      F         : File_Type;
      Opened    : Boolean := False;
      use type Ada.Calendar.Time;
   begin
      Request_Counter := Request_Counter + 1;

      if Ada.Directories.Exists (Resp_File) then
         Ada.Directories.Delete_File (Resp_File);
      end if;

      Create (F, Out_File, Cmd_File);
      Put (F, "{""command"":""" & Command & """");
      if Parameters'Length > 0 then
         Put (F, "," & Parameters);
      end if;
      Put (F, "}");
      Close (F);

      declare
         Deadline : constant Ada.Calendar.Time :=
           Ada.Calendar.Clock + Command_Deadline_S;
      begin
         loop
            if Ada.Directories.Exists (Resp_File) then
               declare
                  Body_Text : Unbounded_String := Null_Unbounded_String;
               begin
                  Open (F, In_File, Resp_File);
                  Opened := True;
                  while not End_Of_File (F) loop
                     Append (Body_Text, Get_Line (F));
                  end loop;
                  Close (F);
                  Opened := False;
                  return To_String (Body_Text);
               end;
            end if;
            exit when Ada.Calendar.Clock > Deadline;
            delay 0.05;
         end loop;
      end;

      return "";
   exception
      when others =>
         if Opened and then Is_Open (F) then
            Close (F);
         end if;
         return "";
   end Run_Command;

   function Window_Appears (Expected_Title : String := "") return Boolean is
      Response : Unbounded_String;
   begin
      if Expected_Title /= "" then
         raise Probe_Unsupported with
           "the Adi2 bridge exposes no window title"
           & " (its tree root is a widget, not a named window)";
      end if;

      if Session_Dir = Null_Unbounded_String then
         return False;
      end if;

      Response := To_Unbounded_String (Run_Command ("widget_tree", ""));

      --  Minimal read of the reply (the bridge's JSON writer, and its
      --  field ordering, are pinned by the audited commit). A root
      --  tree whose root is visible is F005's "a window appears".
      --  Anything else — no tree, no answer, dead session — is not.
      --  The read stays textual on purpose: no JSON parser in the
      --  runner until a protocol member needs one (Q017).

      declare
         Text       : constant String := To_String (Response);
         Tree_Start : constant Natural :=
           Ada.Strings.Fixed.Index (Text, """tree"":{");
      begin
         if Tree_Start = 0 then
            Last_Snapshot := Response;
            return False;
         end if;

         Root_Slice :
         declare
            Root_Button : constant String :=
              Text (Tree_Start .. Text'Last);
         begin
            if Ada.Strings.Fixed.Index (Root_Button, """visible"":true") = 0
            then
               Last_Snapshot := Response;
               return False;
            end if;
         end Root_Slice;

         Last_Snapshot := Response;
         return True;
      end;
   end Window_Appears;

   function Observed_Text return String is
   begin
      return To_String (Last_Snapshot);
   end Observed_Text;

   procedure Shutdown is
   begin
      if Spawned_Set then
         GNAT.OS_Lib.Kill (Spawned_Id);
      end if;
      Clear;
   end Shutdown;

end Guiverb_AdiMCP;
