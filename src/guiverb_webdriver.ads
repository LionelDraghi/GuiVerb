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

   procedure Click (Session_Id : String; Element_Id : String);
   --  The press action on the Web backend (F020): the element's
   --  default action, injected as real input events; scenario
   --  vocabulary stays "press".

   function Dialog_Names (Session_Id : String) return String;
   --  The accessible names of the currently open dialogs (F025):
   --  native dialog elements that are open, plus role="dialog"
   --  elements; one name per line ("\u001f"-joined internally, line
   --  breaks inside a name preserved). Accessible name per accname:
   --  aria-label, or the text of the elements listed by
   --  aria-labelledby. Empty result when no dialog is open.

   function Field_Names
     (Session_Id : String; Password : Boolean) return String;
   --  The accessible names of the currently visible text fields (F030):
   --  Password = true selects input[type=password] fields; false
   --  selects textboxes: input[type=text], textarea, role="textbox".
   --  One name per line, same accname rules as the dialog lookups.
   --  Empty result when no field matches.

   function Focused_Name (Session_Id : String) return String;
   --  The accessible name of the focused element (F030): "" when no
   --  element has focus.

   procedure Delete_Session (Session_Id : String);

end Guiverb_WebDriver;
