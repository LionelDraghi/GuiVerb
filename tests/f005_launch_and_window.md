# F005 — Launch and window observation

Executable test of the first step of the minimal loop: the GuiVerb
runner launches the witness web application and observes its window.

## Scenario: Launch and observe the witness window

- When I run `bin/guiverb tests/scenarios/f005_launch_and_window.md`
- Then the output contains `OK: a window appears`
- And I get no error
