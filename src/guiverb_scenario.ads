--  ---------------------------------------------------------------------------
--  GuiVerb (https://github.com/LionelDraghi/GuiVerb)
--  SPDX-License-Identifier: Apache-2.0
--  SPDX-FileCopyrightText: 2026, Lionel Draghi
--  ---------------------------------------------------------------------------

with Ada.Strings.Unbounded;

package Guiverb_Scenario is

   --  Minimal scenario parser for the first milestone: recognizes the
   --  steps needed by F005 (launch, window observation) only.

   Parse_Error : exception;

   type Parsed is record
      App_Name    : Ada.Strings.Unbounded.Unbounded_String;
      Window_Name : Ada.Strings.Unbounded.Unbounded_String :=
        Ada.Strings.Unbounded.Null_Unbounded_String;
      --  Empty means the "a window appears" unnamed variant.
      Window_Text : Ada.Strings.Unbounded.Unbounded_String :=
        Ada.Strings.Unbounded.Null_Unbounded_String;
      --  Empty means no "the window contains" text assertion (F010).
      Has_Window  : Boolean := False;
   end record;

   function Parse (File_Name : String) return Parsed;

end Guiverb_Scenario;
