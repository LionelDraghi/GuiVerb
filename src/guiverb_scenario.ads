--  ---------------------------------------------------------------------------
--  GuiVerb (https://github.com/LionelDraghi/GuiVerb)
--  SPDX-License-Identifier: Apache-2.0
--  SPDX-FileCopyrightText: 2026, Lionel Draghi
--  ---------------------------------------------------------------------------

with Ada.Containers.Vectors;
with Ada.Strings.Unbounded;

package Guiverb_Scenario is

   --  Scenario parser: recognizes the steps implemented to date and
   --  returns them in file order. A step not supported by this build
   --  is a parse error, never silently ignored.

   Parse_Error : exception;

   type Step_Kind is
     (Run_Step,             --  When I run <app>
      Window_Step,          --  Then a window [named <name>] appears
      Contains_Step,        --  the window contains <text>
      Button_Step,          --  there is a button named <name>
      Button_Enabled_Step,  --  the <name> button is enabled
      Button_Disabled_Step, --  the <name> button is disabled
      Press_Step,             --  When I press the <name> button
      Dialog_Step,            --  a <name> dialog eventually appears
      Textbox_Step,           --  the dialog contains a textbox named <name>
      Textbox_Password_Step,  --  a password textbox named <name>
      Textbox_Focus_Step);    --  the <name> textbox has focus

   type Step is record
      Kind : Step_Kind;
      Name : Ada.Strings.Unbounded.Unbounded_String;
      --  The step's backticked parameter; empty for the unnamed
      --  "a window appears" variant.
   end record;

   package Step_Lists is new Ada.Containers.Vectors
     (Index_Type => Positive, Element_Type => Step);

   type Parsed is record
      App_Name : Ada.Strings.Unbounded.Unbounded_String;
      --  From the run step; the launch happens before any other step.
      Steps : Step_Lists.Vector;
      --  The steps in file order, run step excluded.
   end record;

   function Parse (File_Name : String) return Parsed;

end Guiverb_Scenario;
