--  ---------------------------------------------------------------------------
--  GuiVerb (https://github.com/LionelDraghi/GuiVerb)
--  SPDX-License-Identifier: Apache-2.0
--  SPDX-FileCopyrightText: 2026, Lionel Draghi
--  ---------------------------------------------------------------------------

with Ada.Command_Line; use Ada.Command_Line;
with Ada.Directories;
with Ada.Environment_Variables;
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Strings.Fixed;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO; use Ada.Text_IO;
with GNAT.OS_Lib; use GNAT.OS_Lib;
with Guiverb_Scenario;
with Guiverb_WebDriver;

procedure Guiverb is

   --  Resolve the application name of the run step to a file:// URL:
   --  look for an apps/<name>/index.html in the scenario directory,
   --  then in each parent directory.

   function App_URL (Scenario_File, App_Name : String) return String is
      Dir : Unbounded_String := To_Unbounded_String
        (Ada.Directories.Containing_Directory (Scenario_File));
   begin
      loop
         declare
            Candidate : constant String := To_String (Dir) & "/apps/"
              & App_Name & "/index.html";
         begin
            if Ada.Directories.Exists (Candidate) then
               return "file://"
                 & Ada.Directories.Full_Name (Candidate);
            end if;
         end;
         declare
            Parent : constant String :=
              Ada.Directories.Containing_Directory (To_String (Dir));
         begin
            exit when Parent = To_String (Dir);
            Dir := To_Unbounded_String (Parent);
         end;
      end loop;
      return "";
   end App_URL;

   Driver         : GNAT.OS_Lib.Process_Id;
   Driver_Spawned : Boolean := False;

   procedure Stop_Driver is
   begin
      if Driver_Spawned then
         GNAT.OS_Lib.Kill (Driver);
         Driver_Spawned := False;
      end if;
   end Stop_Driver;

   Step_Mode     : Boolean := False;
   Scenario_File : Unbounded_String;

   User_Abort : exception;

   --  In step-by-step mode (--step), print a message and wait for the
   --  user to press Enter before the next step runs. Immediate end of
   --  input aborts the run.

   procedure Wait_For_User (Message : String) is
      Line : String (1 .. 256);
      Last : Natural;
   begin
      if not Step_Mode then
         return;
      end if;
      Put_Line (Standard_Error, "--- " & Message);
      Put (Standard_Error, "    press Enter to continue (Ctrl-D to abort)...");
      Flush (Standard_Error);
      begin
         Ada.Text_IO.Get_Line (Line, Last);
      exception
         when End_Error =>
            Put_Line (Standard_Error, "");
            Put_Line (Standard_Error, "aborted by user");
            raise User_Abort;
      end;
      Put_Line (Standard_Error, "");
   end Wait_For_User;

begin
   --  The loader path is often polluted in development environments
   --  (e.g. IDE extension libraries) and that breaks the spawned
   --  browser; the chain needs a clean loader path.

   if Ada.Environment_Variables.Exists ("LD_LIBRARY_PATH") then
      Ada.Environment_Variables.Set ("LD_LIBRARY_PATH", "");
   end if;

   for I in 1 .. Argument_Count loop
      if Argument (I) = "--step" then
         Step_Mode := True;
      elsif Scenario_File /= Null_Unbounded_String then
         Put_Line (Standard_Error, "usage: guiverb [--step] <scenario-file>");
         Set_Exit_Status (Failure);
         return;
      else
         Scenario_File := To_Unbounded_String (Argument (I));
      end if;
   end loop;

   if Scenario_File = Null_Unbounded_String then
      Put_Line (Standard_Error, "usage: guiverb [--step] <scenario-file>");
      Set_Exit_Status (Failure);
      return;
   end if;

   declare
      File : constant String := To_String (Scenario_File);
      Info : constant Guiverb_Scenario.Parsed :=
        Guiverb_Scenario.Parse (File);
      URL  : constant String :=
        App_URL (File, To_String (Info.App_Name));
   begin
      Wait_For_User
        ("next step: When I run `" & To_String (Info.App_Name) & "`");

      if URL = "" then
         Put_Line (Standard_Error, "no application '"
                   & To_String (Info.App_Name)
                   & "' found in an apps/ directory near " & File);
         Set_Exit_Status (Failure);
         return;
      end if;

      declare
         Driver_Path : constant GNAT.OS_Lib.String_Access :=
           GNAT.OS_Lib.Locate_Exec_On_Path ("chromedriver");
      begin
         if Driver_Path = null then
            Put_Line (Standard_Error, "chromedriver not found on PATH");
            Set_Exit_Status (Failure);
            return;
         end if;
         Driver := GNAT.OS_Lib.Non_Blocking_Spawn
           (Driver_Path.all,
            (1 => new String'
               ("--port=" & Ada.Strings.Fixed.Trim
                  (Guiverb_WebDriver.Driver_Port'Image, Ada.Strings.Both))));
         Driver_Spawned := True;
      exception
         when others =>
            Put_Line (Standard_Error, "cannot start chromedriver");
            Set_Exit_Status (Failure);
            return;
      end;

      declare
         Up : Boolean := False;
      begin
         for Try in 1 .. 50 loop
            if Guiverb_WebDriver.Ready then
               Up := True;
               exit;
            end if;
            delay 0.1;
         end loop;
         if not Up then
            Put_Line (Standard_Error,
                      "web driver not ready on port"
                      & Guiverb_WebDriver.Driver_Port'Image);
            Stop_Driver;
            Set_Exit_Status (Failure);
            return;
         end if;
      end;

      Wait_For_User
        ((if To_String (Info.Window_Name) = ""
          then "next step: Then a window appears"
          else "next step: Then a window named `"
               & To_String (Info.Window_Name) & "` appears"));

      begin
         declare
            Headed : constant Boolean :=
              Ada.Environment_Variables.Exists ("GUIVERB_HEADED");
            Session_Id : constant String :=
              Guiverb_WebDriver.New_Session (Headed);
         begin
            Guiverb_WebDriver.Navigate (Session_Id, URL);
            declare
               Actual_Title : constant String :=
                 Guiverb_WebDriver.Title (Session_Id);
               Mismatch : constant Boolean :=
                 To_String (Info.Window_Name) /= ""
                 and then Actual_Title /= To_String (Info.Window_Name);
            begin
               if Mismatch then
                  Put_Line (Standard_Error,
                            "FAIL: a window appears, but its title is """
                            & Actual_Title & """, expected """
                            & To_String (Info.Window_Name) & """");
                  Set_Exit_Status (Failure);
               else
                  Put_Line ("OK: a window appears (title """
                            & Actual_Title & """)");
                  Set_Exit_Status (Success);
               end if;

               Wait_For_User
                 ("end of scenario: press Enter to close the browser");
               Guiverb_WebDriver.Delete_Session (Session_Id);
               Stop_Driver;
            end;
         end;
      exception
         when E : Guiverb_WebDriver.Request_Failed
                | Guiverb_WebDriver.Driver_Unreachable
         =>
            Put_Line (Standard_Error, "FAIL: " & Exception_Message (E));
            Stop_Driver;
            Set_Exit_Status (Failure);
      end;

   exception
      when E : Guiverb_Scenario.Parse_Error =>
         Put_Line (Standard_Error,
                   "scenario error: " & Exception_Message (E));
         Set_Exit_Status (Failure);
   end;

exception
   when User_Abort =>
      Stop_Driver;
      Set_Exit_Status (Failure);
   when others =>
      Stop_Driver;
      raise;
end Guiverb;
