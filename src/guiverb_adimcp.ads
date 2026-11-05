--  ---------------------------------------------------------------------------
--  GuiVerb (https://github.com/LionelDraghi/GuiVerb)
--  SPDX-License-Identifier: Apache-2.0
--  SPDX-FileCopyrightText: 2026, Lionel Draghi
--  ---------------------------------------------------------------------------

package Guiverb_AdiMCP is

   --  The Adi2 backend: launch the probe-enabled projection and
   --  observe and act on it over the Adi2 development bridge
   --  (Adi.MCP). The transport is file IPC, the bridge's own: a
   --  per-process session directory <temp>/adi_mcp/<PID>/ holding
   --  cmd_<id>.json request files, resp_<id>.json answers, and a
   --  "ready" sentinel rewritten while the application runs.
   --  Single flight per session, like any other client of the bridge.
   --
   --  Correlation policy (same minimal form as the GTK backend): the
   --  runner spawns the application binary directly, so the spawned
   --  process id IS the application's — and the bridge namespaces its
   --  session by that very id. No discovery, no guessing: a session
   --  directory that never appears names a probe-less build
   --  (validation/release profiles compile the documented no-op
   --  stub), not a missing window.
   --
   --  Mapping conventions (per backend, like the GTK chain's; the
   --  audit record that grounds them is
   --  docs/proposed/adi2_probe_audit.md):
   --  - Window naming: the bridge exposes no SDL title bar; a
   --    projection that wants a named window declares the title as
   --    its root widget's label — the one name-carrying channel the
   --    bridge serializes for a non-text widget (a box's text falls
   --    back to its declared label). The witness does this; a
   --    projection that does not fails the named check with the tree
   --    as evidence, never a silent pass.
   --  - Accessible names: the bridge carries one text field, no
   --    accessible-name channel (audit) — text-as-name for text
   --    bearing widgets: a button is what it displays.
   --  - Field naming: no relations; a field is named by its following
   --    sibling in tree order when that sibling resolves to a text
   --    input — the Adi2 counterpart of the GTK projection's
   --    Set_Mnemonic_Widget. A match path that lives in an overlay
   --    resolves through the bridge's overlay fallback; a root-tree
   --    widget with the same relative path would shadow it (recorded
   --    limitation; the witness's root has no such deep paths).
   --  - Focus: the serialized widget state ("state_focused") is the
   --    ground truth; the bridge's get_focus answers disagreed with
   --    the snapshots in the audit's experiment annex.
   --
   --  Intrusiveness (the phase 4 measurement): the runner carries
   --  none — the probe is a build-profile decision of the
   --  application, and the runner only speaks the bridge protocol.

   Launch_Failed : exception;
   --  No session directory appeared within the bounded deadline: the
   --  binary is missing, or was built without the probe.

   procedure Launch (Binary_Path : String);
   --  Spawn the application binary directly and wait for its probe
   --  session ("ready" sentinel) within a bounded deadline. A
   --  validation/release binary (no bridge) fails here: the scenario
   --  cannot run silently un-probed.

   function Window_Appears (Expected_Title : String := "") return Boolean;
   --  Poll the bridge for the application's root widget within a
   --  bounded deadline: a visible root answers the unnamed form
   --  (F005). The named form additionally requires the root's
   --  serialized text to be the expected title (window naming
   --  convention above).

   function Window_Contains (Expected : String) return Boolean;
   --  Poll for a widget whose text answers the bridge's non-exact
   --  find_by_text — case-insensitive substring — over the root tree
   --  and the overlays (F010: rendered text content; no accessible
   --  name channel to consult, audit).

   function Button_Named (Name : String) return Boolean;
   --  Poll for a button widget (find_by_type, then the button's
   --  serialized text — text-as-name) named Name (F015).

   function Button_Enabled (Name : String) return Boolean;
   --  The named button's serialized state: not state_disabled. False
   --  when the button is not found: the caller's diagnostic says
   --  disabled, and the button-existence check is the preceding
   --  scenario step (F015).

   function Press_Button (Name : String) return Boolean;
   --  Find the named button, then issue click_widget: the bridge
   --  synthesizes a pointer event at the widget centre through the
   --  ordinary dispatch pipeline — the semantic layer S003/F020
   --  protect, not a delivered input (F020).

   function Dialog_Appears (Expected_Name : String := "") return Boolean;
   --  Poll the tree for an overlay whose type is a dialog; the named
   --  form requires the dialog's serialized subtree to carry the
   --  expected title text — the dialog exposes its title as an inner
   --  label (F025).

   function Field_Named (Name : String; Password : Boolean := False)
                         return Boolean;
   --  Poll for a text field named Name, by the field-naming
   --  convention above (F030). Password is unreferenced: the bridge
   --  does not expose the password mode — the same Q022 position as
   --  the GTK chain (both Entry and PasswordEntry map to the text
   --  role), the password variant resolves through the same search.

   function Field_Focused (Name : String) return Boolean;
   --  The named field's serialized state is focused (F030; focus
   --  convention above).

   function Observed_Text return String;
   --  The last gathered root snapshot, for the diagnostic when a
   --  check failed.

   function Current_Tree return String;
   --  A fresh widget_tree answer, for a failed check's diagnostic.

   procedure Shutdown;
   --  Terminate the launched application. The bridge's quit command
   --  is not reliable across versions (the pinned commit implements
   --  `quit`, its own docs advertise `quit_app`), so the runner side
   --  terminates the process it spawned: one-less protocol cost, and
   --  an application that refuses to close cannot stall the suite.

end Guiverb_AdiMCP;
