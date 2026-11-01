--  ---------------------------------------------------------------------------
--  GuiVerb (https://github.com/LionelDraghi/GuiVerb)
--  SPDX-License-Identifier: Apache-2.0
--  SPDX-FileCopyrightText: 2026, Lionel Draghi
--  ---------------------------------------------------------------------------

with Ada.Directories;
with Ada.Strings.Fixed;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO;

package body Guiverb_Scenario is

   function Trimmed (Line : String) return String is
      First : Natural := Line'First;
      Last  : Natural := Line'Last;
   begin
      while First <= Last and then Line (First) = ' ' loop
         First := First + 1;
      end loop;
      while Last >= First and then Line (Last) = ' ' loop
         Last := Last - 1;
      end loop;
      return Line (First .. Last);
   end Trimmed;

   --  The text between the first pair of backticks, or "" if none.

   function Backticked (Line : String) return String is
   begin
      for I in Line'Range loop
         if Line (I) = '`' then
            for J in I + 1 .. Line'Last loop
               if Line (J) = '`' then
                  return Line (I + 1 .. J - 1);
               end if;
            end loop;
            return "";
         end if;
      end loop;
      return "";
   end Backticked;

   function Parse (File_Name : String) return Parsed is
      File    : Ada.Text_IO.File_Type;
      Result  : Parsed;
   begin
      Ada.Text_IO.Open (File, Ada.Text_IO.In_File, File_Name);
      while not Ada.Text_IO.End_Of_File (File) loop
         declare
            Line  : constant String := Trimmed (Ada.Text_IO.Get_Line (File));
         begin
            if Line /= "" and then Line (Line'First) /= '#' then
               if Line'Length >= 12
                 and then Line (Line'First .. Line'First + 11) = "- When I run"
               then
                  declare
                     Name : constant String := Backticked (Line);
                  begin
                     if Name = "" then
                        raise Parse_Error
                        with "run step without application name: " & Line;
                     elsif Result.App_Name /= Null_Unbounded_String then
                        raise Parse_Error with "two run steps in one scenario";
                     end if;
                     Result.App_Name := To_Unbounded_String (Name);
                  end;
               elsif Line = "- Then a window appears" then
                  Result.Has_Window := True;
               elsif Line'Length >= 21
                 and then Line (Line'First .. Line'First + 20)
                            = "- Then a window named"
               then
                  declare
                     Name : constant String := Backticked (Line);
                  begin
                     if Name = "" then
                        raise Parse_Error
                        with "named window step without name: " & Line;
                     end if;
                     Result.Has_Window := True;
                     Result.Window_Name := To_Unbounded_String (Name);
                  end;
               elsif Ada.Strings.Fixed.Index (Line, "the window contains") > 0
               then
                  declare
                     Text : constant String := Backticked (Line);
                  begin
                     if Text = "" then
                        raise Parse_Error
                        with "window text step without text: " & Line;
                     elsif Result.Window_Text /= Null_Unbounded_String then
                        raise Parse_Error
                        with "two window text steps in one scenario";
                     end if;
                     Result.Window_Text := To_Unbounded_String (Text);
                  end;
               else
                  if Line'Length >= 2
                    and then Line (Line'First .. Line'First + 1) = "- "
                  then
                     raise Parse_Error
                     with "step not supported by this build: " & Line;
                  end if;
                  --  anything else is prose: ignored
               end if;
            end if;
         end;
      end loop;
      Ada.Text_IO.Close (File);

      if Result.App_Name = Null_Unbounded_String or else not Result.Has_Window
      then
         raise Parse_Error
         with "scenario needs a run step and a window assertion";
      end if;
      return Result;
   exception
      when Ada.Directories.Name_Error =>
         raise Parse_Error with "scenario file not found: " & File_Name;
   end Parse;

end Guiverb_Scenario;
