# F020 — Press action on a control <!-- omit from toc -->

Source: `examples/reference-scenarios.md` (continue to login)
Milestone: 1 — minimal loop (Web)

## Contents <!-- omit from toc -->
- [Need](#need)
- [Intended outcome](#intended-outcome)
- [Vocabulary introduced](#vocabulary-introduced)
- [ARIA grounding](#aria-grounding)
- [References](#references)
- [Acceptance criteria](#acceptance-criteria)
- [Executable scenarios](#executable-scenarios)
  - [Scenario: continue to login (excerpt)](#scenario-continue-to-login-excerpt)
- [Verification beyond bbt](#verification-beyond-bbt)
- [Design implications](#design-implications)
- [Open questions](#open-questions)
- [Finalization target](#finalization-target)

## Need

The first action: from observation to acting on the application.
Without one semantic action, nothing can be driven.

## Intended outcome

A scenario can activate a control by role and name, without any
coordinate, selector, or input-device concept.

## Vocabulary introduced

- `When I press the <name> button`: semantic activation of a button.

## ARIA grounding

ARIA declares semantics, not actions; actions live in the platform
layer. The vocabulary keeps the user's verb (`press`); each backend
maps it to its native activation (Web: the element's default action;
GTK/AT-SPI: the DoAction interface; UIA: Invoke). The distinction with
a device-level `click` is kept for a later feature (candidate
features, press vs click).

## References

- [Core Accessibility API Mappings 1.2](https://www.w3.org/TR/core-aam-1.2/) — how platform APIs expose actions; ARIA itself declares no actions

## Acceptance criteria

- Pressing `Continue` in the witness application opens the login view.
- Pressing a missing control is a diagnostic, not a crash.

## Executable scenarios

### Scenario: continue to login (excerpt)

- Given the welcome window is open
- When I press the `Continue` button
- Then a login dialog eventually appears

## Verification beyond bbt

- None yet.

## Design implications

- First entry in the action tier model (semantic action vs system
  input) that the architecture and the CI strategy rely on.

## Open questions

- Q008 (automatic fallback between action levels).

## Finalization target

`docs/features/scenario_vocabulary.md`.
