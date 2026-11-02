# F010 — Text content of a window

| Feature | Scenario in the feature page |
|---|---|
| F010 | Welcome text |

Executable scenario of `docs/proposed/f010_window_text_content.md`,
run with the GuiVerb runner (`make f010`); the wrapper `witness`
selects the application instance.

## Scenario: Welcome text

- When I run `witness`
- Then a window appears
- And the window contains `Hello World`
