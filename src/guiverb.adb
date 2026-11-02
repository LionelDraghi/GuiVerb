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
with Guiverb_ATSPI;

procedure Guiverb is

   --  Run the application launcher and return the file:// URL it
   --  prints (first output line). Application resolution keeps the
   --  scenario away from file layout details.

   function Launched_URL (Launch_Script : String) return String is
      Tmp_File : constant String := "/tmp/guiverb-launch.url";
      Success  : Boolean;
      RC       : Integer;
      URL      : Unbounded_String := Null_Unbounded_String;
   begin
      GNAT.OS_Lib.Spawn
        (Program_Name => Launch_Script,
         Args         => (1 .. 0 => null),
         Output_File  => Tmp_File,
         Success      => Success,
         Return_Code  => RC,
         Err_To_Out   => True);
      if not Success or else RC /= 0 then
         return "";
      end if;
      declare
         F : Ada.Text_IO.File_Type;
      begin
         Ada.Text_IO.Open (F, Ada.Text_IO.In_File, Tmp_File);
         if not Ada.Text_IO.End_Of_File (F) then
            URL := To_Unbounded_String
              (Ada.Strings.Fixed.Trim
                 (Ada.Text_IO.Get_Line (F), Ada.Strings.Both));
         end if;
         Ada.Text_IO.Close (F);
      exception
         when others =>
            if Ada.Text_IO.Is_Open (F) then
               Ada.Text_IO.Close (F);
            end if;
      end;
      Ada.Directories.Delete_File (Tmp_File);
      return To_String (URL);
   exception
      when others =>
         return "";
   end Launched_URL;

   --  Resolve the application name of the run step: look for an
   --  apps/<name> directory in the scenario directory, then in each
   --  parent. The Web projection is index.html; a launcher beside it
   --  can replace the default resolution for applications that need
   --  to prepare their environment.

   function App_URL (Scenario_File, App_Name : String) return String is
      Dir : Unbounded_String := To_Unbounded_String
        (Ada.Directories.Containing_Directory (Scenario_File));
   begin
      loop
         declare
            App_Dir : constant String := To_String (Dir) & "/apps/"
              & App_Name;
         begin
            if Ada.Directories.Exists (App_Dir & "/index.html") then
               return "file://"
                 & Ada.Directories.Full_Name (App_Dir & "/index.html");
            elsif Ada.Directories.Exists (App_Dir & "/launch") then
               return Launched_URL (App_Dir & "/launch");
            end if;
         end;
         declare
            Now    : constant String := To_String (Dir);
            Parent : constant String :=
              (if Now = "/" or else Now = "."
               then ""
               else Ada.Directories.Containing_Directory (Now));
         begin
            exit when Parent = To_String (Dir);
            Dir := To_Unbounded_String (Parent);
         end;
      end loop;
      return "";
   end App_URL;

   --  Resolve the application name of the run step: look for an
   --  apps/<name>/bin/<name> executable in the scenario directory,
   --  then in each parent: the built application, which the backend
   --  spawns directly (non-Web backends; no wrapper required from
   --  the application author).

   function App_Binary (Scenario_File, App_Name : String) return String is
      Dir : Unbounded_String := To_Unbounded_String
        (Ada.Directories.Containing_Directory (Scenario_File));
   begin
      loop
         declare
            App_Dir : constant String := To_String (Dir) & "/apps/"
              & App_Name;
         begin
            if Ada.Directories.Exists
                 (App_Dir & "/bin/" & App_Name)
            then
               return App_Dir & "/bin/" & App_Name;
            end if;
         end;
         declare
            Now    : constant String := To_String (Dir);
            Parent : constant String :=
              (if Now = "/" or else Now = "."
               then ""
               else Ada.Directories.Containing_Directory (Now));
         begin
            exit when Parent = To_String (Dir);
            Dir := To_Unbounded_String (Parent);
         end;
      end loop;
      return "";
   end App_Binary;

   Driver         : GNAT.OS_Lib.Process_Id;
   Driver_Spawned : Boolean := False;

   procedure Stop_Driver is
   begin
      if Driver_Spawned then
         GNAT.OS_Lib.Kill (Driver);
         Driver_Spawned := False;
      end if;
   end Stop_Driver;

   type Backend_Kind is (Web, GTK);

   function Backend_Kind_Of (Text : String) return Backend_Kind is
   begin
      if Text = "gtk" or else Text = "GTK" then
         return GTK;
      else
         return Web;
      end if;
   end Backend_Kind_Of;

   Step_Mode     : Boolean := False;
   Scenario_File : Unbounded_String;
   Backend       : Backend_Kind := Web;

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

   if Ada.Environment_Variables.Exists ("GUIVERB_BACKEND") then
      Backend := Backend_Kind_Of
        (Ada.Environment_Variables.Value ("GUIVERB_BACKEND"));
   end if;

   for I in 1 .. Argument_Count loop
      if Argument (I) = "--step" then
         Step_Mode := True;
      elsif Argument (I)'Length >= 10
        and then Argument (I)
                  (Argument (I)'First .. Argument (I)'First + 9)
                  = "--backend="
      then
         Backend := Backend_Kind_Of
           (Argument (I) (Argument (I)'First + 10 .. Argument (I)'Last));
      elsif Scenario_File /= Null_Unbounded_String then
         Put_Line
           (Standard_Error,
            "usage: guiverb [--step] [--backend=web|gtk] <scenario-file>");
         Set_Exit_Status (Failure);
         return;
      else
         Scenario_File := To_Unbounded_String (Argument (I));
      end if;
   end loop;

   if Scenario_File = Null_Unbounded_String then
      Put_Line
        (Standard_Error,
         "usage: guiverb [--step] [--backend=web|gtk] <scenario-file>");
      Set_Exit_Status (Failure);
      return;
   end if;

   declare
      File : constant String := To_String (Scenario_File);
      Info : constant Guiverb_Scenario.Parsed :=
        Guiverb_Scenario.Parse (File);
      URL     : constant String :=
        (if Backend = Web
         then App_URL (File, To_String (Info.App_Name))
         else "");
      --  App resolution is backend-specific: the Web backend wants
      --  the URL to serve; the GTK backend wants the application
      --  binary to spawn. Resolving both would run a launcher twice —
      --  and, for an application that keeps running, deadlock the
      --  blocking URL capture.
      Binary  : constant String :=
        App_Binary (File, To_String (Info.App_Name));
   begin
      Wait_For_User
        ("next step: When I run `" & To_String (Info.App_Name) & "`");

      if (Backend = Web and then URL = "")
        or else (Backend = GTK and then Binary = "")
      then
         Put_Line (Standard_Error, "no application '"
                   & To_String (Info.App_Name)
                   & "' found in an apps/ directory near " & File);
         Set_Exit_Status (Failure);
         return;
      end if;

      --  Backend-owned launch machinery (Q023 working position): the
      --  Web chain owns the driver; the GTK chain spawns the
      --  application binary directly — the spawned pid is the
      --  application's, which is the observation correlation key —
      --  and sets the accessibility environment it needs (GTK 4.14+
      --  defaults to AccessKit; the AT-SPI bridge is what this
      --  backend reads).

      if Backend = GTK then
         Ada.Environment_Variables.Set ("GTK_A11Y", "atspi");
         begin
            Guiverb_ATSPI.Launch (Binary);
         exception
            when E : Guiverb_ATSPI.Launch_Failed =>
               Put_Line (Standard_Error, "FAIL: " & Exception_Message (E));
               Set_Exit_Status (Failure);
               return;
         end;
      else
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
                     (Guiverb_WebDriver.Driver_Port'Image,
                      Ada.Strings.Both))));
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
      end if;

      declare
         Headed : constant Boolean :=
           Ada.Environment_Variables.Exists ("GUIVERB_HEADED");
         Session_Id : GNAT.OS_Lib.String_Access := null;
         Failed     : Boolean := False;

         use type Guiverb_Scenario.Step_Kind;

            --  F005 on the GTK backend: the window check polls the
            --  accessibility bus for the launched application's
            --  window (correlation by process id). Actions and text
            --  assertions come with the next GTK increments.

            procedure Check_Window_Atspi (Expected : String) is
               Ok : constant Boolean :=
                 Guiverb_ATSPI.Window_Appears (Expected);
            begin
               if Ok then
                  Put_Line ("OK: a window appears (title """
                            & Guiverb_ATSPI.Observed_Title & """)");
               else
                  Put_Line (Standard_Error,
                            "FAIL: no window appears for this application"
                            & (if Expected /= ""
                               then " (no window titled """ & Expected
                                    & """)"
                               else ""));
                  Failed := True;
               end if;
            end Check_Window_Atspi;

            procedure Fail_Unsupported (What : String) is
            begin
               Put_Line (Standard_Error,
                         "FAIL: """ & What & """ has no GTK backend"
                         & " implementation yet");
               Failed := True;
            end Fail_Unsupported;

            function Preview (Text : String) return String is
               Max : constant := 200;
            begin
               if Text'Length <= Max then
                  return Text;
               else
                  return Text (Text'First .. Text'First + Max - 1) & "...";
               end if;
            end Preview;

            procedure Check_Window (Expected : String) is
               Actual_Title : constant String :=
                 Guiverb_WebDriver.Title (Session_Id.all);
            begin
               if Expected /= "" and then Actual_Title /= Expected then
                  Put_Line (Standard_Error,
                            "FAIL: a window appears, but its title is """
                            & Actual_Title & """, expected """
                            & Expected & """");
                  Failed := True;
               else
                  Put_Line ("OK: a window appears (title """
                            & Actual_Title & """)");
               end if;
            end Check_Window;

            procedure Check_Contains (Expected : String) is
               Actual_Text : constant String :=
                 Guiverb_WebDriver.Text (Session_Id.all);
            begin
               if Ada.Strings.Fixed.Index (Actual_Text, Expected) = 0 then
                  Put_Line (Standard_Error,
                            "FAIL: the window does not contain """
                            & Expected & """; the window text is: """
                            & Preview (Actual_Text) & """");
                  Failed := True;
               else
                  Put_Line ("OK: the window contains """
                            & Expected & """");
               end if;
            end Check_Contains;

            procedure Check_Button (Expected : String) is
               Element : constant String :=
                 Guiverb_WebDriver.Find (Session_Id.all, "button", Expected);
            begin
               if Element = "" then
                  Put_Line (Standard_Error,
                            "FAIL: there is no button named """
                            & Expected & """");
                  Failed := True;
               else
                  Put_Line ("OK: there is a button named """
                            & Expected & """");
               end if;
            end Check_Button;

            procedure Check_Button_State
              (Expected : String; Wanted : Guiverb_Scenario.Step_Kind)
            is
               Element : constant String :=
                 Guiverb_WebDriver.Find (Session_Id.all, "button", Expected);
               Is_Enabled : Boolean := False;
            begin
               if Element = "" then
                  Put_Line (Standard_Error,
                            "FAIL: there is no button named """
                            & Expected & """");
                  Failed := True;
                  return;
               end if;
               Is_Enabled :=
                 Guiverb_WebDriver.Enabled (Session_Id.all, Element);
               if (Wanted = Guiverb_Scenario.Button_Enabled_Step)
                    = Is_Enabled
               then
                  Put_Line ("OK: the """ & Expected & """ button is "
                            & (if Wanted = Guiverb_Scenario.Button_Enabled_Step
                               then "enabled" else "disabled"));
               else
                  Put_Line (Standard_Error,
                            "FAIL: the """ & Expected & """ button is "
                            & (if Is_Enabled then "enabled" else "disabled"));
                  Failed := True;
               end if;
            end Check_Button_State;

            procedure Do_Press (Expected : String) is
               Element : constant String :=
                 Guiverb_WebDriver.Find (Session_Id.all, "button", Expected);
            begin
               if Element = "" then
                  Put_Line (Standard_Error,
                            "FAIL: there is no button named """
                            & Expected & """ to press");
                  Failed := True;
               else
                  Guiverb_WebDriver.Click (Session_Id.all, Element);
                  Put_Line ("OK: the """ & Expected
                            & """ button is pressed");
               end if;
            end Do_Press;

      begin
         if Backend = Web then
            Session_Id := new String'
              (Guiverb_WebDriver.New_Session (Headed));
            Guiverb_WebDriver.Navigate (Session_Id.all, URL);
         end if;

         for C in Info.Steps.Iterate loop
               declare
                  Current : constant Guiverb_Scenario.Step :=
                    Info.Steps (C);
               begin
                  case Current.Kind is
                     when Guiverb_Scenario.Run_Step =>
                        null;  --  the launch already happened
                     when Guiverb_Scenario.Window_Step =>
                        Wait_For_User
                          ((if To_String (Current.Name) = ""
                            then "next step: Then a window appears"
                            else "next step: Then a window named `"
                                 & To_String (Current.Name)
                                 & "` appears"));
                        if Backend = GTK then
                           Check_Window_Atspi (To_String (Current.Name));
                        else
                           Check_Window (To_String (Current.Name));
                        end if;
                     when Guiverb_Scenario.Contains_Step =>
                        Wait_For_User
                          ("next step: Then the window contains `"
                           & To_String (Current.Name) & "`");
                        if Backend = GTK then
                           Fail_Unsupported ("the window contains ...");
                        else
                           Check_Contains (To_String (Current.Name));
                        end if;
                     when Guiverb_Scenario.Button_Step =>
                        Wait_For_User
                          ("next step: And there is a button named `"
                           & To_String (Current.Name) & "`");
                        if Backend = GTK then
                           Fail_Unsupported ("named button lookup");
                        else
                           Check_Button (To_String (Current.Name));
                        end if;
                     when Guiverb_Scenario.Button_Enabled_Step
                        | Guiverb_Scenario.Button_Disabled_Step
                     =>
                        Wait_For_User
                          ("next step: And the `"
                           & To_String (Current.Name) & "` button is "
                           & (if Current.Kind =
                                    Guiverb_Scenario.Button_Enabled_Step
                              then "enabled" else "disabled"));
                        if Backend = GTK then
                           Fail_Unsupported ("the button enabled state");
                        else
                           Check_Button_State
                             (To_String (Current.Name), Current.Kind);
                        end if;
                     when Guiverb_Scenario.Press_Step =>
                        Wait_For_User
                          ("next step: When I press the `"
                           & To_String (Current.Name) & "` button");
                        if Backend = GTK then
                           Fail_Unsupported ("button press");
                        else
                           Do_Press (To_String (Current.Name));
                        end if;
                  end case;
                  exit when Failed;
               end;
         end loop;

         Set_Exit_Status ((if Failed then Failure else Success));
         Wait_For_User
           ("end of scenario: press Enter to close the browser");
         if Backend = Web then
            Guiverb_WebDriver.Delete_Session (Session_Id.all);
            GNAT.OS_Lib.Free (Session_Id);
            Stop_Driver;
         else
            Guiverb_ATSPI.Shutdown;
         end if;
      exception
         when E : Guiverb_WebDriver.Request_Failed
                | Guiverb_WebDriver.Driver_Unreachable
                | Guiverb_ATSPI.Launch_Failed
         =>
            Put_Line (Standard_Error, "FAIL: " & Exception_Message (E));
            if Backend = Web and then Session_Id /= null then
               begin
                  Guiverb_WebDriver.Delete_Session (Session_Id.all);
                  GNAT.OS_Lib.Free (Session_Id);
               exception
                  when others => null;  --  best effort: browser must close
               end;
            end if;
            if Backend = GTK then
               Guiverb_ATSPI.Shutdown;
            else
               Stop_Driver;
            end if;
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
      Guiverb_ATSPI.Shutdown;
      Stop_Driver;
      Set_Exit_Status (Failure);
   when others =>
      Guiverb_ATSPI.Shutdown;
      Stop_Driver;
      raise;
end Guiverb;
