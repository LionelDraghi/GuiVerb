# F020 — Press action on a control

| Feature | Scenario in the feature page |
|---|---|
| F020 | Continue to login (excerpt) |

Executable scenario of `docs/proposed/f020_press_action.md`, run with
the GuiVerb runner (`make f020`); the wrapper `witness` selects the
application instance. Pressing `Continue` opens the login view, and
the post-press assertion runs after the action.

## Scenario: Continue to login (excerpt)

- When I run `witness`
- When I press the `Continue` button
- And the window contains `Log in`
