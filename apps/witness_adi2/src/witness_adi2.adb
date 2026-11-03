--  GuiVerb (https://github.com/LionelDraghi/GuiVerb)
--  SPDX-License-Identifier: Apache-2.0
--  SPDX-FileCopyrightText: 2026, Lionel Draghi
--  ---------------------------------------------------------------------------
--  The reference application, Adi2 probe projection (phase 4). Same
--  reference behaviour as the Web witness (apps/witness/index.html):
--  window "GuiVerb witness", text "Hello World", button "Continue"
--  that opens the login dialog ("Log in") with a User text entry
--  (focused on open) and a password entry, and a Refresh button that
--  posts a status message.
--
--  Probe activation (the phase 4 measurement subject): the SAME
--  source builds with and without the probe. The Adi2 build profile
--  decides — development compiles src/mcp (the file-IPC introspection
--  bridge), any other profile compiles the documented no-op stub
--  (src/mcp_stub). The application's opt-in is the Initialize call
--  below, a no-op when the stub is linked in.
--  ---------------------------------------------------------------------------

pragma Ada_2022;

with Ada.Strings.Fixed;
with Adi.App;
with Adi.CSS_Styles;    use Adi.CSS_Styles;
with Adi.Layout_Util;
with Adi.MCP;
with Adi.Window;             use Adi.Window;
with Adi.Widget;             use Adi.Widget;
with Adi.Widget.Box;         use type Adi.Widget.Box.Box_Handle;
with Adi.Widget.Label;       use Adi.Widget.Label;
with Adi.Widget.Button;      use Adi.Widget.Button;
with Adi.Widget.Text_Input;
with Adi.Widget.Dialog;

procedure Witness_Adi2 is
   A : Adi.App.App;

   Status_Label  : Label_Handle;
   Alert_Label   : Label_Handle;
   User_Field    : Adi.Widget.Text_Input.Text_Input_Handle;
   Login_Dialog  : Adi.Widget.Dialog.Dialog_Handle;

   procedure Hide_Alert_And_Clear_User is
   begin
      if Is_Valid (Alert_Label) then
         Set_Visible (Widget_Handle'(+Alert_Label), False);
      end if;
      Adi.Widget.Text_Input.Set_Text (User_Field, "");
   end Hide_Alert_And_Clear_User;

   procedure On_Login_Click (W : Widget_Handle) is
      pragma Unreferenced (W);
   begin
      if Ada.Strings.Fixed.Trim
           (Adi.Widget.Text_Input.Get_Text (User_Field),
            Ada.Strings.Both)
        = ""
      then
         Set_Visible (Widget_Handle'(+Alert_Label), True);
         Set_Focused (Adi.Widget.Text_Input."+" (User_Field));
      else
         Adi.Widget.Label.Set_Text (Status_Label, "Logged in");
         Set_Visible (Widget_Handle'(+Status_Label), True);
         Adi.Widget.Dialog.Hide (Login_Dialog);
      end if;
   end On_Login_Click;

   procedure On_Continue (Btn : Widget_Handle) is
      pragma Unreferenced (Btn);
   begin
      Hide_Alert_And_Clear_User;
      Adi.Widget.Dialog.Show (Login_Dialog);
      Set_Focused (Adi.Widget.Text_Input."+" (User_Field));
   end On_Continue;

   procedure On_Refresh (Btn : Widget_Handle) is
      pragma Unreferenced (Btn);
   begin
      --  Deviation from the Web witness: the 300 ms asynchronous delay
      --  is not reproduced; Adi2 exposes no public timer API. The
      --  status appears immediately, so the scenario wait degenerates
      --  to a single poll.
      Adi.Widget.Label.Set_Text (Status_Label, "Up to date");
      Set_Visible (Widget_Handle'(+Status_Label), True);
   end On_Refresh;

begin
   A.Init;
   Adi.Layout_Util.Set_Px_Maps_To_Dip (True);
   A.Set_Target_FPS (60);

   declare
      W : constant Window_Handle :=
        Create_Window_Handle ("GuiVerb witness",
                              Adi.Window.Extent (Px (420.0), Px (260.0)));

      Root : constant Adi.Widget.Box.Box_Handle :=
        Adi.Widget.Box.Create_Handle;

      Title : constant Label_Handle := Create_Handle ("Hello World");
      Continue_Btn : constant Button_Handle := Create_Handle ("Continue");
      Refresh_Btn  : constant Button_Handle := Create_Handle ("Refresh");
   begin
      Status_Label := Create_Handle ("");
      Set_Visible (Widget_Handle'(+Status_Label), False);

      Add_Child (Widget_Handle'(+Root), Widget_Handle'(+Title));
      Add_Child (Widget_Handle'(+Root), Widget_Handle'(+Continue_Btn));
      Add_Child (Widget_Handle'(+Root), Widget_Handle'(+Refresh_Btn));
      Add_Child (Widget_Handle'(+Root), Widget_Handle'(+Status_Label));

      Connect_Clicked (Continue_Btn, On_Continue'Unrestricted_Access);
      Connect_Clicked (Refresh_Btn, On_Refresh'Unrestricted_Access);

      --  Login dialog (overlay): user + password fields, login button,
      --  validation alert — same content as the Web witness dialog.
      declare
         Content_Box : constant Adi.Widget.Box.Box_Handle :=
           Adi.Widget.Box.Create_Handle;
         User_Label    : constant Label_Handle := Create_Handle ("User");
         Password_Label : constant Label_Handle := Create_Handle ("Password");
         Password_Field : constant Adi.Widget.Text_Input.Text_Input_Handle :=
           Adi.Widget.Text_Input.Create_Handle ("");
         Login_Btn : constant Button_Handle := Create_Handle ("Login");
      begin
         User_Field := Adi.Widget.Text_Input.Create_Handle ("");
         Alert_Label := Create_Handle ("User is required");
         Set_Visible (Widget_Handle'(+Alert_Label), False);

         Adi.Widget.Text_Input.Set_Password_Mode (Password_Field);

         Add_Child (Widget_Handle'(+Content_Box), Widget_Handle'(+User_Label));
         Add_Child (Widget_Handle'(+Content_Box), Adi.Widget.Text_Input."+" (User_Field));
         Add_Child (Widget_Handle'(+Content_Box), Widget_Handle'(+Password_Label));
         Add_Child (Widget_Handle'(+Content_Box), Adi.Widget.Text_Input."+" (Password_Field));
         Add_Child (Widget_Handle'(+Content_Box), Widget_Handle'(+Alert_Label));
         Add_Child (Widget_Handle'(+Content_Box), Widget_Handle'(+Login_Btn));
         Connect_Clicked (Login_Btn, On_Login_Click'Unrestricted_Access);

         Login_Dialog := Adi.Widget.Dialog.Create_Handle;
         Adi.Widget.Dialog.Attach_Window (Login_Dialog, W);
         Adi.Widget.Dialog.Set_Title (Login_Dialog, "Log in");
         Adi.Widget.Dialog.Set_Content (Login_Dialog, +Content_Box);
         --  No Add_Button on the dialog shell: the semantic Login
         --  button lives in the content box, like the Web witness.
         Adi.Widget.Dialog.Set_Dismiss_On_Backdrop (Login_Dialog, False);
         Adi.Widget.Dialog.Set_Dismiss_On_Escape (Login_Dialog, False);
      end;

      Set_Root (W, Widget_Handle'(+Root));
      Adi.MCP.Initialize (W);
      A.Add_Window (W);
      A.Run;
      Adi.MCP.Finalize;
   end;
end Witness_Adi2;
