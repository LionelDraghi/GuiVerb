# F045 — Widget states <!-- omit from toc -->

Source: ARIA 1.2 states and properties; roadmap phase 1
Milestone: 2 — wider ARIA vocabulary (Web)

## Contents <!-- omit from toc -->
- [Need](#need)
- [Intended outcome](#intended-outcome)
- [Vocabulary introduced](#vocabulary-introduced)
- [ARIA grounding](#aria-grounding)
- [References](#references)
- [Acceptance criteria](#acceptance-criteria)
- [Executable scenarios](#executable-scenarios)
  - [Scenario: disclosure state](#scenario-disclosure-state)
- [Verification beyond bbt](#verification-beyond-bbt)
- [Design implications](#design-implications)
- [Open questions](#open-questions)
- [Finalization target](#finalization-target)

## Need

Beyond enabled/disabled, the state of a widget is what scenarios
assert: checked, expanded, selected, required, invalid. These are the
states of the ARIA ontology, and the natural second step after role
and name.

## Intended outcome

A scenario can assert the state of any widget, expressed in
user-visible terms.

## Vocabulary introduced

- `is checked` / `is unchecked` / `is partially checked`;
- `is pressed` / `is not pressed`;
- `is expanded` / `is collapsed`;
- `is selected` / `is not selected`;
- `is required`, `is invalid`.

## ARIA grounding

`aria-checked` (true/false/mixed), `aria-pressed`, `aria-expanded`,
`aria-selected`, `aria-required`, `aria-invalid`, `aria-disabled`
(already in F015). Each vocabulary entry maps to exactly one state
property; no attribute name appears in a scenario.

## References

- WAI-ARIA 1.2, states [aria-checked](https://www.w3.org/TR/wai-aria-1.2/#aria-checked), [aria-pressed](https://www.w3.org/TR/wai-aria-1.2/#aria-pressed), [aria-expanded](https://www.w3.org/TR/wai-aria-1.2/#aria-expanded), [aria-selected](https://www.w3.org/TR/wai-aria-1.2/#aria-selected), [aria-required](https://www.w3.org/TR/wai-aria-1.2/#aria-required), [aria-invalid](https://www.w3.org/TR/wai-aria-1.2/#aria-invalid)

## Acceptance criteria

- Each state assertion is expressible and testable on the witness
  application extended with a demo control, or on a second example
  page.

## Executable scenarios

### Scenario: disclosure state

- When I press the `Advanced` button
- Then the `Advanced` button is expanded
- And the `Server` textbox is visible

## Verification beyond bbt

- None yet.

## Design implications

- Fixes the boolean-vs-string model of state values in the canonical
  object schema (phase 1).

## Open questions

- None.

## Finalization target

`docs/features/scenario_vocabulary.md`.
