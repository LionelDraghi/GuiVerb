# F050 — MVP widget role set <!-- omit from toc -->

Source: ARIA 1.2 widget role taxonomy; roadmap phase 1 ("freeze the MVP
        vocabulary subset")
Milestone: 2 — wider ARIA vocabulary (Web)

## Contents <!-- omit from toc -->
- [Need](#need)
- [Intended outcome](#intended-outcome)
- [Proposed MVP set](#proposed-mvp-set)
- [References](#references)
- [Acceptance criteria](#acceptance-criteria)
- [Executable scenarios](#executable-scenarios)
- [Verification beyond bbt](#verification-beyond-bbt)
- [Design implications](#design-implications)
- [Open questions](#open-questions)
- [Finalization target](#finalization-target)

## Need

The MVP vocabulary must be an explicit, frozen subset of the ARIA
widget roles, not an open-ended "any role works". This feature
performs that freeze.

## Intended outcome

A documented, closed set of widget roles supported at MVP, each with
its name lookup, its states (F045), and its actions (F020, F035).

## Proposed MVP set

| Role | States | Actions |
|---|---|---|
| `button` | enabled, pressed | press |
| `textbox` | enabled, required, invalid, readonly, multiline | type into |
| `checkbox` | checked (incl. mixed) | toggle/check/uncheck |
| `radio` (+ `radiogroup`) | checked, selected | select |
| `combobox` | expanded, collapsed | open, select option |
| `listbox` / `option` | selected | select |
| `slider` | value, orientation | set value |
| `spinbutton` | value | increment, decrement, set value |
| `tab` / `tabpanel` | selected | select tab |

Everything else (tree, grid of widgets, menu bar, and so on) is
explicitly out of the MVP and listed as future work.

## References

- WAI-ARIA 1.2, [widget roles](https://www.w3.org/TR/wai-aria-1.2/#widget_roles) — the taxonomy the MVP set is drawn from

## Acceptance criteria

- The set is frozen in the specifications, one line per role, with the
  supported states and actions.
- A scenario using an out-of-set role fails with a clear
  "not in the MVP vocabulary" diagnostic.

## Executable scenarios

Not executable as such: this is a vocabulary freeze. Each role gets
its acceptance scenario when implemented.

## Verification beyond bbt

- None yet.

## Design implications

- Directly implements roadmap phase 1, "freeze the MVP vocabulary
  subset".
- The set is backend-independent: each backend declares which roles it
  supports (capability report).

## Open questions

- Q003 (which ARIA relations join the MVP).

## Finalization target

`docs/features/scenario_vocabulary.md`, section "MVP widget roles".
