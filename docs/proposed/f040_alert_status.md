# F040 — Alerts and status messages

Source: `examples/reference-scenarios.md` (validation failure, asynchronous refresh)
Milestone: 1 — minimal loop (Web)

## Need

Feedback to the user arrives asynchronously: an error alert after a
failed action, a status message after a refresh. Both are live-region
semantics, and both appear without being summoned by a further action.

## Intended outcome

A scenario can assert that an alert or a status message eventually
appears, with its text.

## Vocabulary introduced

- `an alert named <text> eventually appears`;
- `a status message <text> eventually appears`.

## ARIA grounding

- `alert`: role `alert`, assertive live region, appears without focus
  change;
- `status`: role `status`, polite live region;
- both rely on `aria-live` semantics: the appearance itself is the
  event, which makes the `eventually` waiting of F025 event-driven
  rather than polled, where the platform allows it.

## References

- WAI-ARIA 1.2, roles [alert](https://www.w3.org/TR/wai-aria-1.2/#alert) and [status](https://www.w3.org/TR/wai-aria-1.2/#status), property [aria-live](https://www.w3.org/TR/wai-aria-1.2/#aria-live)

## Acceptance criteria

- The "validation failure" and "asynchronous refresh" reference
  scenarios run in full against the witness application.
- With this feature, all four reference scenarios run on platform 1.

## Executable scenarios

### Scenario: validation failure

- Given the login dialog is open
- When I press the `Login` button
- Then an alert named `User is required` eventually appears
- And the `User` textbox has focus

### Scenario: asynchronous refresh

- Given the application is open
- When I press the `Refresh` button
- Then a status message `Up to date` eventually appears

## Verification beyond bbt

- None yet.

## Design implications

- Closes milestone 1: the four reference scenarios are the exit
  criterion.
- Live regions are the first event-driven observations: the backend
  contract must say whether appearance is observed as an event or
  detected by polling (concerns Q007, Q014).

## Open questions

- Q007, Q014.

## Finalization target

`docs/features/scenario_vocabulary.md`.
