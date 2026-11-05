# F030 — Text fields and focus

| Feature | Scenario in the feature page |
|---|---|
| F030 | Login fields |

Executable scenario of `docs/proposed/f030_text_fields_focus.md`,
run with the GuiVerb runner (`make f030`). The login dialog exposes
a text field, a password field, and the platform focus; the field
naming for password fields stays open (Q022).

## Scenario: Login fields

- When I run `witness`
- When I press the `Continue` button
- And the dialog contains a textbox named `User`
- And the dialog contains a password textbox named `Password`
- And the `User` textbox has focus
