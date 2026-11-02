--  ---------------------------------------------------------------------------
--  GuiVerb (https://github.com/LionelDraghi/GuiVerb)
--  SPDX-License-Identifier: Apache-2.0
--  SPDX-FileCopyrightText: 2026, Lionel Draghi
--  ---------------------------------------------------------------------------
--  The reference application, GTK4 projection. Same reference
--  behaviour as the Web witness: window "GuiVerb witness", button
--  "Continue". Pattern from the GtkAda4 testsuite: Gtk.Main.Init
--  before any widget, Present to show, events pumped with
--  Main_Context_Iteration (there is no Gtk.Main.Main in GTK4).
--  GTK_A11Y=atspi (set by the runner's GTK backend) makes GTK 4.14+
--  expose the tree over AT-SPI instead of AccessKit.
--  ---------------------------------------------------------------------------

with Ada.Text_IO;
with Glib.Main;
with Gtk.Main;
with Gtk.Widget; use Gtk.Widget;
with Gtk.Window; use Gtk.Window;
with Gtk.Button; use Gtk.Button;

procedure Witness is
   Win     : Gtk_Window;
   Button  : Gtk_Button;
   Closing : Boolean := False;

   procedure Window_Destroyed (Self : access Gtk_Widget_Record'Class) is
      pragma Unreferenced (Self);
   begin
      Closing := True;
      Ada.Text_IO.Put_Line ("witness: window destroyed");
      Ada.Text_IO.Flush;
   end Window_Destroyed;

begin
   Gtk.Main.Init;
   Gtk_New (Win);
   Win.Set_Title ("GuiVerb witness");
   Win.Set_Default_Size (360, 240);
   Gtk_New (Button, "Continue");
   Win.Set_Child (Button);
   Win.Show;
   Win.Present;
   Win.On_Destroy (Window_Destroyed'Unrestricted_Access);

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
