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

   Scenario_File : constant String :=
     (if Argument_Count = 1 then Argument (1) else "");

begin
   --  The loader path is often polluted in development environments
   --  (e.g. IDE extension libraries) and that breaks the spawned
   --  browser; the chain needs a clean loader path.

   if Ada.Environment_Variables.Exists ("LD_LIBRARY_PATH") then
      Ada.Environment_Variables.Set ("LD_LIBRARY_PATH", "");
   end if;

   if Scenario_File = "" then
      Put_Line (Standard_Error, "usage: guiverb <scenario-file>");
      Set_Exit_Status (Failure);
      return;
   end if;

   declare
      Info : constant Guiverb_Scenario.Parsed :=
        Guiverb_Scenario.Parse (Scenario_File);
      URL  : constant String :=
        App_URL (Scenario_File, To_String (Info.App_Name));
   begin
      if URL = "" then
         Put_Line (Standard_Error, "no application '"
                   & To_String (Info.App_Name)
                   & "' found in an apps/ directory near " & Scenario_File);
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
            begin
               Guiverb_WebDriver.Delete_Session (Session_Id);

               if To_String (Info.Window_Name) /= ""
                 and then Actual_Title /= To_String (Info.Window_Name)
               then
                  Put_Line (Standard_Error,
                            "FAIL: a window appears, but its title is """
                            & Actual_Title & """, expected """
                            & To_String (Info.Window_Name) & """");
                  Stop_Driver;
                  Set_Exit_Status (Failure);
                  return;
               end if;

               Put_Line ("OK: a window appears (title """
                         & Actual_Title & """)");
               Stop_Driver;
               Set_Exit_Status (Success);
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
   when others =>
      Stop_Driver;
      raise;
end Guiverb;
