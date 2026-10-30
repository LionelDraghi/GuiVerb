# F030 — Text fields and focus <!-- omit from toc -->

Source: `examples/reference-scenarios.md` (continue to login, validation failure)
Milestone: 1 — minimal loop (Web)

## Contents <!-- omit from toc -->
- [Need](#need)
- [Intended outcome](#intended-outcome)
- [Vocabulary introduced](#vocabulary-introduced)
- [ARIA grounding](#aria-grounding)
- [References](#references)
- [Acceptance criteria](#acceptance-criteria)
- [Executable scenarios](#executable-scenarios)
  - [Scenario: login fields](#scenario-login-fields)
- [Verification beyond bbt](#verification-beyond-bbt)
- [Design implications](#design-implications)
- [Open questions](#open-questions)
- [Finalization target](#finalization-target)

## Need

Forms are the second most basic GUI pattern: text entry fields, and
the focus that says where the next input goes.

## Intended outcome

A scenario can assert the presence of a text field by name, distinguish
a password field, and check which control has focus.

## Vocabulary introduced

- `the dialog contains a textbox named <name>`;
- `a password textbox named <name>` (naming under discussion, see
  below);
- `the <name> textbox has focus`.

## ARIA grounding

- Role: `textbox`; a multiline field is the same role with
  `aria-multiline` — one role, one vocabulary entry.
- Password: there is no password role in ARIA; a password field is
  exposed as a text field with a protected state at the accessibility
  API level. The GuiVerb vocabulary must decide how to name it
  (new concern Q022).
- Focus is not an ARIA concept: it comes from the platform focus state
  and events.

## References

- WAI-ARIA 1.2, role [textbox](https://www.w3.org/TR/wai-aria-1.2/#textbox) and property [aria-multiline](https://www.w3.org/TR/wai-aria-1.2/#aria-multiline)

## Acceptance criteria

- The "continue to login" reference scenario runs in full, including
  the three field assertions and the focus check.

## Executable scenarios

### Scenario: login fields

- Given the login dialog is open
- Then the dialog contains a textbox named `User`
- And the dialog contains a password textbox named `Password`
- And the `User` textbox has focus

## Verification beyond bbt

- None yet.

## Design implications

- First use of a state that changes over time without an action
  (focus): the observation model must distinguish static lookup from
  tracked state.

## Open questions

- Q022 (password field naming).

## Finalization target

`docs/features/scenario_vocabulary.md`.
