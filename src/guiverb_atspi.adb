--  ---------------------------------------------------------------------------
--  GuiVerb (https://github.com/LionelDraghi/GuiVerb)
--  SPDX-License-Identifier: Apache-2.0
--  SPDX-FileCopyrightText: 2026, Lionel Draghi
--  ---------------------------------------------------------------------------

with Ada.Calendar;          use Ada.Calendar;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Unchecked_Conversion;
with GNAT.OS_Lib;
with Interfaces.C;          use Interfaces.C;
with Interfaces.C.Strings;
with System;

package body Guiverb_ATSPI is

   App_Pid         : GNAT.OS_Lib.Process_Id;
   Target_Pid      : Integer := 0;
   Observed        : Unbounded_String := Null_Unbounded_String;

   use type GNAT.OS_Lib.Process_Id;
   use type System.Address;

   --  libatspi direct imports (no dev headers installed): exactly the
   --  calls a canonical tree walk needs. Correlation is by process id
   --  — the spawned binary IS the application (no intermediate
   --  launcher), so its pid is stable.

   function Atspi_Get_Desktop (D : int) return System.Address;
   pragma Import (C, Atspi_Get_Desktop, "atspi_get_desktop");

   function Atspi_Accessible_Get_Child_Count
     (Obj : System.Address) return int;
   pragma Import (C, Atspi_Accessible_Get_Child_Count,
                     "atspi_accessible_get_child_count");

   function Atspi_Accessible_Get_Child_At_Index
     (Obj : System.Address; Index : int) return System.Address;
   pragma Import (C, Atspi_Accessible_Get_Child_At_Index,
                     "atspi_accessible_get_child_at_index");

   function Atspi_Accessible_Get_Name
     (Obj : System.Address; Error : System.Address) return System.Address;
   pragma Import (C, Atspi_Accessible_Get_Name,
                     "atspi_accessible_get_name");

   function Atspi_Accessible_Get_Process_Id
     (Obj : System.Address; Error : System.Address) return int;
   pragma Import (C, Atspi_Accessible_Get_Process_Id,
                     "atspi_accessible_get_process_id");

   procedure G_Object_Unref (Obj : System.Address);
   pragma Import (C, G_Object_Unref, "g_object_unref");

   procedure G_Free (P : System.Address);
   pragma Import (C, G_Free, "g_free");

   --  A libatspi-returned C string, once read, is released with
   --  g_free (the string transferred to us is glib-allocated).

   function To_Chars is
     new Ada.Unchecked_Conversion
       (System.Address, Interfaces.C.Strings.chars_ptr);

   function C_String_Of (P : System.Address) return String is
   begin
      if P = System.Null_Address then
         return "";
      end if;
      declare
         Text : constant String :=
           Interfaces.C.Strings.Value (To_Chars (P));
      begin
         G_Free (P);
         return Text;
      end;
   end C_String_Of;

   --  Walk the desktop tree looking for a window of the launched
   --  application: correlation by process id only (correlation
   --  policy, minimal form).

   function Scan_For_Window (Expected_Title : String) return Boolean is
      Desktop : constant System.Address := Atspi_Get_Desktop (0);
   begin
      if Desktop = System.Null_Address then
         return False;
      end if;
      for A in 1 .. Atspi_Accessible_Get_Child_Count (Desktop) loop
         declare
            App : constant System.Address :=
              Atspi_Accessible_Get_Child_At_Index (Desktop, int (A - 1));
         begin
            if App /= System.Null_Address
              and then Target_Pid > 0
              and then Integer
                         (Atspi_Accessible_Get_Process_Id
                            (App, System.Null_Address)) = Target_Pid
            then
               for W in 1 .. Atspi_Accessible_Get_Child_Count (App) loop
                  declare
                     Frame : constant System.Address :=
                       Atspi_Accessible_Get_Child_At_Index
                         (App, int (W - 1));
                  begin
                     if Frame /= System.Null_Address then
                        declare
                           Name : constant String :=
                             C_String_Of
                               (Atspi_Accessible_Get_Name
                                  (Frame, System.Null_Address));
                        begin
                           if Expected_Title = ""
                             or else Name = Expected_Title
                           then
                              Observed := To_Unbounded_String (Name);
                              G_Object_Unref (Frame);
                              G_Object_Unref (App);
                              return True;
                           end if;
                           G_Object_Unref (Frame);
                        end;
                     end if;
                  end;
               end loop;
            end if;
            if App /= System.Null_Address then
               G_Object_Unref (App);
            end if;
         end;
      end loop;
      return False;
   end Scan_For_Window;

   procedure Launch (Binary_Path : String) is
      Binary : GNAT.OS_Lib.String_Access :=
        new String'(Binary_Path);
      Binary_List : constant GNAT.OS_Lib.Argument_List :=
        (1 => Binary);
   begin
      App_Pid := GNAT.OS_Lib.Non_Blocking_Spawn
        (Binary_Path, Binary_List);
      GNAT.OS_Lib.Free (Binary);
      if App_Pid = GNAT.OS_Lib.Invalid_Pid then
         raise Launch_Failed with "cannot launch " & Binary_Path;
      end if;
      Target_Pid := GNAT.OS_Lib.Pid_To_Integer (App_Pid);
   end Launch;

   function Window_Appears (Expected_Title : String := "") return Boolean is
      Deadline : constant Time := Clock + 6.0;
      Found    : Boolean := False;
   begin
      Observed := Null_Unbounded_String;
      while Clock < Deadline and then not Found loop
         Found := Scan_For_Window (Expected_Title);
         if not Found then
            delay 0.2;
         end if;
      end loop;
      return Found;
   end Window_Appears;

   function Observed_Title return String is
   begin
      return To_String (Observed);
   end Observed_Title;

   procedure Shutdown is
      Status  : GNAT.OS_Lib.Process_Id;
      Success : Boolean;
   begin
      if Target_Pid > 0 then
         GNAT.OS_Lib.Kill (App_Pid);
         GNAT.OS_Lib.Wait_Process (Status, Success);
         Target_Pid := 0;
      end if;
   end Shutdown;

end Guiverb_ATSPI;
