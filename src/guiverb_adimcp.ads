--  ---------------------------------------------------------------------------
--  GuiVerb (https://github.com/LionelDraghi/GuiVerb)
--  SPDX-License-Identifier: Apache-2.0
--  SPDX-FileCopyrightText: 2026, Lionel Draghi
--  ---------------------------------------------------------------------------

package Guiverb_AdiMCP is

   --  Minimal Adi2 backend: launch the probe-enabled projection and
   --  observe its window over the Adi2 development bridge (Adi.MCP).
   --  The transport is file IPC, the bridge's own: a per-process
   --  session directory <temp>/adi_mcp/<PID>/ holding cmd_<id>.json
   --  request files, resp_<id>.json answers, and a "ready" sentinel
   --  rewritten while the application runs. Single flight per
   --  session, like any other client of the bridge.
   --
   --  Correlation policy (same minimal form as the GTK backend): the
   --  runner spawns the application binary directly, so the spawned
   --  process id IS the application's — and the bridge namespaces its
   --  session by that very id. No discovery, no guessing: a session
   --  directory that never appears names a probe-less build
   --  (validation/release profiles compile the documented no-op
   --  stub), not a missing window.
   --
   --  Intrusiveness (the phase 4 measurement, recorded in
   --  docs/proposed/adi2_probe_audit.md): the runner carries none —
   --  the probe is a build-profile decision of the application, and
   --  the runner only speaks the bridge protocol.

   Launch_Failed : exception;
   --  No session directory appeared within the bounded deadline: the
   --  binary is missing, or was built without the probe.

   Probe_Unsupported : exception;
   --  The requested observation has no equivalent on this bridge;
   --  surfaced as a diagnostic, never silently degraded (the
   --  scenario's failure is the conformance matrix status).

   procedure Launch (Binary_Path : String);
   --  Spawn the application binary directly and wait for its probe
   --  session ("ready" sentinel) within a bounded deadline. A
   --  validation/release binary (no bridge) fails here: the scenario
   --  cannot run silently un-probed.

   function Window_Appears (Expected_Title : String := "") return Boolean;
   --  Poll the bridge for the application's root widget within a
   --  bounded deadline: a read-back root snapshot with a visible
   --  root means the window exists. Empty Expected_Title is the F005
   --  scenario's form. A non-empty expectation raises
   --  Probe_Unsupported: the bridge exposes no window title (the
   --  root of its tree is a box widget), so a named-window check has
   --  no ground truth to consult — the caller carries the diagnostic.

   function Observed_Text return String;
   --  The last gathered root snapshot (short form), for the
   --  diagnostic when Window_Appears returned False.

   procedure Shutdown;
   --  Terminate the launched application. The bridge's quit command
   --  is not reliable across versions (the pinned commit implements
   --  `quit`, its own docs advertise `quit_app`), so the runner side
   --  terminates the process it spawned: one-less protocol cost, and
   --  an application that refuses to close cannot stall the suite.

end Guiverb_AdiMCP;
