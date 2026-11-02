# Conformance matrix

Which feature is tested on which application and backend. Hand
maintained from the scenario runs; the automation is a later feature
(see `docs/proposed/reference_apps.md`, "Open questions").

Legend:
- **OK** — the scenario passes against this application/backend;
- **planned** — the feature exists as a proposal, not yet implemented
  on this backend;
- **n/a** — not applicable.

## Backend status

| Application | Projection | Backend | Role |
|---|---|---|---|
| `witness` (`apps/witness/`) | static HTML | Web (chromedriver) | reference application, platform 1 |
| `witness` (`apps/witness/`) | GTK4 sub-crate | GTK (AT-SPI) | platform 2, second projection of the same behaviours |
| `witness_gnoga` (`apps/witness_gnoga/`) | Gnoga server app | Web (chromedriver) | second web application: same suite, different DOM producer |

The suite targets the stable name `witness`; `GUIVERB_APP` selects
the instance: `make check-gtk` (GTK projection — red while the GTK
increments of F010-F020 are missing, the reported status is the
matrix's), `make check-gnoga` (Gnoga projection).

## Features

This is milestone 1 in progress; F025–F075 are proposals
(`docs/proposed/`).

| Feature | witness / Web | witness / GTK | witness_gnoga / Web |
|---|---|---|---|
| F005 Launch and window observation | OK | OK | OK |
| F010 Text content of a window | OK | OK | OK |
| F015 Button by accessible name | OK | OK | OK |
| F020 Press action | OK | OK | OK |
| F025 Dialog appearance | planned | planned | planned |
| F030 Text fields and focus | planned | planned | planned |
| F035 Text and value entry | planned | planned | planned |
| F040 Alerts and status messages | planned | planned | planned |

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
