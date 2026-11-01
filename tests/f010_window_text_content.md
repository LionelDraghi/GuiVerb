# F010 — Text content of a window

| Feature | Scenario in the feature page |
|---|---|
| F010 | Welcome text |

Executable test: the GuiVerb runner asserts the text content of the
witness window.

## Scenario: Welcome text

- When I run `bin/guiverb tests/scenarios/f010_window_text_content.md`
- Then the output contains `OK: the window contains`
- And I get no error
