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
--
--  Dress code (a sober, dark CAD-tool look — near-black canvas,
--  quiet panels, neutral controls, one accent for the primary
--  action): Adi2 ships no default dressing — a bare widget renders as
--  positioned text — so the projection styles its parts explicitly,
--  with the programmatic style builder. The CSS codegen path (a
--  tool-run per stylesheet) is the alternative; not wanted for a
--  witness at this stage.
--  ---------------------------------------------------------------------------

pragma Ada_2022;

with Ada.Strings.Fixed;
with Adi.App;
with Adi.CSS_Styles;         use Adi.CSS_Styles;
with Adi.Layout_Util;
with Adi.MCP;
with Adi.Widget_Styles;      use Adi.Widget_Styles;
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

   --  Palette — neutral darks, one blue accent, light ink.
   Canvas     : constant Color_Value := RGB (24, 27, 31);
   Panel      : constant Color_Value := RGB (36, 40, 45);
   Field      : constant Color_Value := RGB (29, 33, 38);
   Ink        : constant Color_Value := RGB (226, 229, 233);
   Ink_Dim    : constant Color_Value := RGB (145, 152, 160);
   Edge       : constant Color_Value := RGB (58, 64, 72);
   Accent     : constant Color_Value := RGB (33, 150, 243);
   Accent_Hv  : constant Color_Value := RGB (52, 163, 246);
   Accent_Ps  : constant Color_Value := RGB (25, 118, 210);
   Neutral    : constant Color_Value := RGB (46, 51, 57);
   Neutral_Hv : constant Color_Value := RGB (56, 62, 69);
   Neutral_Ps : constant Color_Value := RGB (38, 42, 48);

   --  One style definition per part: a base and the two interactive
   --  states (empty state rules overlay nothing). The builder interns
   --  on Build, so repeated calls stay cheap.
   procedure Set_Dress (H : Widget_Handle; P : Part_Kind;
                        Base, Hover, Press, Focus : Style_Rules) is
   begin
      Set_Part_Style (H, P,
        Create.Base (Base).On_Hover (Hover).On_Press (Press)
                    .On_Focus (Focus).Build);
   end Set_Dress;

   function Panel_Surface (Background : Color_Value) return Style_Rules is
     (Empty_Style with Delta
        Background_Color => Opt_Bg_Color.Val (Background),
        Border_Width     =>
          [others => Opt_Length.Val (Px (1.0))],
        Border_Color     =>
          [others => Opt_Edge_Color.Val (Edge)],
        Border_Radius    => [others => Opt_Length.Val (Px (8.0))],
        Padding          => [others => Opt_Length.Val (Px (14.0))],
        Gap              => Opt_Gap.Val (Gap (Px (10.0))));

   procedure Dress_Container
     (C : Adi.Widget.Box.Box_Handle; Background : Color_Value) is
   begin
      Set_Dress (Widget_Handle'(+C), Main_Part,
                 Panel_Surface (Background), Empty_Style, Empty_Style, Empty_Style);
   end Dress_Container;

   function Button_Surface (Bg : Color_Value) return Style_Rules is
     (Empty_Style with Delta
        Display          => Opt_Display.Val (Inline_Flex),
        Justify_Content  => Opt_Justify.Val (Center),
        Align_Items      => Opt_Align_Items.Val (Center),
        Background_Color => Opt_Bg_Color.Val (Bg),
        Color            => Opt_Text_Color.Val (Ink),
        Border_Width     => [others => Opt_Length.Val (Px (1.0))],
        Border_Color     => [others => Opt_Edge_Color.Val (Edge)],
        Border_Radius    => [others => Opt_Length.Val (Px (4.0))],
        Padding          =>
          [Top    => Opt_Length.Val (Px (8.0)),
           Right  => Opt_Length.Val (Px (18.0)),
           Bottom => Opt_Length.Val (Px (8.0)),
           Left   => Opt_Length.Val (Px (18.0))]);

   procedure Dress_Button (B : Button_Handle; Accent_One : Boolean) is
      Surface : constant Style_Rules :=
        (if Accent_One
         then Button_Surface (Accent)
         else Button_Surface (Neutral));
      Hover : constant Style_Rules :=
        (Empty_Style with Delta
           Background_Color =>
             Opt_Bg_Color.Val ((if Accent_One then Accent_Hv else Neutral_Hv)));
      Press : constant Style_Rules :=
        (Empty_Style with Delta
           Background_Color =>
             Opt_Bg_Color.Val ((if Accent_One then Accent_Ps else Neutral_Ps)));
   begin
      Set_Dress (Widget_Handle'(+B), Main_Part,
                 Surface, Hover, Press, Empty_Style);
   end Dress_Button;

   --  Labels draw their text on the label part (the button's text is
   --  the same part through inheritance).
   procedure Dress_Text (H : Widget_Handle; Tint : Color_Value) is
      Rules : constant Style_Rules :=
        (Empty_Style with Delta Color => Opt_Text_Color.Val (Tint));
   begin
      Set_Dress (H, Label_Part, Rules, Empty_Style, Empty_Style, Empty_Style);
   end Dress_Text;

   --  Fields: a dark inset surface on the main part, light ink on the
   --  text part, accent border while focused (the state rule overlays
   --  only the border color of the base).
   procedure Dress_Field
     (F : Adi.Widget.Text_Input.Text_Input_Handle) is
      Base : constant Style_Rules :=
        (Empty_Style with Delta
          Background_Color => Opt_Bg_Color.Val (Field),
          Border_Width     => [others => Opt_Length.Val (Px (1.0))],
          Border_Color     => [others => Opt_Edge_Color.Val (Edge)],
          Border_Radius    => [others => Opt_Length.Val (Px (4.0))],
          Padding          =>
            [Top    => Opt_Length.Val (Px (6.0)),
             Right  => Opt_Length.Val (Px (10.0)),
             Bottom => Opt_Length.Val (Px (6.0)),
             Left   => Opt_Length.Val (Px (10.0))]);
      Focused : constant Style_Rules :=
        (Empty_Style with Delta
           Border_Color => [others => Opt_Edge_Color.Val (Accent)]);
      Text : constant Style_Rules :=
        (Empty_Style with Delta Color => Opt_Text_Color.Val (Ink));
   begin
      Set_Dress (Adi.Widget.Text_Input.To_Widget_Handle (F), Main_Part,
                 Base, Empty_Style, Empty_Style, Focused);
      Set_Dress (Adi.Widget.Text_Input.To_Widget_Handle (F), Text_Part,
                 Text, Empty_Style, Empty_Style, Empty_Style);
   end Dress_Field;

   --  The refresh fix (see the tick below): a programming-activated
   --  change (the bridge's click_widget, a Set_Visible) marks the
   --  tree dirty and the frame draws — but a frame only PRESENTS when
   --  it draws, so a window drawn once then left clean shows its last
   --  frame until the next mouse motion makes it dirty again. The
   --  witness asks for a redraw every frame; at the target frame rate
   --  this is the always-covered case a harness wants, and the
   --  intrusive-cost analogue of a continuous-redraw app.
   Live_Window : Window_Handle := Null_Window_Handle;

   procedure Keep_Presented (DT : Duration) is
      pragma Unreferenced (DT);
   begin
      Adi.Window.Request_Redraw (Live_Window);
   end Keep_Presented;

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

      --  The window-title declaration draws the root label over the
      --  first child (the overlay is the root box's origin child);
      --  the spacer is a blank-text label line that keeps the
      --  content below it.
      Spacer : constant Label_Handle := Create_Handle (" ");
   begin
      --  Window title declaration: the probe bridge exposes no SDL
      --  title bar, and the root widget's declared label is the one
      --  name-carrying channel it serializes (a box's text falls back
      --  to its declared label). The projection carries the window
      --  title there; the runner reads it as the window's name
      --  (Guiverb_AdiMCP). The declared label renders as a text part
      --  on the root box — tinted as the dim header line of the
      --  dress code, deliberately.
      Adi.Widget.Set_Label (Widget_Handle'(+Root), "GuiVerb witness");
      Dress_Container (Root, Canvas);
      Dress_Text (Widget_Handle'(+Root), Ink_Dim);

      Status_Label := Create_Handle ("");
      Set_Visible (Widget_Handle'(+Status_Label), False);

      Add_Child (Widget_Handle'(+Root), Widget_Handle'(+Spacer));
      Add_Child (Widget_Handle'(+Root), Widget_Handle'(+Title));
      Add_Child (Widget_Handle'(+Root), Widget_Handle'(+Continue_Btn));
      Add_Child (Widget_Handle'(+Root), Widget_Handle'(+Refresh_Btn));
      Add_Child (Widget_Handle'(+Root), Widget_Handle'(+Status_Label));

      Dress_Text (Widget_Handle'(+Title), Ink);
      Dress_Button (Continue_Btn, True);
      Dress_Button (Refresh_Btn, False);
      Dress_Text (Widget_Handle'(+Status_Label), Ink);

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

         Dress_Container (Content_Box, Panel);
         Dress_Text (Widget_Handle'(+User_Label), Ink);
         Dress_Text (Widget_Handle'(+Password_Label), Ink);
         Dress_Text (Widget_Handle'(+Alert_Label), Ink);
         Dress_Button (Login_Btn, False);
         Dress_Field (User_Field);
         Dress_Field (Password_Field);

         Connect_Clicked (Login_Btn, On_Login_Click'Unrestricted_Access);

         Login_Dialog := Adi.Widget.Dialog.Create_Handle;
         Adi.Widget.Dialog.Attach_Window (Login_Dialog, W);
         Adi.Widget.Dialog.Set_Title (Login_Dialog, "Log in");
         Adi.Widget.Dialog.Set_Content (Login_Dialog, +Content_Box);
         --  The dialog's own shell is styled like any other panel:
         --  its internal title label and content panel are handles
         --  the widget exposes (a bare label renders default-ink
         --  black, unreadable on the dark canvas otherwise).
         Dress_Text
           (Widget_Handle'
              (+Adi.Widget.Dialog.Get_Title_Handle (Login_Dialog)),
            Ink);
         Dress_Container
           (Adi.Widget.Dialog.Get_Content_Panel_Handle (Login_Dialog),
            Panel);
         --  No Add_Button on the dialog shell: the semantic Login
         --  button lives in the content box, like the Web witness.
         Adi.Widget.Dialog.Set_Dismiss_On_Backdrop (Login_Dialog, False);
         Adi.Widget.Dialog.Set_Dismiss_On_Escape (Login_Dialog, False);
      end;

      Set_Root (W, Widget_Handle'(+Root));
      Adi.MCP.Initialize (W);

      --  The first frame presents only when something is dirty (the
      --  initial tree is born clean); the per-frame redraw request
      --  above covers the first frame as well.
      Live_Window := W;
      Adi.Window.Connect_Tick (W, Keep_Presented'Unrestricted_Access);

      A.Add_Window (W);
      A.Run;
      Adi.MCP.Finalize;
   end;
end Witness_Adi2;
