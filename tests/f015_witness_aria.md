# F015 — Button by accessible name, with enabled state (ARIA practices witness)

| Feature | Scenario in the feature page |
|---|---|
| F015 | Welcome button |

Executable test: the GuiVerb runner resolves the `Details` button of
the ARIA practices witness and asserts its enabled state.

## Scenario: Welcome button of the ARIA practices witness

- When I run `bin/guiverb tests/scenarios/f015_witness_aria.md`
- Then the output contains `OK: there is a button named`
- And the output contains `button is enabled`
- And I get no error
