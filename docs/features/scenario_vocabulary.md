# Scenario vocabulary <!-- omit from toc -->

The scenario vocabulary is the canonical, platform-agnostic behavioural
language GuiVerb scenarios are written in (S001), grounded in WAI-ARIA
1.2. Each feature owns the detail of the steps it introduces; this page
summarises, never duplicates.

Steps are listed in two chapters: **implemented** — parsed and executed
by the current runner, exercised by the shared suite in
`tests/scenarios/` — and **planned** — proposed in `docs/proposed/`,
not yet implemented, listed in their proposal's own wording.

## Contents <!-- omit from toc -->

- [Implemented](#implemented)
- [Planned](#planned)

## Implemented

Executable today against the reference applications (`apps/`). The
runner and the backends implementing them: `src/guiverb_scenario.*`,
`src/guiverb_webdriver.*` (Web), `src/guiverb_atspi.*` (GTK/AT-SPI).

| Step | Meaning | Feature |
|---|---|---|
| `When I run <app>` | launch the application under test: resolved in `apps/<app>/` — each backend picks its own projection (Web: `index.html`, or `serve` for a server application: the backend spawns it, waits for the URL it reports, and kills it; GTK: `bin/<app>`, run with `GTK_A11Y=atspi`) | F005 |
| `Then a window appears` | a top-level window exists | F005 |
| `Then a window named <name> appears` | named variant (window title on the Web backend) | F005 |
| `And the window contains <text>` | rendered text content of the window subtree | F010 |
| `And there is a button named <name>` | role + accessible name lookup | F015 |
| `And the <name> button is enabled` / `is disabled` | user-visible enabled state of the looked-up button | F015 |
| `When I press the <name> button` | semantic activation; the Web backend injects real input events | F020 |
| `Then a <name> dialog eventually appears` | role `dialog`, bounded wait — the harness deadline is configuration, the failure diagnostic carries it; `alertdialog` same feature | F025 |
| `the dialog contains a textbox named <name>` | text field lookup by accessible name (label or aria association) | F030 |
| `the dialog contains a password textbox named <name>` | protected field; same role as textbox on both backends (Q022) | F030 |
| `the <name> textbox has focus` | platform focus, not an ARIA concept | F030 |


Matching is exact on accessible name (element content or `aria-label`
on the Web backend); the articles, casing, and partial-matching
questions are open (Q010, Q011, Q012). The executable scenarios live
in `tests/scenarios/` — **one file per feature, never one per
application or platform**: the scenario invokes the stable application
name, and each backend launches its own projection of
`apps/<application>/`.
`make check` runs the suite directly with the runner and trusts its
exit status (S002: for GUI scenarios, the GuiVerb runner is the
executor). Each file carries a `## Scenario:` title, keeping it bbt
compatible.

Minimal runnable example (witness application):

- When I run `witness`
- Then a window appears
- And there is a button named `Continue`
- And the `Continue` button is enabled

## Planned

Not implemented; the exact wording lived in (or is owned by) the
proposal cited in the last column, which remains the authoritative
specification until Finalize.

Milestone 1 — minimal loop, remainder:

| Step | Meaning | Proposal |
|---|---|---|
| `When I type <text> into the <name> textbox` | text entry | F035 |
| `When I set the <name> slider to <value>` | value entry | F035 |
| `When I increment the <name> spinbutton` | value entry | F035 |
| `an alert named <text> eventually appears` | live-region alert | F040 |
| `a status message <text> eventually appears` | live-region status | F040 |

Milestone 2 — wider ARIA vocabulary:

| Step | Meaning | Proposal |
|---|---|---|
| `is checked` / `is unchecked` / `is partially checked` | widget states | F045 |
| `is pressed` / `is not pressed` | widget states | F045 |
| `is expanded` / `is collapsed` | widget states | F045 |
| `is selected` / `is not selected` | widget states | F045 |
| `is required`, `is invalid` | widget states | F045 |
| closed role set: `button`, `textbox`, `checkbox`, `radio`, `combobox`, … | frozen MVP role set, each with its states and actions | F050 |
| `heading` (with level), `list`/`listitem`, `table`/`row`/`cell`/`columnheader` | structure roles | F055 |
| `main`, `navigation`, `banner`, `contentinfo`, …; named `region` | landmarks | F055 |
| `in the <name> <role>` | scoping qualifier on existing assertions | F055 |
| `the focus is on the <name> <role>` | generalized focus assertion | F060 |
| `When I press the key <key>` | single-key input, distinct from typing (F035) and semantic press (F020) | F060 |
| `the focus stays within the <name> dialog` | focus containment | F060 |

Milestone 3 — beyond the reference scenarios:

| Step | Meaning | Proposal |
|---|---|---|
| `When I drag the <name> <role> to the <name> <role>` | semantic drag-and-drop | F065 |
| `When I drag the <name> <role> <distance> <unit> to the <direction>` | domain-unit variant (e.g. `1 cm to the left`) | F065 |
| `the snapshot of <target> is equal to <asset>` | visual assertion on a semantic region, gated (S003) | F070 |

No scenario vocabulary: F075 records the injection level per action as
a report and diagnostic concern, not a scenario step.
