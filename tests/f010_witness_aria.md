# F010 — Text content of a window (ARIA practices witness)

| Feature | Scenario in the feature page |
|---|---|
| F010 | Welcome text |

Executable test: the GuiVerb runner asserts the text content of the
ARIA practices witness window.

## Scenario: Welcome text of the ARIA practices witness

- When I run `bin/guiverb tests/scenarios/f010_witness_aria.md`
- Then the output contains `OK: the window contains`
- And I get no error
