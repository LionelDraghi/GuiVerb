# F010 — Text content of a window (ARIA practices witness)

| Feature | Scenario in the feature page |
|---|---|
| F010 | Welcome text |

Executable scenario of `docs/proposed/f010_window_text_content.md`
against the second reference application:

```sh
bin/guiverb tests/scenarios/f010_witness_aria.md
```

- When I run `witness_aria`
- Then a window appears
- And the window contains `ARIA witness`
