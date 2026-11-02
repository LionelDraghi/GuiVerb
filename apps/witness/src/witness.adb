--  GuiVerb (https://github.com/LionelDraghi/GuiVerb)
--  SPDX-License-Identifier: Apache-2.0
--  SPDX-FileCopyrightText: 2026, Lionel Draghi
--  ---------------------------------------------------------------------------
--  The reference application, GTK4 projection. Same reference
--  behaviour as the Web witness (apps/witness/index.html): window
--  "GuiVerb witness", text "Hello World", button "Continue" that
--  opens the login dialog ("Log in") with a User text entry (focused
--  on open) and a password entry. The login view is a Gtk_Window
--  carrying accessible role "dialog" (GTK 4.10+; Gtk.Dialog is
--  obsolescent in GtkAda4); labels are linked with Set_Mnemonic_Widget,
--  the GTK 4 way of carrying accname to the field. Pattern from the
--  GtkAda4 testsuite: Gtk.Main.Init before any widget, Present to
--  show, events pumped with Main_Context_Iteration (there is no
--  Gtk.Main.Main in GTK4).
--  GTK_A11Y=atspi (set by the runner's GTK backend) makes GTK 4.14+
--  expose the tree over AT-SPI instead of AccessKit.
--  ---------------------------------------------------------------------------

with Ada.Text_IO;
with Glib.Main;
with Gtk.Accessible;
with Gtk.Box;      use Gtk.Box;
with Gtk.Button;   use Gtk.Button;
with Gtk.Enums;    use Gtk.Enums;
with Gtk.Gentry;   use Gtk.Gentry;
with Gtk.Label;    use Gtk.Label;
with Gtk.Main;
with Gtk.Widget;   use Gtk.Widget;
with Gtk.Window;   use Gtk.Window;

procedure Witness is
   Win        : Gtk_Window;
   Box        : Gtk_Box;
   Label      : Gtk_Label;
   Button     : Gtk_Button;
   Login      : Gtk_Window;
   Login_Box  : Gtk_Box;
   User_Label : Gtk_Label;
   User_Entry : Gtk_Entry;
   Pass_Label : Gtk_Label;
   Pass_Entry : Gtk_Entry;
   Closing    : Boolean := False;

   procedure Window_Destroyed (Self : access Gtk_Widget_Record'Class) is
      pragma Unreferenced (Self);
   begin
      Closing := True;
      Ada.Text_IO.Put_Line ("witness: window destroyed");
      Ada.Text_IO.Flush;
   end Window_Destroyed;

   procedure Continue_Clicked (Self : access Gtk_Button_Record'Class) is
      pragma Unreferenced (Self);
      Focused : Boolean := False;
   begin
      Login.Present;
      --  Grab_Focus fails while the window is not mapped yet: retry.
      for Try in 1 .. 25 loop
         Focused := User_Entry.Grab_Focus;
         exit when Focused;
         delay 0.02;
      end loop;
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

   Gtk_New (Login);
   Login.Set_Title ("Log in");
   Login.Set_Default_Size (300, 160);
   Login.Set_Modal (True);
   Login.Set_Transient_For (Win);
   Gtk.Accessible.Gtk_Accessible_Role_Properties.Set_Property
     (Login,
      Gtk.Accessible.Gtk_Accessible_Role_Properties.Property
        (Gtk.Accessible.Accessible_Role_Property),
      Gtk.Accessible.Accessible_Role_Dialog);
   Gtk_New (Login_Box, Orientation_Vertical, 6);
   Login.Set_Child (Login_Box);

   Gtk_New (User_Label, "User");
   Gtk_New (User_Entry);
   User_Label.Set_Mnemonic_Widget (User_Entry);
   Login_Box.Append (User_Label);
   Login_Box.Append (User_Entry);

   Gtk_New (Pass_Label, "Password");
   Gtk_New (Pass_Entry);
   Pass_Entry.Set_Visibility (False);
   Pass_Label.Set_Mnemonic_Widget (Pass_Entry);
   Login_Box.Append (Pass_Label);
   Login_Box.Append (Pass_Entry);

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
