--  ---------------------------------------------------------------------------
--  GuiVerb (https://github.com/LionelDraghi/GuiVerb)
--  SPDX-License-Identifier: Apache-2.0
--  SPDX-FileCopyrightText: 2026, Lionel Draghi
--  ---------------------------------------------------------------------------

package Guiverb_WebDriver is

   --  Minimal WebDriver (W3C standard) client, for the Web backend.
   --  Each call is one HTTP request to the local driver; the driver
   --  process itself is managed by the caller.

   Driver_Unreachable : exception;
   Request_Failed     : exception;

   Driver_Port : constant := 9515;

   function Ready return Boolean;
   --  True when the driver answers GET /status with ready = true.

   function New_Session (Headed : Boolean := False) return String;
   --  Chromium session; headless unless Headed is true. Returns the
   --  session id.

   procedure Navigate (Session_Id : String; URL : String);

   function Title (Session_Id : String) return String;

   function Text (Session_Id : String) return String;
   --  The rendered text of the window subtree (F010). On the Web
   --  backend: the text of the document body; how the body is located
   --  stays backend-private.

   function Find
     (Session_Id : String; Role, Name : String) return String;
   --  Resolve role + accessible name to an element reference (F015),
   --  or "" when no element matches. The role+name to locator mapping
   --  stays backend-private; only the button role is mapped for now.

   function Enabled (Session_Id : String; Element_Id : String) return Boolean;
   --  The enabled state of the element: user-visible state, not an
   --  attribute value (F015).

   procedure Delete_Session (Session_Id : String);

end Guiverb_WebDriver;
