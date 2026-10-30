# Reference GUI Scenarios <!-- omit from toc -->

## Contents <!-- omit from toc -->

- [Scenario: welcome interface](#scenario-welcome-interface)
- [Scenario: continue to login](#scenario-continue-to-login)
- [Scenario: validation failure](#scenario-validation-failure)
- [Scenario: asynchronous refresh](#scenario-asynchronous-refresh)

## Scenario: welcome interface

- When I run "myapp"
- Then a welcome window appears
- And the window contains "Hello World"
- And there is a button named "Continue"
- And the "Continue" button is enabled

## Scenario: continue to login

- Given the welcome window is open
- When I press the "Continue" button
- Then a login dialog eventually appears
- And the dialog contains a textbox named "User"
- And the dialog contains a password textbox named "Password"
- And the dialog contains a button named "Login"
- And the "User" textbox has focus

## Scenario: validation failure

- Given the login dialog is open
- When I press the "Login" button
- Then an alert named "User is required" eventually appears
- And the "User" textbox has focus

## Scenario: asynchronous refresh

- Given the application is open
- When I press the "Refresh" button
- Then a status message "Up to date" eventually appears
