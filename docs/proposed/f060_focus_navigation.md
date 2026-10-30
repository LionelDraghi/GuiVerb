# F060 — Focus and keyboard navigation <!-- omit from toc -->

Source: ARIA 1.2 (focus management practices); roadmap phase 1
Milestone: 2 — wider ARIA vocabulary (Web)

## Contents <!-- omit from toc -->
- [Need](#need)
- [Intended outcome](#intended-outcome)
- [Vocabulary introduced](#vocabulary-introduced)
- [ARIA grounding](#aria-grounding)
- [References](#references)
- [Acceptance criteria](#acceptance-criteria)
- [Executable scenarios](#executable-scenarios)
  - [Scenario: tab order](#scenario-tab-order)
- [Verification beyond bbt](#verification-beyond-bbt)
- [Design implications](#design-implications)
- [Open questions](#open-questions)
- [Finalization target](#finalization-target)

## Need

`has focus` exists since F030 for a single widget. Real dialogs move
focus (initial focus, Tab order, focus traps, composite widgets driven
by arrows). Scenarios must observe and assert this movement.

## Intended outcome

A scenario can follow focus across controls and assert keyboard
navigation behaviour.

## Vocabulary introduced

- `the focus is on the <name> <role>` (generalized form of F030);
- `When I press the key <key>`: single-key keyboard input, distinct
  from typing into a field (F035) and from a semantic press (F020);
- `the focus stays within the <name> dialog`: containment assertion.

## ARIA grounding

Focus is platform state, not an ARIA property; ARIA governs what
should be focusable and composite-widget patterns such as
`aria-activedescendant` (combobox, listbox). The backend observes
focus events where the platform provides them, polls otherwise.

## References

- WAI-ARIA 1.2, property [aria-activedescendant](https://www.w3.org/TR/wai-aria-1.2/#aria-activedescendant)
- ARIA Authoring Practices, [keyboard interaction](https://www.w3.org/WAI/ARIA/apg/practices/keyboard-interface/)

## Acceptance criteria

- Tab from `User` to `Password` is observable in the witness login
  dialog.
- A composite-widget page (listbox with `aria-activedescendant`) is
  navigable with arrow keys.

## Executable scenarios

### Scenario: tab order

- Given the login dialog is open
- When I press the key `Tab`
- Then the focus is on the `Password` textbox

## Verification beyond bbt

- None yet.

## Design implications

- First keyboard input: this is where the action-tier model (semantic
  vs system input) becomes observable, and where CI profiles start to
  differ (see `docs/dev/ci-strategy.md`).

## Open questions

- Q008, Q014.

## Finalization target

`docs/features/scenario_vocabulary.md`.
