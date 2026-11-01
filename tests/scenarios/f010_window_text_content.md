# F010 — Text content of a window (witness application)

| Feature | Scenario in the feature page |
|---|---|
| F010 | Welcome text |

Executable scenario of `docs/proposed/f010_window_text_content.md`,
run with the GuiVerb runner:

```sh
bin/guiverb tests/scenarios/f010_window_text_content.md
```

- When I run `witness_web`
- Then a window appears
- And the window contains `Hello World`
