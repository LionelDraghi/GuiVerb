# F010 — Text content of a window <!-- omit from toc -->

Source: `examples/reference-scenarios.md` (welcome interface)
Milestone: 1 — minimal loop (Web)

## Contents <!-- omit from toc -->
- [Need](#need)
- [Intended outcome](#intended-outcome)
- [Vocabulary introduced](#vocabulary-introduced)
- [ARIA grounding](#aria-grounding)
- [References](#references)
- [Acceptance criteria](#acceptance-criteria)
- [Executable scenarios](#executable-scenarios)
  - [Scenario: welcome text](#scenario-welcome-text)
- [Verification beyond bbt](#verification-beyond-bbt)
- [Design implications](#design-implications)
- [Open questions](#open-questions)
- [Finalization target](#finalization-target)

## Need

After launch, the first assertion on content: the window shows the
expected text.

## Intended outcome

A scenario can assert that a window contains a given text.

## Vocabulary introduced

- `Then the window contains <text>`: text content assertion, scoped to
  the window.

## ARIA grounding

Text content is not a role: it is the rendered text of the subtree,
distinct from the accessible name and description computed per the
accname specification. The backend reads the accessible text of the
document subtree; no DOM or CSS concept leaks into the scenario.

## References

- [Accessible Name and Description Computation (accname) 1.2](https://www.w3.org/TR/accname-1.2/) — name and description, distinct from text content

## Acceptance criteria

- `And the window contains "Hello World"` runs against the witness
  application.
- A missing text produces a diagnostic showing what text was found.

## Executable scenarios

### Scenario: welcome text

- When I run `witness_web`
- Then a window appears
- And the window contains `Hello World`

## Verification beyond bbt

- None yet.

## Design implications

- Distinguishes content text from accessible name: a control is found
  by name (F015), a text assertion reads content.

## Open questions

- None.

## Finalization target

`docs/features/scenario_vocabulary.md`.
