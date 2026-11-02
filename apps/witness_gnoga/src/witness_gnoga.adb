--  GuiVerb (https://github.com/LionelDraghi/GuiVerb)
--  SPDX-License-Identifier: Apache-2.0
--  SPDX-FileCopyrightText: 2026, Lionel Draghi
--  ---------------------------------------------------------------------------
--  The reference application, Gnoga projection: a long-running Web
--  application (HTTP server + WebSocket), same reference behaviour as
--  the static Web witness (apps/witness/index.html):
--    document title "GuiVerb witness", text "Hello World",
--    button "Continue" opens the Log in view,
--    button "Refresh" shows "Up to date" after a delay (the status
--    behaviour used by the alert/status scenarios),
--  The DOM is built client-side from Ada element objects; elements
--  are per-connection (a second connection would raise
--  Object_Already_Created on the package objects).
--  The runner kills this process at the end of the run.
--  ---------------------------------------------------------------------------

with Gnoga;
with Gnoga.Application.Multi_Connect;
with Gnoga.Gui.Base;
with Gnoga.Gui.Element.Common;
with Gnoga.Gui.Element.Section;
with Gnoga.Gui.View;
with Gnoga.Gui.Window;

procedure Witness_Gnoga is
   use Gnoga.Gui.View;

   use Gnoga.Gui.Element.Section;

   Login_View : aliased Gnoga.Gui.Element.Common.DIV_Type;
   Status     : aliased Gnoga.Gui.Element.Common.DIV_Type;

   procedure On_Continue (Object : in out Gnoga.Gui.Base.Base_Type'Class) is
      pragma Unreferenced (Object);
   begin
      Login_View.Hidden (False);
   end On_Continue;

   task type Refresh_Task;

   task body Refresh_Task is
   begin
      delay 0.3;
      Status.Hidden (False);
   end Refresh_Task;
   type Refresh_Access is access Refresh_Task;

   procedure On_Refresh (Object : in out Gnoga.Gui.Base.Base_Type'Class) is
      pragma Unreferenced (Object);
      Task_Ref : constant Refresh_Access := new Refresh_Task;
      pragma Unreferenced (Task_Ref);
   begin
      Status.Hidden (True);
   end On_Refresh;

   procedure On_Connect
     (Main_Window : in out Gnoga.Gui.Window.Window_Type'Class;
      Connection  :        access
        Gnoga.Application.Multi_Connect.Connection_Holder_Type)
   is
      pragma Unreferenced (Connection);
      View     : Gnoga.Gui.View.View_Type;
      Welcome  : Gnoga.Gui.Element.Common.DIV_Type;
      Login    : Section_Type;
      Continue : Gnoga.Gui.Element.Common.Button_Type;
      Refresh  : Gnoga.Gui.Element.Common.Button_Type;
      Message  : Gnoga.Gui.Element.Common.DIV_Type;
   begin
      View.Create (Main_Window);

      Welcome.Create (View);
      Welcome.Put_Line ("Hello World");

      Login.Create (View, H2);
      Login.Put_Line ("Log in");
      Login_View.Create (View);
      Login_View.Hidden (True);

      Message.Create (View);
      Message.Put_Line ("Up to date");
      Status.Create (View);
      Status.Hidden (True);

      Continue.Create (View, "Continue", "continue");
      Continue.On_Click_Handler (On_Continue'Unrestricted_Access);
      Refresh.Create (View, "Refresh", "refresh");
      Refresh.On_Click_Handler (On_Refresh'Unrestricted_Access);
   end On_Connect;

begin
   Gnoga.Application.Multi_Connect.Initialize
     (Event => On_Connect'Unrestricted_Access, Boot => "boot.html");
   Gnoga.Application.Title ("GuiVerb witness");
   Gnoga.Application.Multi_Connect.Message_Loop;
end Witness_Gnoga;
