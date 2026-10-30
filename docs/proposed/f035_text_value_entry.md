# F035 — Text and value entry <!-- omit from toc -->

Source: `docs/proposed/candidate-features.md` (calculator: semantic numeric
        entry); ARIA 1.2 value roles
Milestone: 1 — minimal loop (Web)

## Contents <!-- omit from toc -->
- [Need](#need)
- [Intended outcome](#intended-outcome)
- [Vocabulary introduced](#vocabulary-introduced)
- [ARIA grounding](#aria-grounding)
- [References](#references)
- [Acceptance criteria](#acceptance-criteria)
- [Executable scenarios](#executable-scenarios)
  - [Scenario: calculator entry (candidate, to settle)](#scenario-calculator-entry-candidate-to-settle)
- [Verification beyond bbt](#verification-beyond-bbt)
- [Design implications](#design-implications)
- [Open questions](#open-questions)
- [Finalization target](#finalization-target)

## Need

Observing fields is not enough: scenarios must enter text and values.
The calculator candidate adds semantic numeric entry; sliders and
spinbuttons add valued widgets.

## Intended outcome

A scenario can type text into a field and set or step a value.

## Vocabulary introduced

- `When I type <text> into the <name> textbox`;
- `When I set the <name> slider to <value>`;
- `When I increment the <name> spinbutton`.

## ARIA grounding

Typing targets role `textbox`; values are `aria-valuenow`,
`aria-valuemin`, `aria-valuemax` on `slider` and `spinbutton`. Numeric
entry stays semantic: the scenario states a value, never key sequences
(the calculator candidate explicitly wants semantic numeric entry, and
the `2 + 3 = 6` oddity in candidate-features must be resolved before
that scenario becomes a conformance test).

## References

- WAI-ARIA 1.2, property [aria-valuenow](https://www.w3.org/TR/wai-aria-1.2/#aria-valuenow); roles [slider](https://www.w3.org/TR/wai-aria-1.2/#slider) and [spinbutton](https://www.w3.org/TR/wai-aria-1.2/#spinbutton)

## Acceptance criteria

- Typing into `User` then pressing `Login` drives the witness
  application through a successful login path.
- A valued-widget demo page accepts set/increment and reflects the
  value in assertions.

## Executable scenarios

### Scenario: calculator entry (candidate, to settle)

- Given the display is `0`
- When I enter `2`
- And I press `+`
- And I enter `3`
- Then the display is `5`

## Verification beyond bbt

- None yet.

## Design implications

- Value typing raises the text-encoding question (UTF-8, IME) for the
  protocol (concern Q018).

## Open questions

- Q018.

## Finalization target

`docs/features/scenario_vocabulary.md`.
