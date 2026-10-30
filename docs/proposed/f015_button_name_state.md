# F015 — Button by accessible name, with enabled state

Source: `examples/reference-scenarios.md` (welcome interface)
Milestone: 1 — minimal loop (Web)

## Need

The first widget lookup: find a control by role and name, and assert
its enabled state.

## Intended outcome

A scenario can assert the presence of a button by its accessible name,
and that it is enabled or disabled.

## Vocabulary introduced

- `there is a button named <name>`;
- `the <name> button is enabled` / `is disabled`.

## ARIA grounding

- Role: `button`.
- Name: computed per the accname specification (element content or
  `aria-label`); the scenario never sees the attribute used.
- State: enabled is the absence of `aria-disabled="true"`; the
  vocabulary exposes the user-visible state, not the attribute.

## References

- WAI-ARIA 1.2, role [button](https://www.w3.org/TR/wai-aria-1.2/#button)
- WAI-ARIA 1.2, state [aria-disabled](https://www.w3.org/TR/wai-aria-1.2/#aria-disabled)

## Acceptance criteria

- `And there is a button named "Continue"` and
  `And the "Continue" button is enabled` run against the witness
  application.
- A missing button and a disabled button produce distinct diagnostics.

## Executable scenarios

### Scenario: welcome button

- When I run `witness-web`
- Then a window appears
- And there is a button named `Continue`
- And the `Continue` button is enabled

## Verification beyond bbt

- None yet.

## Design implications

- Fixes the lookup key: role + accessible name (concerns Q010 to Q012
  on articles, casing, and matching apply here).

## Open questions

- Q010, Q011, Q012.

## Finalization target

`docs/features/scenario_vocabulary.md`.
