# F015 — Button by accessible name, with enabled state (ARIA practices witness)

| Feature | Scenario in the feature page |
|---|---|
| F015 | Welcome button |

Executable scenario of `docs/proposed/f015_button_name_state.md`
against the second reference application:

```sh
bin/guiverb tests/scenarios/f015_witness_aria.md
```

- When I run `witness_aria`
- Then a window appears
- And there is a button named `Details`
- And the `Details` button is enabled
