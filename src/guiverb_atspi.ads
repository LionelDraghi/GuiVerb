--  ---------------------------------------------------------------------------
--  GuiVerb (https://github.com/LionelDraghi/GuiVerb)
--  SPDX-License-Identifier: Apache-2.0
--  SPDX-FileCopyrightText: 2026, Lionel Draghi
--  ---------------------------------------------------------------------------

package Guiverb_ATSPI is

   --  Minimal GTK/AT-SPI backend: launch the application wrapper and
   --  observe its windows over the accessibility bus. The bus side is
   --  libatspi, imported directly — no D-Bus programming here; libatspi
   --  connects to org.a11y.Bus by itself (no atspi_init in this
   --  libatspi: initialisation is lazy and automatic).
   --
   --  Correlation policy (minimal form): the launched wrapper execs
   --  the application, so its process id IS the application's, and
   --  every window it exposes carries the same process id.

   Launch_Failed : exception;

   procedure Launch (Binary_Path : String);
   --  Spawn the application binary directly (no wrapper: the
   --  application is its own launcher). The accessibility
   --  environment (GTK_A11Y) is the caller backend's business.

   function Window_Appears (Expected_Title : String := "") return Boolean;
   --  Poll the accessibility bus for a window of the launched
   --  application, within a bounded deadline. Empty Expected_Title
   --  accepts the first window found. Observed_Title returns the
   --  window title, for the diagnostic when False.

   function Observed_Title return String;

   --  The steps below resolve inside the observed window. Matching is
   --  by AT-SPI role and accessible name (exact); "enabled" is the
   --  user-visible state, mapped on GTK4 to STATE_SENSITIVE — GTK 4
   --  does not emit STATE_ENABLED (observed: every widget carries
   --  SENSITIVE only). Each of them polls the accessibility tree
   --  within the bounded harness deadline: a server-side tree or an
   --  application mid-build changes between polls.

   function Window_Contains (Expected : String) return Boolean;
   --  The window's rendered text content: the accessible names and
   --  Text-interface content of the window subtree (the GTK
   --  equivalent of the Web window's innerText).

   function Observed_Text return String;
   --  The last gathered window text, for the FAIL diagnostic.

   function Button_Named (Name : String) return Boolean;
   --  A push button of the window named Name exists.

   function Button_Enabled (Name : String) return Boolean;
   --  The named push button's user-visible enabled state — see the
   --  mapping note above.

   function Press_Button (Name : String) return Boolean;
   --  Invoke the named push button's first action (AT-SPI semantic
   --  action, not injected input).

   procedure Shutdown;
   --  Kill (and reap) the launched application.

end Guiverb_ATSPI;
