# F025 — Dialog appearance, with bounded waiting

Source: `examples/reference-scenarios.md` (continue to login)
Milestone: 1 — minimal loop (Web)

## Need

GUI behaviour is asynchronous: a dialog appears after an action, not
instantaneously. The scenario language needs an explicit, bounded wait.

## Intended outcome

A scenario can assert that a dialog eventually appears, with the
waiting semantics explicit and bounded.

## Vocabulary introduced

- `Then a <name> dialog eventually appears`: role `dialog`, awaited
  within a bounded deadline;
- `alertdialog` is the same feature with the alert semantics of F040.

## ARIA grounding

Role: `dialog` (window role in the ARIA taxonomy), typically
role="dialog" or the native dialog element on the Web. `eventually`
is the GuiVerb waiting keyword: it introduces a deadline, it is not a
fixed sleep. Default duration and deadline sharing are open questions.

## References

- WAI-ARIA 1.2, roles [dialog](https://www.w3.org/TR/wai-aria-1.2/#dialog) and [alertdialog](https://www.w3.org/TR/wai-aria-1.2/#alertdialog)

## Acceptance criteria

- The "continue to login" reference scenario runs in full against the
  witness application.
- A dialog that never appears fails with the deadline in the
  diagnostic.

## Executable scenarios

### Scenario: continue to login

- Given the welcome window is open
- When I press the `Continue` button
- Then a login dialog eventually appears

## Verification beyond bbt

- None yet.

## Design implications

- Introduces time into the model: deadline, polling or event-driven
  wait, per-step vs per-scenario deadline (concerns Q013 to Q015).

## Open questions

- Q013, Q014, Q015.

## Finalization target

`docs/features/scenario_vocabulary.md`.
