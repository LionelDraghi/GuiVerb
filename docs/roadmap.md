# Roadmap

This is a lightweight index of intentional future development. Details
remain in the development plan below and in the linked documents.

| Phase | Outcome | Status |
|---|---|---|
| 0 | Reference behaviour: one reference application specification, one shared scenario suite, the minimal semantic vocabulary, expected error cases | In progress |
| 0A | Project separation from `bbt`: standalone repository layout, dependency boundary, invocation strategy, compatibility contract | In progress |
| 1 | Canonical model and logical protocol | Planned |
| 2 | Web reference backend | Planned |
| 3 | GTK / AT-SPI backend | Planned |
| 4 | Adi2 probe | Planned |
| 5 | raygui feasibility spike | Planned (gated) |
| 6 | Consolidation | Planned |

Priority concerns are considered before roadmap additions when choosing
new work, unless the user chooses otherwise.

## Feature plan

Features are developed through progressive, numbered proposals in
`docs/proposed/` (`F005` to `F075`, numbered in steps of 5 so features
can be inserted without renumbering, plus the witness web
application), indexed in `docs/specifications.md`. The plan is
milestone-driven:

1. minimal loop: witness application on platform 1 (Web) and the
   smallest feature set that runs the four reference scenarios, plus
   text and value entry for a successful login path;
2. wider ARIA vocabulary;
3. beyond the reference scenarios (drag-and-drop, gated visual
   assertions, action provenance).

Implementation work starts with milestone 1 only; features and
platforms are extended afterwards.

## Development plan

### Phase 0: Reference behaviour

Deliver one reference application specification, one shared scenario
suite, the minimal semantic vocabulary, and expected error cases.

Exit: no scenario mentions a toolkit, OS, selector technology, or input
device.

### Phase 0A: Project separation from `bbt`

Deliver a standalone GuiVerb repository layout, dependency boundary,
invocation strategy, and compatibility contract with `bbt`.

Exit: GuiVerb can build, test, and release without changing `bbt`; any
reused `bbt` capability is accessed through a stable and documented
boundary.

### Phase 1: Canonical model and logical protocol

Deliver the object schema, capabilities, sessions, generations,
messages, errors, attachments, injection classification, and version
negotiation.

Exit: all reference scenarios are expressible without native toolkit
concepts.

### Phase 2: Web reference backend

Deliver browser lifecycle, role/name lookup, semantic actions, waits,
screenshots, and semantic diagnostics.

Exit: reference scenarios run without CSS, XPath, or technical test IDs.

### Phase 3: GTK / AT-SPI backend

Deliver `libatspi` mapping, event subscriptions, semantic actions,
optional system input, and local/headless profiles.

Exit: the same scenarios run through AT-SPI with explicit
stale-reference and setup diagnostics.

### Phase 4: Adi2 probe

Deliver API audit, minimal probe, external bridge, retained-tree
mapping, and measured intrusiveness.

Exit: the same scenarios run and every build/runtime difference is
documented.

### Phase 5: raygui feasibility spike

Deliver wrappers, frame snapshots, generation-scoped references,
button/text-entry actions, and measured application changes.

Gate: promote if instrumentation is localised; defer otherwise.

### Phase 6: Consolidation

Deliver shared conformance tests, capability reports, protocol
compatibility tests, configuration profiles, diagnostics, and
architecture decision records.

## Immediate backlog

1. Define the reference application and scenarios.
2. Freeze the MVP vocabulary subset.
3. Draft logical protocol messages independently of encoding.
4. Compare Playwright and WebDriver/BiDi.
5. Build an AT-SPI tree dumper and event monitor.
6. Audit Adi2 widget and MCP APIs.
7. Build a raygui button/textbox wrapper.
8. Replace matrix assumptions with measured results.
