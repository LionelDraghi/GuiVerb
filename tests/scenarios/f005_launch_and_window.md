# F005 — Launch and window observation

| Feature | Scenario in the feature page |
|---|---|
| F005 | Launch |

Executable scenario of `docs/proposed/f005_launch_and_window.md`,
run with the GuiVerb runner (`make f005`). The application name is
stable: the runner resolves it in `apps/<name>/`, and `GUIVERB_APP`
overrides it (default `witness`), so one scenario file serves every
application and platform (e.g. `GUIVERB_APP=witness_gnoga`
`make check-gnoga`).

## Scenario: Launch and observe the witness window

- When I run `witness`
- Then a window appears
