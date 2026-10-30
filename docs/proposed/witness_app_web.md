# Witness web application <!-- omit from toc -->

Source: roadmap phase 0 (reference application) and phase 2 (Web backend);
        `examples/reference-scenarios.md`
Milestone: 1 — minimal loop (Web)

## Contents <!-- omit from toc -->
- [Need](#need)
- [Intended outcome](#intended-outcome)
- [Acceptance criteria](#acceptance-criteria)
- [Scope](#scope)
- [Non-goals](#non-goals)
- [Verification beyond bbt](#verification-beyond-bbt)
- [Design implications](#design-implications)
- [Open questions](#open-questions)
- [Finalization target](#finalization-target)

## Need

The minimal test loop needs a target: a small application implementing
the reference scenarios, on platform 1 (Web). Without it, no feature
can be exercised end to end.

## Intended outcome

A dependency-free web application under `tests/apps/witness_web/`,
with correct ARIA semantics, that realizes all four reference
scenarios:

- a welcome view: heading `Hello World`, button `Continue`;
- a login dialog (role `dialog`) with a textbox `User`, a password
  field `Password`, a button `Login`;
- an alert `User is required` when `Login` is pressed with an empty
  `User`, and focus returned to the `User` field;
- a `Refresh` button and a status message `Up to date`.

Static HTML + a small script, no framework, no build step, served by
any static file server.

## Acceptance criteria

- Every step of the four reference scenarios has a concrete target in
  the application.
- Roles, names (per the accname computation), and states are explicit
  in the markup: no test-only ids, no CSS- or XPath-dependent hooks.
- The markup is clean against an accessibility checker (e.g. axe).

## Scope

- One page, one dialog, one alert, one status region.

## Non-goals

- No visual polish, no backend, no packaging.

## Verification beyond bbt

- Manual pass of the four scenarios with a browser and a screen-reader
  or accessibility inspector, once, at creation.

## Design implications

- The application is the reference for what "semantically sufficient
  markup" means for the Web backend.

## Open questions

- Native `<dialog>` element vs `role="dialog"`: decide at
  implementation, keep both legal for the backend.

## Finalization target

A section in `docs/features/` once the first feature page exists; the
application itself stays under `tests/apps/witness_web/`.
