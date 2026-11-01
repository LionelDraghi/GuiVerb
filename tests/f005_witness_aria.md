# F005 — Launch and window observation (ARIA practices witness)

| Feature | Scenario in the feature page |
|---|---|
| F005 | Launch |

Executable test: the GuiVerb runner launches the second reference
application and observes its window, by name.

## Scenario: Launch and observe the ARIA practices witness

- When I run `bin/guiverb tests/scenarios/f005_witness_aria.md`
- Then the output contains `OK: a window appears`
- And I get no error
