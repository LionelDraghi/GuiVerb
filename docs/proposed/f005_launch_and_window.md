# F005 — Launch and window observation <!-- omit from toc -->

Source: `examples/reference-scenarios.md` (welcome interface); roadmap phase 2
Milestone: 1 — minimal loop (Web)

## Contents <!-- omit from toc -->
- [Need](#need)
- [Intended outcome](#intended-outcome)
- [Vocabulary introduced](#vocabulary-introduced)
- [ARIA grounding](#aria-grounding)
- [References](#references)
- [Acceptance criteria](#acceptance-criteria)
- [Executable scenarios](#executable-scenarios)
  - [Scenario: launch](#scenario-launch)
- [Verification beyond bbt](#verification-beyond-bbt)
- [Design implications](#design-implications)
- [Open questions](#open-questions)
- [Finalization target](#finalization-target)


## Need

The smallest observable behaviour: launch the application under test
and observe that a window exists. No scenario can run without it.

## Intended outcome

A scenario can start the application and assert that a window appeared,
optionally by name.

## Vocabulary introduced

- `When I run <command>`: launch the application under test;
- `Then a window appears`: a top-level window exists;
- `Then a window named <name> appears`: named variant.

## ARIA grounding

ARIA has no role for a native top-level window on the Web: the root of
the accessibility tree is the document. `window` is therefore a GuiVerb
canonical concept, mapped per backend (Web: the page and its document;
GTK: the window/frame role). This is the concrete form of concerns
Q001 and Q002.

## References

- WAI-ARIA 1.2, abstract role [window](https://www.w3.org/TR/wai-aria-1.2/#window)

## Acceptance criteria

- The first steps of the "welcome interface" reference scenario run
  against the witness web application.
- A missing window produces a diagnostic, not a crash or a timeout
  without explanation.

## Executable scenarios

Not executable yet: the GuiVerb runner does not exist. Target syntax:

### Scenario: launch

- When I run `witness_web`
- Then a window appears

## Verification beyond bbt

- None: the scenario is the check once the runner exists.

## Design implications

- Defines the launch/observe boundary between the runner core and a
  backend (concern Q005).

## Open questions

- Q001, Q002.

## Finalization target

`docs/features/scenario_vocabulary.md`.
