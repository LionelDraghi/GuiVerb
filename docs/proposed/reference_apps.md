# Reference applications and the conformance matrix <!-- omit from toc -->

Source: discussion with the owner, 2026-10-30 — one application per
feature would not scale; the project's goal is a platform-agnostic
scenario suite, so the test targets must be organised around a small
set of shared applications.

## Contents <!-- omit from toc -->
- [Need](#need)
- [Intended outcome](#intended-outcome)
- [Scope](#scope)
- [Non-goals](#non-goals)
- [Acceptance criteria](#acceptance-criteria)
- [Specification](#specification)
  - [One shared scenario suite](#one-shared-scenario-suite)
  - [Scenario-to-feature reference](#scenario-to-feature-reference)
  - [Application set](#application-set)
  - [Layout and builds](#layout-and-builds)
- [Executable scenarios](#executable-scenarios)
  - [Scenario: the shared suite still runs after the reorganisation](#scenario-the-shared-suite-still-runs-after-the-reorganisation)
- [Verification beyond bbt](#verification-beyond-bbt)
- [Design implications](#design-implications)
- [Open questions](#open-questions)
- [Finalization target](#finalization-target)

## Need

One application per feature does not scale: features are numerous
(`F005`–`F075`) and applications are costly to write and maintain.
What the project actually needs is an answer to one question: *which
requirement is tested on which platform?* That question has an
app × platform shape, not a feature-per-app shape.

A small set of reference applications, each covering several
requirements, is cheaper to maintain and makes the platform matrix
meaningful: the same scenario suite runs against every application,
on every platform, and the resulting matrix shows conformance per
platform.

## Intended outcome

A small number of reference applications under `apps/`, each carrying
its build machinery, together with a single shared scenario suite that
covers the features. Every scenario references the features it
exercises, so a requirement × platform conformance matrix can be
derived.

## Scope

- Move the witness web application from `tests/apps/witness_web/` to
  `apps/witness_web/`.
- Directory layout for reference applications: `apps/<app>/`, with the
  application sources and a `builds/` subdirectory.
- Scenario header convention: each scenario file opens with a
  feature/scenario table linking it to the features it exercises.
- Selection of the initial application set (see Specification).

## Non-goals

- No binary artefacts committed: `builds/` holds build recipes, not
  results.
- No matrix-generation tool in this change: the matrix is derivable
  from the scenario headers; its automation is a later feature.
- No separate feature files under `docs/features/` beyond the
  vocabulary summary (`docs/features/scenario_vocabulary.md`, which
  gathers implemented and planned steps with pointers to the
  proposals): the feature proposals under `docs/proposed/` remain the
  detailed specification.
- Second application scenarios exercise only the executable vocabulary
  (F005, F010) at creation; the milestone-2 scenarios (states F045,
  structure F055, focus F060) follow when their features are
  implemented.

## Acceptance criteria

- The witness web application lives under `apps/witness_web/` and the
  existing F005 chain runs unchanged against it (`make check`).
- The scenario files carry the feature/scenario header table.
- Each application documents its build procedure per platform, and no
  build output is committed.

## Specification

### One shared scenario suite

The scenario suite is a single, shared, platform-agnostic source. It
is not per-application and not per-platform (S001). A reference
application does not own scenarios: it must satisfy the shared suite.
Application-specific scenarios exist only for behaviour specific to
one application, and never redefine a shared requirement.

### Scenario-to-feature reference

Every scenario file opens with a table recalling the features it
exercises:

| Feature | Scenario in the feature page |
|---|---|
| F015 | Button by accessible name |

This table is the link the conformance matrix is built from: features
(columns) × applications × platforms (rows).

### Application set

Two applications are enough for a long time:

- `witness`: THE reference application, one directory containing the
  platform projections of the same behaviour (window "GuiVerb
  witness", button "Continue"): `index.html` for the Web backend, a
  local GTK4 sub-crate (`gtkada4` dependency, local make, binary in
  `bin/witness`) for platform 2 — no wrapper, no per-platform
  application name: each backend launches its own projection. Covers
  milestone 1 (F005–F040);
- `witness_aria`: derived from the [ARIA Authoring Practices
  patterns](https://github.com/w3c/aria-practices) (disclosure,
  checkbox, list); created with the `apps/` layout, it already runs
  the executable scenarios and will carry the milestone-2 scenarios
  (states F045, structure F055, focus F060) as the features are
  implemented.

Existing Gherkin suites (TodoMVC, WebDriver examples) are not adopted:
their scenarios use the low-level automation vocabulary that S001
excludes, so only the applications' semantics would be reusable — the
scenarios must be written in the canonical vocabulary in any case.

### Layout and builds

```text
apps/
  witness_web/
    index.html, app.js, style.css
    builds/
      <platform>/...   build recipes; no binaries committed
```

Each application build is treated like the template's tools: a
sub-crate with its own dependencies and its local `make`, per
platform. Build outputs are generated locally and never committed.

## Executable scenarios

### Scenario: the shared suite still runs after the reorganisation

- When I run `make check`
- Then the output contains `check OK`
- And I get no error

## Verification beyond bbt

- Unit tests: not applicable — no source change.
- SPARK / proof: not applicable.
- Other: the witness application stays verifiable against an
  accessibility checker (axe), as required by its own proposal.

## Design implications

- Strengthens S001: the shared suite becomes the organisational rule,
  not only a vocabulary rule.
- Revises `docs/proposed/witness_app_web.md` (location
  `tests/apps/witness_web/` → `apps/witness_web/`).
- The app × platform matrix extends `docs/pilot-targets.md`: that
  document compares platform approaches; the matrix records conformance
  results per application and platform.

## Open questions

- Backend selection and launch (see
  `docs/dev/design_discussions.md`, "Backend selection and launch"):
  how a run selects the application/backend pair.
- How the conformance matrix is generated and where it is published
  (later feature; candidate `docs/tests_results/`).

## Finalization target

A "Reference applications" section in `docs/architecture.md`, plus a
pointer from `docs/specifications.md` (the feature index notes where
scenarios live). The scenario header convention belongs to the same
section.
