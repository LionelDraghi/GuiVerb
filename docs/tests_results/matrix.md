# Conformance matrix

Which feature is tested on which application and backend. Hand
maintained from the scenario runs; the automation is a later feature
(see `docs/proposed/reference_apps.md`, "Open questions").

Legend:
- **OK** — the scenario passes against this application/backend;
- **planned** — the feature exists as a proposal, not yet implemented
  on this backend;
- **out of probe scope** — the Adi2 chain refuses the step before any
  launch (`FAIL: feature out of the Adi2 probe scope`): the structural
  refusal is the red, not a missing check;
- **n/a** — not applicable.

## Backend status

| Application | Projection | Backend | Role |
|---|---|---|---|
| `witness` (`apps/witness/`) | static HTML | Web (chromedriver) | reference application, platform 1 |
| `witness` (`apps/witness/`) | GTK4 sub-crate | GTK (AT-SPI) | platform 2, second projection of the same behaviours |
| `witness_gnoga` (`apps/witness_gnoga/`) | Gnoga server app | Web (chromedriver) | second web application: same suite, different DOM producer |
| `witness_adi2` (`apps/witness_adi2/`) | Adi2 sub-crate (Adi2 pinned at the audited commit) | Adi2 probe (file IPC, `Adi.MCP`) | platform 3, intrusive chain: observe the retained widget tree through the development bridge (`docs/proposed/adi2_probe_audit.md`) |

The suite targets the stable name `witness`; `GUIVERB_APP` selects
the instance: `make check-gtk` (GTK projection — red while the GTK
increments of F010-F020 are missing, the reported status is the
matrix's), `make check-gnoga` (Gnoga projection),
`make check-adi2` (Adi2 probe projection — window observation only,
the probe session's current scope; the Adi2 backend refuses any
scenario carrying later features before launching the application).

## Features

This is milestone 1 in progress; F025–F075 are proposals
(`docs/proposed/`).

| Feature | witness / Web | witness / GTK | witness_gnoga / Web | witness_adi2 / Adi2 probe |
|---|---|---|---|---|
| F005 Launch and window observation | OK | OK | OK | OK (unnamed); named windows: out of probe scope — the bridge exposes no window title (Q019) |
| F010 Text content of a window | OK | OK | OK | out of probe scope (tree carries text, no bridge command yet written for it) |
| F015 Button by accessible name | OK | OK | OK | out of probe scope (no canonical role mapping yet) |
| F020 Press action | OK | OK | OK | out of probe scope (`click_widget` exists, not wired yet) |
| F025 Dialog appearance | OK | OK | planned (Q026) | out of probe scope (overlays in the tree, not wired yet) |
| F030 Text fields and focus | OK | OK | planned (Q026) | out of probe scope |
| F035 Text and value entry | planned | planned | planned | out of probe scope (`set_text` is injection level 4 — F075 decides its fate) |
| F040 Alerts and status messages | planned | planned | planned | out of probe scope |

Notes for the Adi2 column, from the audit and the F005 integration
run (2026-11):

- The runner carries no intrusiveness: the probe is a build-profile
  decision of the application
  (`apps/witness_adi2/alire.toml`, `[build-profiles]`
  `adi2 = "development"`); the same source builds and runs without the
  session directory on any other profile (measured against the audit
  record).
- A probe-less build (validation/release) fails at launch with a
  diagnostic naming the missing probe session — not a silent,
  unprobed success.
- The bridge exposes no window title, so `Then a window named
  <name> appears` has no ground truth on this backend; the runner
  surfaces the refusal as the check's failure (no silent fallback).
- Bridge protocol divergences observed at the pinned commit are
  recorded in the audit record's experiment annex
  (`quit` vs `quit_app`; overlay path spellings; snapshot vs
  `get_focus` focus disagreement).

Notes:

- On the GTK chain, `make check-gtk` is the runnable status: green as
  of F020; it goes red again per-backend as features land.
- GTK row mappings (observations, see the design discussions): window
  text content = accessible names gathered over the window subtree
  (GTK 4 labels carry their text as accessible name; the AT-SPI Text
  interface is unused today); enabled state = STATE_SENSITIVE —
  GTK 4 never emits STATE_ENABLED; press = the AT-SPI semantic action
  (`click`, `do_action(0)`), not injected input.
- The application node still registers as "Unnamed" (Q024); the
  backend correlates by process id.
- The Gnoga app reproduces the same reference behaviours as the static
  witness (`apps/witness/`); its DOM is built client-side from a
  long-running server — the backend spawns, waits, navigates, and
  kills it (`apps/witness_gnoga/README.md`).
- GtkAda4 notes and the AT-SPI observation chain are recorded in
  `docs/dev/design_discussions.md` and Q024 (`docs/dev/concerns.md`).
