# Design discussions <!-- omit from toc -->

This document records structural choices, alternatives, rationale, and
status. It does not duplicate behavioral specifications. An open
decision may be indexed as a concern when it blocks work or creates
material risk.

| Decision | Status | Date |
|---|---|---|
| Backend selection and launch | Discussing | 2026-10-30 |
| Web driver for the minimal loop | Accepted | 2026-10-30 |
| Application resolution and server applications | Accepted | 2026-11-02 |
| <title> | Discussing | YYYY-MM-DD |

Statuses: Discussing | Accepted | Rejected | Superseded.

## Contents <!-- omit from toc -->

- [Template for a new discussion](#template-for-a-new-discussion)
  - [Web driver for the minimal loop](#web-driver-for-the-minimal-loop)
- [Context](#context)
- [Options considered](#options-considered)
  - [WebDriver (chromedriver)](#webdriver-chromedriver)
  - [Playwright](#playwright)
- [Decision](#decision)
- [Rationale](#rationale)
- [Consequences](#consequences)

## Template for a new discussion

Copy this block for each new discussion, as a `###` section.

```markdown
### <title>

Status: Discussing
Date: YYYY-MM-DD
Related: <proposal, concern, issue, or feature>

## Context

<Forces and constraints that make a decision necessary.>

## Options considered

### Option A

- Benefits: ...
- Costs and risks: ...

### Option B

- Benefits: ...
- Costs and risks: ...

## Decision

<Leave open while Discussing.>

## Rationale

<Why this option was selected.>

## Consequences

- ...
```

### Web driver for the minimal loop

Status: Accepted
Date: 2026-10-30
Related: concern Q021, proposal F005, `docs/proposed/witness_app_web.md`

## Context

The minimal loop needs a complete chain with an explicit mapping:
runner, browser, and observation. Two candidates: the WebDriver
protocol via chromedriver, or Playwright.

## Options considered

### WebDriver (chromedriver)

- Benefits: plain HTTP + JSON over localhost, no framework, no
  dependency in the crate, the mapping is explicit at each call.
- Costs and risks: a minimal hand-written HTTP/JSON layer (currently
  in `src/guiverb_webdriver.adb`, deliberately small); chromedriver
  must be installed separately and match the browser major version.

### Playwright

- Benefits: richer waits, automatic browser management.
- Costs and risks: a driver protocol and a Node layer to operate;
  heavier than needed for the first observation steps.

## Decision

WebDriver via chromedriver, for the minimal loop. Q021 stays open:
this choice does not settle what the backend will use for waits,
downloads, and browser management at large.

## Rationale

The first milestone is about trust in the chain, not convenience:
each step of the mapping must be visible. Plain HTTP keeps the
backend auditable and the crate dependency-free.

## Consequences

- chromedriver must be on PATH, with a version matching the browser
  major (e.g. `npx @puppeteer/browsers install chromedriver@156`).
- The minimal HTTP/JSON layer is a known, deliberate debt: it grows
  only with the features actually implemented.

### Backend selection and launch

Status: Discussing
Date: 2026-10-30
Related: S001, F005, `docs/architecture.md` (logical backend contract)

## Context

The same scenario file must run against several GUIs (Web today, GTK4
tomorrow). The runner needs (1) a pluggable backend mechanism, (2) a
way to know which backend a run uses, (3) a way to bring up whatever
the backend needs (driver, browser, accessibility bus).

## Options considered

### Strategy pattern + CLI selection

- Benefits: the backend contract becomes a tagged type with
  dispatching primitives (Launch, Find, Observe, Act, Wait); the
  backend is chosen outside the script (`guiverb --backend=web …`),
  so CI replays the same file once per backend; the launch of the
  driver machinery stays owned by the backend, as F005 already does
  with chromedriver; scenarios stay technology-free (S001).
- Costs and risks: the backend abstraction must not be introduced
  before a second backend exists (premature); the CLI grows a flag
  and, later, profiles.

### Selection and launch inside the scenario (Given steps)

- Benefits: everything is visible in one file; bbt's "Given I run"
  model carries over directly.
- Costs and risks: "Given I use the web backend" or "Given I run
  `chromedriver`" reintroduce platform and tooling names into the
  scenario (S001 violation); the same script can no longer run
  unchanged on two GUIs; the backend loses the responsibility for its
  own chain, and the runner cannot diagnose a stalled launch it does
  not own.

## Decision

Open while Discussing. Working position: strategy pattern, CLI
selection, backend-owned launch; the scenario keeps only application
vocabulary. `Given I run` stays available for application
preconditions, as in bbt.

### Application resolution and server applications

Status: Accepted
Date: 2026-11-02
Related: concern Q023, proposal `docs/proposed/reference_apps.md`,
`apps/witness_gnoga/`

## Context

The suite's scenarios invoke a stable application name; the runner
resolves it. With a second reference application — witness_gnoga, a
long-running HTTP server tested by the Web backend — a run must (1)
select the application instance the suite targets, (2) launch a server
application whose DOM is built only after the browser socket
connects, and (3) clean it up.

## Options considered

### Wrapper inside the scenario

- Benefits: no runner change.
- Costs and risks: per-application wrappers for every user (the suite
  is not just the reference apps), and a scenario that depends on
  files outside `apps/`.

### Resolution by the runner, override by environment

- Benefits: the scenario stays `When I run <app>`; the runner walks up
  the directories to `apps/<name>/` and picks the projection per
  backend — Web: `index.html`, GTK: `bin/<name>`; `GUIVERB_APP`
  overrides the name, so `make check-gnoga` runs the same suite
  against another instance; a `serve` launcher beside the app makes a
  server application first-class: the runner spawns it, waits for the
  URL it reports, kills it with the rest of the chain.
- Costs and risks: one more launcher contract (`serve`) to document;
  observations must tolerate a DOM built after navigation, which the
  web checks now poll for within the harness deadline ('eventually'
  timing stays configuration, not scenario vocabulary).

## Decision

Resolution by the runner: `apps/<name>/` with per-backend
projections, `GUIVERB_APP` to override the instance, and `serve` for
server applications. No wrapper in the scenario path, and bbt-style
`Given I run` remains available for application preconditions.

## Consequences

- The second web reference application folds into the same suite
  (S001 unchanged: no new steps, no framework reference).
- `make check-gnoga` runs the shared suite against `witness_gnoga`
  (`apps/witness_gnoga/` below the application's README for its
  prerequisites and automation notes).
- The Web chain gained bounded-settle polling on every observation —
  the harness timing is a configuration default (deadline), reused by
  F025's `eventually` wording when that lands.
- The directory-walk rule near the root is fixed (it used to leave at
  `""` and raise `Name_Error` on elements found after the last
  candidate).
