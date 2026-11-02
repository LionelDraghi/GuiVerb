--  GuiVerb (https://github.com/LionelDraghi/GuiVerb)
--  SPDX-License-Identifier: Apache-2.0
--  SPDX-FileCopyrightText: 2026, Lionel Draghi
--  ---------------------------------------------------------------------------
--  The reference application, GTK4 projection. Same reference
--  behaviour as the Web witness (apps/witness/index.html): window
--  "GuiVerb witness", text "Hello World", button "Continue" that
--  opens the login view ("Log in" revealed). Pattern from the
--  GtkAda4 testsuite: Gtk.Main.Init before any widget, Present to
--  show, events pumped with Main_Context_Iteration (there is no
--  Gtk.Main.Main in GTK4).
--  GTK_A11Y=atspi (set by the runner's GTK backend) makes GTK 4.14+
--  expose the tree over AT-SPI instead of AccessKit.
--  ---------------------------------------------------------------------------

with Ada.Text_IO;
with Glib.Main;
with Gtk.Box;      use Gtk.Box;
with Gtk.Button;   use Gtk.Button;
with Gtk.Enums;    use Gtk.Enums;
with Gtk.Label;    use Gtk.Label;
with Gtk.Main;
with Gtk.Widget;   use Gtk.Widget;
with Gtk.Window;   use Gtk.Window;

procedure Witness is
   Win     : Gtk_Window;
   Box     : Gtk_Box;
   Label   : Gtk_Label;
   Button  : Gtk_Button;
   Closing : Boolean := False;

   procedure Window_Destroyed (Self : access Gtk_Widget_Record'Class) is
      pragma Unreferenced (Self);
   begin
      Closing := True;
      Ada.Text_IO.Put_Line ("witness: window destroyed");
      Ada.Text_IO.Flush;
   end Window_Destroyed;

   procedure Continue_Clicked (Self : access Gtk_Button_Record'Class) is
      pragma Unreferenced (Self);
   begin
      Label.Set_Text ("Log in");
   end Continue_Clicked;

begin
   Gtk.Main.Init;
   Gtk_New (Win);
   Win.Set_Title ("GuiVerb witness");
   Win.Set_Default_Size (360, 240);
   Gtk_New (Box, Orientation_Vertical, 6);
   Win.Set_Child (Box);
   Gtk_New (Label, "Hello World");
   Box.Append (Label);
   Gtk_New (Button, "Continue");
   Box.Append (Button);
   Win.Show;
   Win.Present;
   Win.On_Destroy (Window_Destroyed'Unrestricted_Access);
   Button.On_Clicked (Continue_Clicked'Unrestricted_Access);

   while not Closing loop
      declare
         Dispatched : constant Boolean :=
           Glib.Main.Main_Context_Iteration (May_Block => False);
         pragma Unreferenced (Dispatched);
      begin
         delay 0.02;
      end;
   end loop;
end Witness;
