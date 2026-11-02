# F005 — Launch and window observation

| Feature | Scenario in the feature page |
|---|---|
| F005 | Launch |

Executable scenario of `docs/proposed/f005_launch_and_window.md`,
run with the GuiVerb runner (`make f005`). The application name is
stable: the `witness` wrapper launches the environment and the
application instance selected by `GUIVERB_APP` (default
`witness_web`), so one scenario file serves every application and
platform.

## Scenario: Launch and observe the witness window

- When I run `witness`
- Then a window appears
