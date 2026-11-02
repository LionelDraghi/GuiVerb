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

   procedure Shutdown;
   --  Kill (and reap) the launched application.

end Guiverb_ATSPI;
