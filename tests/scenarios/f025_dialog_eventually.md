# F025 — Dialog appearance, with bounded waiting

| Feature | Scenario in the feature page |
|---|---|
| F025 | Continue to login (dialog eventually) |

Executable scenario of `docs/proposed/f025_dialog_eventually.md`,
run with the GuiVerb runner (`make f025`). The dialog waits within
the harness deadline: `eventually` is the explicit bounded-wait
keyword; a dialog that never appears fails with the deadline in the
diagnostic. The login view opens on the press of `Continue`.

## Scenario: Continue to login

- When I run `witness`
- Then a window named `GuiVerb witness` appears
- And there is a button named `Continue`
- When I press the `Continue` button
- Then a `Log in` dialog eventually appears
