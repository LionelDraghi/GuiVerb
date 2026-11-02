# F015 — Button by accessible name, with enabled state (witness application)

| Feature | Scenario in the feature page |
|---|---|
| F015 | Welcome button |

Executable scenario of `docs/proposed/f015_button_name_state.md`,
run with the GuiVerb runner:

```sh
bin/guiverb tests/scenarios/f015_button_name_state.md
```

- When I run `witness_web`
- Then a window appears
- And there is a button named `Continue`
- And the `Continue` button is enabled
