# CI Strategy for GUI Backends

## Principle

“Headless” is not one universal execution mode. Each platform provides a different graphical-session model. The project therefore distinguishes:

1. **semantic backend tests**, which test canonical mapping and protocol behaviour without a real desktop when possible;
2. **hosted-runner smoke tests**, which run a small real GUI scenario on standard CI runners where reliable;
3. **interactive-session end-to-end tests**, which exercise focus, pointer, keyboard, drag-and-drop, IME, window activation, and screenshots in a real logged-in desktop session.

A backend capability report must describe the actual session and injection level used.

## Web

Use browser-native headless mode for the main cross-platform suite. Add a smaller headed-browser smoke suite when rendering, focus, native dialogs, or screenshots matter.

Expected CI profile:

- primary: GitHub-hosted Linux runner, browser headless;
- secondary: browser matrix on Linux, Windows, and macOS where useful;
- headed diagnostics: virtual display on Linux or a logged-in desktop runner on Windows/macOS.

Browser headless testing validates the Web backend, not native desktop accessibility stacks.

## Linux / GTK / AT-SPI

Use an isolated graphical session containing the display/compositor, D-Bus session, accessibility bus, application, and backend.

Candidate profiles:

- X11 compatibility profile using Xvfb;
- Wayland profile using an isolated compositor;
- semantic-action profile through AT-SPI;
- system-input profile when the compositor permits controlled injection.

AT-SPI conformance should not be reduced to screenshot testing: the semantic tree and events are the primary evidence.

## Windows

A Windows process running as a service may execute outside an interactive user desktop. Native GUI E2E therefore requires a runner operating in a logged-in interactive user session, not merely a background service context.

Proposed profiles:

- **hosted smoke profile:** determine experimentally which semantic UI Automation and window operations work on the selected GitHub-hosted image;
- **authoritative E2E profile:** self-hosted Windows VM or machine with a dedicated logged-in test user and the Actions runner started in that user session;
- **protocol/unit profile:** canonical-model and backend translation tests that do not require the desktop.

The authoritative profile should cover activation, focus, keyboard, pointer, drag-and-drop, screenshots, multiple windows, and DPI scaling. The machine should be reset or reprovisioned between runs where practical.

Do not describe this as “headless Windows”. Call it an **unattended interactive desktop session**.

Security requirements for a self-hosted GUI runner include repository trust controls, a dedicated low-privilege account, isolation from sensitive networks and user data, and controlled access to secrets.

## macOS / Darwin

Native AppKit and accessibility E2E require an Aqua/WindowServer session in which the application can become active and own the key window. A process-only runner without a logged-in GUI session is insufficient for tests involving activation, focus, first responder, pasteboard, IME, or pointer interaction.

Proposed profiles:

- **GitHub-hosted macOS smoke profile:** run a GUI-session probe first, then a minimal AppKit/accessibility test;
- **authoritative E2E profile:** dedicated self-hosted Mac with a logged-in Aqua session and the Actions runner launched in that user GUI domain;
- **protocol/unit profile:** canonical mapping and backend tests that do not require WindowServer interaction.

The authoritative profile should cover AX observation, activation, key-window and focus behaviour, keyboard and pointer input, drag-and-drop, screenshots, multiple displays/scaling where relevant, and permissions required by accessibility automation.

Do not call this strictly “headless macOS”. It is an **unattended logged-in Aqua session**.

## Proposed CI tiers

### Tier 1: every pull request

- parser and common protocol tests;
- canonical model and error taxonomy;
- backend mapping tests using fixtures or fake providers;
- Web backend in browser headless mode;
- Linux AT-SPI smoke test if the isolated session is stable enough.

### Tier 2: platform smoke matrix

- Linux GTK/AT-SPI in isolated X11 and/or Wayland session;
- Windows hosted-runner GUI-session probe and minimal native smoke test;
- macOS hosted-runner GUI-session probe and minimal native smoke test;
- Adi2 and raygui launch/snapshot/action smoke tests on supported platforms.

### Tier 3: authoritative native E2E

- self-hosted interactive Windows runner;
- self-hosted logged-in macOS runner;
- controlled Linux compositor session;
- system-input, focus, drag-and-drop, screenshots, IME, and window-management scenarios.

Tier 3 may run on protected branches, releases, or explicitly requested workflows rather than on every untrusted pull request.

## Backend conformance consequence

A passing scenario must record:

- operating system and session profile;
- observation provider;
- action provider;
- injection level;
- whether the run used a real interactive desktop, virtual display/compositor, browser headless mode, or a fake provider;
- any unsupported capability or skipped assertion.

This prevents a direct widget mutation or fake provider from being reported as equivalent to native system-input E2E.

## Open validation tasks

1. Create a small session probe for each OS.
2. Test the probes on current GitHub-hosted images.
3. Establish the smallest reliable self-hosted Windows interactive-session configuration.
4. Establish the smallest reliable self-hosted macOS Aqua-session configuration.
5. Define reset, isolation, artifact capture, and security policies for native GUI runners.
6. Decide which tests belong to each CI tier from measured reliability and risk.
