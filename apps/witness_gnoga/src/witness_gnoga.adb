--  GuiVerb (https://github.com/LionelDraghi/GuiVerb)
--  SPDX-License-Identifier: Apache-2.0
--  SPDX-FileCopyrightText: 2026, Lionel Draghi
--  ---------------------------------------------------------------------------
--  The reference application, Gnoga projection: a long-running Web
--  application (HTTP server + WebSocket), same reference behaviour as
--  the static Web witness (apps/witness/index.html):
--    document title "GuiVerb witness", text "Hello World",
--    button "Continue" reveals the login view
--    (currently a plain view — role="dialog" and aria-label are
--    set with the Element.Attribute setter, which breaks the
--    WebSocket dispatch on Gnoga 2.2.3, see concern Q026),
--    button "Refresh" shows "Up to date" after a delay (status
--    behaviour reserved for the alert/status scenarios, F040),
--  The DOM is built client-side from Ada element objects; elements
--  are per-connection (a second connection would raise
--  Object_Already_Created on the package objects).
--  The runner kills this process at the end of the run.
--  ---------------------------------------------------------------------------

with Gnoga;
with Gnoga.Application.Multi_Connect;
with Gnoga.Gui.Base;
with Gnoga.Gui.Element.Common;
with Gnoga.Gui.View;
with Gnoga.Gui.Window;

procedure Witness_Gnoga is
   use Gnoga.Gui.View;

   Login_View : aliased Gnoga.Gui.Element.Common.DIV_Type;

   procedure On_Continue (Object : in out Gnoga.Gui.Base.Base_Type'Class) is
      pragma Unreferenced (Object);
   begin
      Login_View.Hidden (False);
   end On_Continue;

   procedure On_Connect
     (Main_Window : in out Gnoga.Gui.Window.Window_Type'Class;
      Connection  :        access
        Gnoga.Application.Multi_Connect.Connection_Holder_Type)
   is
      pragma Unreferenced (Connection);
      View     : Gnoga.Gui.View.View_Type;
      Welcome  : Gnoga.Gui.Element.Common.DIV_Type;
      Continue : Gnoga.Gui.Element.Common.Button_Type;
   begin
      View.Create (Main_Window);

      Welcome.Create (View);
      Welcome.Put_Line ("Hello World");

      Login_View.Create (View);
      Login_View.Hidden (True);
      Login_View.Put_Line ("Log in");

      Continue.Create (View, "Continue", "continue");
      Continue.On_Click_Handler (On_Continue'Unrestricted_Access);
   end On_Connect;

begin
   Gnoga.Application.Multi_Connect.Initialize
     (Event => On_Connect'Unrestricted_Access, Boot => "boot.html");
   Gnoga.Application.Title ("GuiVerb witness");
   Gnoga.Application.Multi_Connect.Message_Loop;
end Witness_Gnoga;
