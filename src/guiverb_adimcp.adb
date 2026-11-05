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
   --  The checks poll within the harness deadline the GTK backend's
   --  polls use.

   Launch_Deadline_S  : constant := 15.0;
   Command_Deadline_S : constant := 15.0;
   Check_Deadline     : constant Duration := 6.0;
   Poll_Interval      : constant Duration := 0.2;

   use type Ada.Calendar.Time;

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
   begin
      Request_Counter := Request_Counter + 1;

      if Ada.Directories.Exists (Resp_File) then
         Ada.Directories.Delete_File (Resp_File);
      end if;

      Create (F, Out_File, Cmd_File);
      Put (F, "{" & """" & "command" & """" & ":"
             & """" & Command & """");
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

   --  -----------------------------------------------------------------------
   --  Command shorthands
   --  -----------------------------------------------------------------------

   function Find_By_Text (Query : String; Exact : Boolean := False)
                          return String is
   begin
      return Run_Command ("find_by_text",
        """query"":""" & Query & """,""exact"":"
        & (if Exact then "true" else "false"));
   end Find_By_Text;

   function Find_By_Type (Type_Name : String) return String is
   begin
      return Run_Command ("find_by_type",
        """type_name"":""" & Type_Name & """");
   end Find_By_Type;

   function Widget_Info (Path : String) return String is
   begin
      return Run_Command ("widget_info", """path"":""" & Path & """");
   end Widget_Info;

   function Widget_Tree return String is
   begin
      return Run_Command ("widget_tree", "");
   end Widget_Tree;

   --  -----------------------------------------------------------------------
   --  Textual JSON reading (the pinned bridge serialization)
   --  -----------------------------------------------------------------------

   --  All reads rest on the bridge's compact encoding and pinned
   --  member order — the same ground the F005 root read rests on.
   --  The reference texts carry no escapes, braces or quotes inside
   --  string values; a full reader waits on Q017.

   --  First occurrence of Pattern at or after index From (an index
   --  into Source); 0 when absent. Index on a slice answers in the
   --  slice's own indexing — absolute, no offset to add — and the
   --  region searched starts at the slice's own first index: the
   --  objects parsed here are slices of the response, rarely
   --  1-based.

   function After_From
     (Source, Pattern : String; From : Positive) return Natural is
      Low : constant Positive :=
        Positive'Max (From, Source'First);
   begin
      if Low > Source'Last then
         return 0;
      end if;
      return Ada.Strings.Fixed.Index
               (Source (Low .. Source'Last), Pattern);
   end After_From;

   --  The string value of a string member Key: "" when absent. The
   --  members read here carry no escaped quote (the tag names and
   --  the reference texts). Exactness of names never rests on this
   --  reader where the bridge can answer it: find_by_text exact
   --  does the comparison (see Window_Contains and Button_Info).

   function Member_Value (Object, Key : String) return String is
      Key_Pattern : constant String := '"' & Key & '"' & ":" & '"';
      K : constant Natural := After_From (Object, Key_Pattern, 1);
   begin
      if K = 0 then
         return "";
      end if;
      declare
         From : constant Natural := K + Key_Pattern'Length;
         Q    : Natural := From;
      begin
         while Q <= Object'Last loop
            exit when Object (Q) = '"'
              and then (Q = From or else Object (Q - 1) /= '\');
            Q := Q + 1;
         end loop;
         return Object (From .. Q - 1);
      end;
   end Member_Value;

   --  The numeric value of member Key; 0 when absent or non-numeric.

   function Member_Number (Object, Key : String) return Natural is
      Key_Pattern : constant String := '"' & Key & '"' & ":";
      K : constant Natural := After_From (Object, Key_Pattern, 1);
   begin
      if K = 0 then
         return 0;
      end if;
      declare
         From : constant Natural := K + Key_Pattern'Length;
         Q    : Natural := From;
      begin
         while Q <= Object'Last and then Object (Q) in '0' .. '9' loop
            Q := Q + 1;
         end loop;
         if Q = From then
            return 0;
         end if;
         return Natural'Value (Object (From .. Q - 1));
      exception
         when Constraint_Error =>
            return 0;
      end;
   end Member_Number;

   --  How a boolean member Key reads: 0 = member absent (unknown),
   --  1 = false, 2 = true.

   function Member_Boolean (Object, Key : String) return Natural is
      Key_Pattern : constant String := '"' & Key & '"' & ":";
      K : constant Natural := After_From (Object, Key_Pattern, 1);
   begin
      if K = 0 then
         return 0;
      end if;
      declare
         Pos : constant Natural := K + Key_Pattern'Length;
      begin
         if Pos <= Object'Last and then Object (Pos) = 't' then
            return 2;
         end if;
         return 1;
      end;
   end Member_Boolean;

   --  Whether the array member Array_Key of a find answer holds at
   --  least one object (an empty look-up serializes "matches":[]).

   Matches_Open : constant String := """matches"":[";

   function Has_Matches (Response : String) return Boolean is
      Open : constant Natural :=
        Ada.Strings.Fixed.Index (Response, Matches_Open);
   begin
      return Open /= 0
        and then Open + Matches_Open'Length <= Response'Last
        and then Response (Open + Matches_Open'Length) /= ']';
   end Has_Matches;

   --  Match objects of a find answer: flat (id, path, type, text),
   --  so the scan splits on the object braces textually. The id is
   --  what actions address, the path what widget_info resolves.

   type Bridge_Match is record
      Present   : Boolean := False;
      Id        : Natural := 0;
      Path      : Unbounded_String;
      Type_Name : Unbounded_String;
      Text      : Unbounded_String;
   end record;

   Null_Match : constant Bridge_Match :=
     (Present   => False,
      Id        => 0,
      Path      => Null_Unbounded_String,
      Type_Name => Null_Unbounded_String,
      Text      => Null_Unbounded_String);

   function Parse_Match (Object : String) return Bridge_Match is
   begin
      return (Present   => True,
              Id        => Member_Number (Object, "id"),
              Path      => To_Unbounded_String
                             (Member_Value (Object, "path")),
              Type_Name => To_Unbounded_String
                             (Member_Value (Object, "type")),
              Text      => To_Unbounded_String
                             (Member_Value (Object, "text")));
   end Parse_Match;

   type Match_Test is access function (M : Bridge_Match) return Boolean;

   --  Whether the "type" member of an object carries Sub.

   function Type_Contains (Object, Sub : String) return Boolean is
   begin
      return Ada.Strings.Fixed.Index (Member_Value (Object, "type"), Sub) /= 0;
   end Type_Contains;

   --  The first match of a find answer satisfying Test, visiting the
   --  matches array in serialization order; Null_Match when none —
   --  which the polling checks treat as "not yet", not as an error.

   function Find_Match
     (Response : String; Test : not null Match_Test) return Bridge_Match
   is
      Open      : constant Natural :=
        Ada.Strings.Fixed.Index (Response, Matches_Open);
      From      : Positive;
      Obj_Start : Natural;
      Obj_End   : Natural;
   begin
      if Open = 0 or else not Has_Matches (Response) then
         return Null_Match;
      end if;

      From := Open + Matches_Open'Length;
      Obj_Start := From;
      loop
         Obj_End := After_From (Response, "}", Obj_Start);
         exit when Obj_End = 0;
         declare
            M : constant Bridge_Match :=
              Parse_Match (Response (Obj_Start .. Obj_End));
         begin
            if Test (M) then
               return M;
            end if;
         end;
         Obj_Start := After_From (Response, "{", Obj_End + 1);
         exit when Obj_Start = 0;
      end loop;
      return Null_Match;
   end Find_Match;

   --  Whether some "text" member of a serialized subtree carries
   --  Expected exactly.

   function Carries_Text (Slice, Expected : String) return Boolean is
      Key_Pattern : constant String := """text"":""";
      From        : Natural := Slice'First;
   begin
      loop
         declare
            Hit : constant Natural := After_From (Slice, Key_Pattern, From);
         begin
            exit when Hit = 0;
            declare
               First : constant Positive := Hit + Key_Pattern'Length;
               Q     : Natural := First;
            begin
               while Q <= Slice'Last and then Slice (Q) /= '"' loop
                  Q := Q + 1;
               end loop;
               if Slice (First .. Q - 1) = Expected then
                  return True;
               end if;
               From := Q + 1;
            end;
         end;
      end loop;
      return False;
   end Carries_Text;

   --  The first overlay root object of a widget_tree answer whose
   --  type carries Sub and whose serialized subtree carries the text
   --  Text_Is_Expected ("" = any). The overlays array holds nested
   --  objects: a quote-aware scan separates the roots from their
   --  subtrees. A dialog answers its check through the inner label
   --  its title is rendered by (the dialog node's own text member is
   --  absent), and any text of the subtree counts: the candidate
   --  names come from the projection the scenario runs against.

   function Dialog_Overlay_Carries
     (Response, Sub, Text_Is_Expected : String) return Boolean
   is
      Key_Pattern : constant String := """overlays"":[";
      Open        : constant Natural :=
        Ada.Strings.Fixed.Index (Response, Key_Pattern);
   begin
      if Open = 0 then
         return False;
      end if;

      Scan :
      declare
         I         : Natural := Open + Key_Pattern'Length;
         Depth     : Natural := 0;
         In_String : Boolean := False;
         Escaped   : Boolean := False;
         Obj_First : Natural := 0;
      begin
         while I <= Response'Last loop
            if In_String then
               if Escaped then
                  Escaped := False;
               elsif Response (I) = '\' then
                  Escaped := True;
               elsif Response (I) = '"' then
                  In_String := False;
               end if;
            else
               case Response (I) is
                  when '"' =>
                     In_String := True;
                     Escaped   := False;
                  when '{' =>
                     Depth := Depth + 1;
                     if Depth = 1 then
                        Obj_First := I;
                     end if;
                  when '}' =>
                     if Depth = 0 then
                        --  A closer '}' before the array closes (the
                        --  only writer this reads cannot produce
                        --  one): malformed answer, stop.
                        return False;
                     end if;
                     Depth := Depth - 1;
                     if Depth = 0 then
                        declare
                           Slice : constant String :=
                             Response (Obj_First .. I);
                        begin
                           if Type_Contains (Slice, Sub)
                             and then (Text_Is_Expected = ""
                                       or else Carries_Text
                                                 (Slice, Text_Is_Expected))
                           then
                              return True;
                           end if;
                        end;
                     end if;
                  when ']' =>
                     if Depth = 0 then
                        return False;  --  the array closed
                     end if;
                  when others =>
                     null;
               end case;
            end if;
            I := I + 1;
         end loop;
         return False;
      end Scan;
   end Dialog_Overlay_Carries;

   --  -----------------------------------------------------------------------
   --  Public checks
   --  -----------------------------------------------------------------------

   function Window_Appears (Expected_Title : String := "") return Boolean is
      Response : Unbounded_String;
   begin
      if Session_Dir = Null_Unbounded_String then
         return False;
      end if;

      Response := To_Unbounded_String (Widget_Tree);

      --  Minimal read of the reply (the bridge's JSON writer, and its
      --  field ordering, are pinned by the audited commit). The root
      --  node's own members end at its "children" key: the check
      --  reads only the root slice, where its visibility and its
      --  text (the projection's title declaration — see the mapping
      --  conventions in the spec) live. A visible root answers "a
      --  window appears"; the named form also requires the root's
      --  text to be the expected title. Anything else — no tree, no
      --  answer, dead session — is not.

      declare
         Text       : constant String := To_String (Response);
         Tree_Key   : constant String := """tree"":{";
         Tree_Start : constant Natural :=
           Ada.Strings.Fixed.Index (Text, Tree_Key);
      begin
         Last_Snapshot := Response;
         if Tree_Start = 0 then
            return False;
         end if;

         declare
            Children : constant Natural :=
              After_From (Text, """children""", Tree_Start);
            Root : constant String :=
              Text (Tree_Start ..
                    (if Children = 0 then Text'Last else Children - 1));
         begin
            if Ada.Strings.Fixed.Index (Root, """visible"":true") = 0 then
               return False;
            end if;
            return Expected_Title = ""
              or else Ada.Strings.Fixed.Index
                        (Root,
                         """text"":""" & Expected_Title & """") /= 0;
         end;
      end;
   end Window_Appears;

   function Window_Contains (Expected : String) return Boolean is
      Deadline : constant Ada.Calendar.Time :=
        Ada.Calendar.Clock + Check_Deadline;
   begin
      Last_Snapshot := Null_Unbounded_String;
      while Ada.Calendar.Clock < Deadline loop
         declare
            --  Non-exact search: the bridge's case-insensitive
            --  substring look-up over the root tree and the overlays.
            Response : constant String := Find_By_Text (Expected);
         begin
            Last_Snapshot := To_Unbounded_String (Response);
            if Has_Matches (Response) then
               return True;
            end if;
         end;
         delay Poll_Interval;
      end loop;
      return False;
   end Window_Contains;

   function Button_Info (Name : String) return Bridge_Match is
      Deadline : constant Ada.Calendar.Time :=
        Ada.Calendar.Clock + Check_Deadline;

      function Is_The_Button (M : Bridge_Match) return Boolean is
      begin
         return M.Present
           and then To_String (M.Text) = Name
           and then Ada.Strings.Fixed.Index
                      (To_String (M.Type_Name), "button") /= 0;
      end Is_The_Button;
   begin
      while Ada.Calendar.Clock < Deadline loop
         declare
            M : constant Bridge_Match :=
              Find_Match (Find_By_Type ("button"),
                          Is_The_Button'Unrestricted_Access);
         begin
            if M.Present then
               return M;
            end if;
         end;
         delay Poll_Interval;
      end loop;
      return Null_Match;
   end Button_Info;

   --  How the named widget's serialized state State reads (the
   --  widget_info member is "state_" & the lowered image of Adi2's
   --  State_... literals — "state_state_focused" etc.):
   --  0 = unknown (no answer, no widget), 1 = false, 2 = true.

   function Widget_State_Of
     (Match : Bridge_Match; State : String) return Natural
   is
      Response : constant String :=
        (if Match.Present then Widget_Info (To_String (Match.Path)) else "");
   begin
      if Match.Present and then Response /= "" then
         return Member_Boolean (Response, "state_state_" & State);
      end if;
      return 0;
   end Widget_State_Of;

   function Button_Named (Name : String) return Boolean is
   begin
      return Button_Info (Name).Present;
   end Button_Named;

   function Button_Enabled (Name : String) return Boolean is
   begin
      --  Not found reads False, not unknown: the button-existence
      --  step is the preceding scenario step, and the state
      --  diagnostic is the GTK chain's ("the button is disabled")
      --  either way. Unknown state reads not-enabled, never silently
      --  enabled.
      return Widget_State_Of (Button_Info (Name), "disabled") = 1;
   end Button_Enabled;

   function Press_Button (Name : String) return Boolean is
      M : constant Bridge_Match := Button_Info (Name);
   begin
      if not M.Present then
         return False;
      end if;
      declare
         Response : constant String :=
           Run_Command ("click_widget",
                        """id"":" & Ada.Strings.Fixed.Trim
                                       (M.Id'Image, Ada.Strings.Both));
      begin
         return After_From (Response, """status"":""ok""", 1) /= 0;
      end;
   end Press_Button;

   function Dialog_Appears (Expected_Name : String := "") return Boolean is
      Deadline : constant Ada.Calendar.Time :=
        Ada.Calendar.Clock + Check_Deadline;
   begin
      Last_Snapshot := Null_Unbounded_String;
      while Ada.Calendar.Clock < Deadline loop
         declare
            Response : constant String := Widget_Tree;
         begin
            Last_Snapshot := To_Unbounded_String (Response);
            exit when Response = "";
            if Dialog_Overlay_Carries (Response, "dialog", Expected_Name)
            then
               return True;
            end if;
         end;
         delay Poll_Interval;
      end loop;
      return False;
   end Dialog_Appears;

   --  The field-naming convention's lookup (see the spec): the first
   --  match whose following tree sibling resolves to a text input.
   --  The find answers carry overlay subtrees' matches with
   --  overlay-relative paths; widget_info resolves a plain relative
   --  path against the root tree first and falls back to the
   --  overlays — the recorded shadowing limitation applies (a
   --  root-tree widget with the same relative path would be read
   --  instead; the witness's root has no such deep paths).

   function Named_Field_Path (Name : String) return Bridge_Match is
      Deadline : constant Ada.Calendar.Time :=
        Ada.Calendar.Clock + Check_Deadline;
      Result   : Bridge_Match := Null_Match;
      --  The next sibling in the walk order: the name-matching
      --  label's path with its last component incremented.

      function Field_Sibling (Path : String) return String is
         Dot       : constant Natural :=
           Ada.Strings.Fixed.Index (Path, ".", Ada.Strings.Backward);
         Last_Komp : constant Natural :=
           (if Dot = 0 then Path'First else Dot + 1);
         Next_N    : constant Positive :=
           Positive'Value (Path (Last_Komp .. Path'Last)) + 1;
      begin
         return (if Dot = 0
                 then Ada.Strings.Fixed.Trim (Next_N'Image,
                                              Ada.Strings.Both)
                 else Path (Path'First .. Dot)
                      & Ada.Strings.Fixed.Trim (Next_N'Image,
                                                Ada.Strings.Both));
      exception
         when Constraint_Error =>
            return "";
      end Field_Sibling;

      function Follows_Label (M : Bridge_Match) return Boolean is
         Sib : constant String := Field_Sibling (To_String (M.Path));
      begin
         if Sib = "" then
            return False;
         end if;
         declare
            Response : constant String := Widget_Info (Sib);
         begin
            if Response /= "" and then Type_Contains (Response, "text_input")
            then
               Result := (Present   => True,
                          Id        => Member_Number (Response, "id"),
                          Path      => To_Unbounded_String (Sib),
                          Type_Name => To_Unbounded_String
                                         (Member_Value (Response, "type")),
                          Text      => Null_Unbounded_String);
               return True;
            end if;
         end;
         return False;
      end Follows_Label;
   begin
      Result := Null_Match;
      while Ada.Calendar.Clock < Deadline loop
         declare
            M : constant Bridge_Match :=
              Find_Match (Find_By_Text (Name, Exact => True),
                          Follows_Label'Unrestricted_Access);
         begin
            exit when Result.Present or else M.Present;
         end;
         delay Poll_Interval;
      end loop;
      return Result;
   end Named_Field_Path;

   function Field_Named
     (Name : String; Password : Boolean := False) return Boolean is
      pragma Unreferenced (Password);
      --  The bridge does not expose the password mode (audit; Q022):
      --  the same position as the GTK chain — both projections of an
      --  input field resolve through the same search.
   begin
      return Named_Field_Path (Name).Present;
   end Field_Named;

   function Field_Focused (Name : String) return Boolean is
   begin
      --  The serialized widget state is the ground truth: the
      --  bridge's get_focus answers disagreed with the snapshots in
      --  the audit's experiment annex.
      return Widget_State_Of (Named_Field_Path (Name), "focused") = 2;
   end Field_Focused;

   function Observed_Text return String is
   begin
      return To_String (Last_Snapshot);
   end Observed_Text;

   function Current_Tree return String is
      Response : constant String := Widget_Tree;
   begin
      Last_Snapshot := To_Unbounded_String (Response);
      return Response;
   end Current_Tree;

   procedure Shutdown is
   begin
      if Spawned_Set then
         GNAT.OS_Lib.Kill (Spawned_Id);
      end if;
      Clear;
   end Shutdown;

end Guiverb_AdiMCP;
