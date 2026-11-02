# F015 — Button by accessible name, with enabled state

| Feature | Scenario in the feature page |
|---|---|
| F015 | Welcome button |

Executable test: the GuiVerb runner resolves a button by accessible
name and asserts its enabled state.

## Scenario: Welcome button

- When I run `bin/guiverb tests/scenarios/f015_button_name_state.md`
- Then the output contains `OK: there is a button named`
- And the output contains `button is enabled`
- And I get no error
