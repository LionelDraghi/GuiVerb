# Adi2 probe: audit of the existing introspection surface before a minimal probe <!-- omit from toc -->

Source: exploration session on widening pilot targets (Adi2); concern Q019; `docs/pilot-targets.md` ("Adi2"); roadmap phase 4.

## Contents <!-- omit from toc -->
- [Need](#need)
- [Intended outcome](#intended-outcome)
- [Scope](#scope)
- [Non-goals](#non-goals)
- [Acceptance criteria](#acceptance-criteria)
- [Specification](#specification)
- [Executable scenarios](#executable-scenarios)
- [Audit record](#audit-record)
- [Verification beyond bbt](#verification-beyond-bbt)
- [Design implications](#design-implications)
- [Open questions](#open-questions)
- [Finalization target](#finalization-target)

## Need

Adi2 is the pilot target used specifically to measure intrusiveness.
The roadmap phase 4 expects an API audit, a minimal probe, an external
bridge, a retained-tree mapping, and measured intrusiveness, with the
exit criterion: "the same scenarios run and every build/runtime
difference is documented".

The premise of a from-scratch probe is now outdated. Adi2 ships a
development-only introspection bridge that can already screenshot the
running application, walk the widget tree, drive actions (click, text
entry, focus), and read performance counters. The real problems are
not "build a probe" but:

1. **Semantics, not structure.** The bridge exposes a widget tree, not
   an accessibility tree. The canonical model requires role +
   accessible name + states, each distinguishing known value, known
   absence, and unsupported/unknown. Whether an Adi2 widget carries an
   accessible name distinct from its visible text, and whether widget
   classes map onto canonical roles, is unverified.
2. **Build intrusiveness.** The bridge is development-only: probe
   builds differ from production builds. How the bridge is enabled
   (build flag, registration call, runtime event) and what changes at
   runtime must be recorded exactly — that recording is the phase 4
   deliverable, the probe itself is secondary.
3. **In-process transport.** An external backend over an in-process
   bridge raises questions the other pilots do not have: which
   transport (stdio, local socket), which encoding, which tasking
   model on top of the SDL loop, and what happens when the probe fails
   inside the application process.
4. **Injection level discipline.** The probe can act semantically
   (level 3) and manipulate state directly (level 4). The no-silent-
   fallback rule must hold at probe API level, with action provenance
   recorded per action.
5. **Version skew.** Probe and runner evolve independently; version
   negotiation (Q018) is mandatory, not optional.

## Intended outcome

- The Adi2 introspection surface is audited and the audit is recorded
  (capabilities, absences, transport, activation mechanism).
- The exact intrusiveness delta of using it is measured: source
  changes, build profile changes, and runtime differences between a
  plain Adi2 application and a probe-enabled one.
- The witness application has a specified Adi2 projection whose probe
  activation is reproducible, so a later minimal-probe proposal starts
  from evidence instead of a blank page.

## Scope

- An audit of the existing Adi2 bridge/API: tree enumeration, name and
  state exposure, actions, focus, screenshots, counters, transport,
  versioning.
- A specification of the probe activation model: what a probe-enabled
  build adds, how it is enabled, and what must be documented as a
  build/runtime difference.
- The requirement that the witness Adi2 projection runs the same
  reference scenarios through the probe surface once the audit makes
  that assessable.
- Recording the intrusiveness measurement method (what is counted,
  where the record lives).

## Non-goals

- Implementing the GuiVerb Adi2 backend driver (that is a later
  proposal, after this audit).
- Modifying Adi2 itself or deciding where probe hooks live upstream
  (recorded as an open design question).
- The raygui chain (phase 5), Web and GTK backends, vocabulary or
  scenario changes.

## Acceptance criteria

- The audit record states, per capability relevant to the canonical
  contract (Launch / Find / Observe / Act / Wait): supported, absent,
  or unknown — never a silent guess.
- The activation model is specified precisely enough that another
  agent can build a probe-enabled version of the Adi2 witness
  projection without further design discussion.
- Every build and runtime difference introduced by probe activation is
  enumerated in the audit record.
- The intrusiveness measurement is quantified (files touched, packages
  added, build-profile switches, runtime behaviour changes).

## Specification

The audit is a mapping exercise, not a code change to either project.
For each backend-contract verb, the audit records how the existing
Adi2 bridge answers it today, in canonical-vocabulary terms, and what
is missing. Widget classes are mapped to candidate canonical roles
only where the mapping is not contested; contested mappings become
open questions instead of forced equivalents.

Probe activation is specified as an explicit, reproducible profile: an
application that runs unmodified without the probe, and whose probe
activation requires a documented, reviewable change. No silent
enabling, no runtime discovery of an undeclared bridge.

The audit record lives in this proposal while it is a candidate, and
moves to `docs/dev/` (or `docs/architecture.md`, where it decides an
open question) at Finalize.

## Executable scenarios

No bbt scenario at this stage: the proposal specifies an audit and a
probe-activation model for a backend that does not exist yet; there is
no observable GuiVerb behaviour to exercise today. Scenarios are
added by the follow-up minimal-probe proposal, which inherits this
audit as its factual basis. Adding placeholder scenarios now would
assert behaviour the project has not decided to provide.

## Audit record

> Adi2 `0.9.0`, upstream `master` at commit `71f4635a3fcab9d5293df8e0cd9b4d53df44c602`
> (2026-10-26). Sources read: `docs/mcp.md`, `src/mcp/adi-mcp.adb`,
> `src/mcp_stub/adi-mcp.ads`, `src/adi-widget-introspection.ads/.adb`,
> `src/adi-widget.ads`, `src/adi-widget_styles.ads`, `adi.gpr`, `alire.toml`.
> Statuses follow the acceptance criterion: supported / partial / absent / unknown.

### Transport and session

- **File-based IPC, not stdio, not a socket.** Per-process session
  directory `<system temp>/adi_mcp/<PID>/` holding `cmd_<id>.json`,
  `resp_<id>.json`, `screenshot_<id>.png`, and a `ready` sentinel
  rewritten while the application runs. A client detects a dead
  process by the sentinel stopping. The Python MCP server
  (`tools/adi_mcp_server.py`) is optional: the same protocol is
  documented for plain shell use.
- **Pacing:** the Ada side registers callbacks that poll for commands
  each frame; the client enforces single-flight per PID. Commands
  execute inside the ordinary frame loop, through the normal dispatch
  path.
- Encoding is JSON (`Adi.JSON.JSON_Writer`).

### Activation model

- Build-profile switch in `adi.gpr`: the `development` profile
  compiles `src/mcp/`; every other profile (validation, release)
  compiles `src/mcp_stub/`, a documented no-op.
- The application opts in explicitly: `Adi.MCP.Initialize (Win)`
  (optional explicit base dir; `Finalize` on shutdown recommended).
  Two lines plus a `with`.
- No hidden activation: a release binary contains no bridge code and
  exposes no session directory.
- Readiness is discoverable: the `ready` sentinel, namespaced by PID.

### Command inventory

| Domain | Commands |
|---|---|
| Inspection | `screenshot`, `widget_tree`, `widget_info`, `get_focus`, `css_values`, `perf_stats` |
| Search | `find_by_text` (case-insensitive substring or exact), `find_by_type` (substring) |
| Interaction | `click_widget`, `scroll`, `send_keys`, `set_text`, `set_focus`, `quit_app` |
| Tuning | `set_texture_budget` |

### Mapping to the backend contract

| Verb | Status | Evidence and caveats |
|---|---|---|
| Launch / Attach | supported | Initialize + `ready` sentinel; per-PID session; `quit_app` goes through the ordinary quit path and a close handler may refuse |
| Find | partial | By id, path, text, type; covers root tree and overlays; no canonical-role lookup, no ancestor-scoped lookup |
| Snapshot | supported | Full tree JSON per node: type, id, path, text, geometry, states, flags (`visible`, `clickable`, `focusable`, `scrollable`, `draggable`), child and item counts; overlays included; PNG screenshots; resolved CSS per widget part |
| Subscribe | absent | No event stream, no generation counter; change detection is client-side snapshot diffing |
| Wait | absent | Nothing server-side; client-side polling only |
| Perform | partial | Mixed injection levels: `click_widget` synthesizes a pointer event at the widget centre through the normal dispatch pipeline; `send_keys` sends keyboard events to the focused widget; `set_focus`; `scroll` is aimed, not targeted; **`set_text` is a direct model mutation, injection level 4** — it must be excluded from, or explicitly flagged in, semantic actions |

### Semantic fidelity (the canonical object)

| Property | Status | Finding |
|---|---|---|
| Identity | supported | monotonically increasing `Widget_Id`, stable across frames; path fallback; overlay paths (`overlayN:1.2`) |
| Role | partial | `Tag_Name` is the lower-cased Ada external tag of the widget class — a widget-kind name, not a canonical role; no mapping to the ARIA-based vocabulary exists |
| Name | absent | one `Text` field; no accessible name distinct from visible text; non-textual widgets (images, icon buttons) are unreachable by `find_by_text`; no description |
| Value | unknown | text content only through the bridge; typed inputs (e.g. integer value input) were not exercised |
| States | partial | `Widget_State` = Normal / Hovered / Pressed / Focused / Disabled / Selected; Flags = Clickable / Focusable / Scrollable / Draggable / Visible. Disabled, Selected, Focused map cleanly; Hovered and Pressed are CSS-style presentational states, not semantic ones; no read-only, checked, expanded, or required |
| Relations | absent | no label-association, no described-by, no container semantics beyond the tree |
| Bounds | supported | per-widget geometry |
| Generation | absent | no epoch counter; repeated polling is the only freshness signal |

Also recorded: stale or null handles degrade to *empty* answers
(empty fields, empty result sets) rather than errors — silent absence,
which interacts badly with an audit trail unless the backend
distinguishes "not found" from "state unknowable".

### Intrusiveness delta (the phase 4 measurement)

- **Source:** two lines per application (`with Adi.MCP;` +
  `Adi.MCP.Initialize`), optionally a `Finalize` call. Nothing else.
- **Build:** one profile switch. Validation and release binaries
  compile the documented no-op stub — the production binary is
  unaffected.
- **Runtime:** one file-poll callback per frame in development builds;
  JSON serialisation per request; screenshot PNGs in the temp
  directory. The per-frame cost is undocumented — unknown.
- **Verdict:** far below the "medium" intrusiveness anticipated in
  `docs/pilot-targets.md`. No core modification was needed for this
  audit; none is needed for a minimal probe.

### Answers this audit gives the open questions above

1. **Accessible names:** No. One text field, no distinct accessible
   name, no description, no relations. Q019 is answered *in part*:
   structure, states, and actions are sufficient for a minimal probe
   without core modification; name semantics will need a mapping
   convention (text-as-name for text-bearing widgets), and
   descriptions/relations are beyond reach without upstream change.
2. **Transport and tasking:** file IPC, polled inside the frame loop by
   registered callbacks; no dedicated task observed. Failure
   containment is by liveness of the `ready` sentinel; a failed start
   never writes one.
3. **Hook location:** not needed for a minimal probe — existing hooks
   suffice. The question stays open for descriptions/relations and
   read-only/checked/expanded states.
4. **Screenshots and counters:** classified as attachments and
   diagnostics, not canonical model content; both already exist on the
   bridge.

Evidence points for the shared design questions (not decisions):
Q016 gains a third proven transport (file IPC over a per-PID temp
directory); Q017 gains JSON-on-the-app-side as precedent; Q018 is
unresolved — the bridge has no version field, so GuiVerb-side
capability pinning must compensate on the GuiVerb side.

## Verification beyond bbt

- Unit tests: not applicable — no production code in this proposal.
- SPARK / proof: not applicable.
- Other: the audit output must be verifiable against the pinned Adi2
  version (crate version and commit recorded in the audit document).

## Design implications

- Q019 (sufficient semantics without core modification) is the central
  open question; this proposal produces the evidence to decide it.
- Q006 (minimum backend conformance) bounds how strict the semantic
  audit can be; deciding Q006 first would sharpen the audit checklist.
- Q016/Q017 (transport, encoding) and Q018 (attachments, version
  negotiation) apply to the in-process bridge and must be answered
  before any minimal-probe implementation proposal.
- Q023 (backend selection and launch) is unaffected: probe activation
  is a build-profile concern of the application, not of the runner.

## Open questions

- Does the Adi2 bridge expose accessible names distinct from visible
  text, and widget states, with known value / known absence /
  unknown distinguished?
- Which transport and tasking model does the bridge use on top of the
  SDL loop, and what is its failure containment story?
- Where do future probe hooks live if the bridge is insufficient:
  upstream in Adi2, an interposition crate, or a GuiVerb-side patch?
- How are screenshots and performance counters classified: canonical
  attachments, backend diagnostics, or out of scope?

## Finalization target

Audit content to `docs/dev/` (new maintainer document, or merged into
the phase 4 section of `docs/roadmap.md` and `docs/architecture.md`
where it settles Q019); the proposal itself is removed once its
content is integrated.
