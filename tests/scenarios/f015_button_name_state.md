# F015 — Button by accessible name, with enabled state

| Feature | Scenario in the feature page |
|---|---|
| F015 | Welcome button |

Executable scenario of `docs/proposed/f015_button_name_state.md`,
run with the GuiVerb runner (`make f015`); the wrapper `witness`
selects the application instance.

## Scenario: Welcome button

- When I run `witness`
- And there is a button named `Continue`
- And the `Continue` button is enabled
