# GuiVerb specifications

This document holds the project's cross-feature specifications and the
index of the feature pages. The feature pages own every detail; this
index may summarise, never duplicate.

## 1. Feature index

Feature pages are numbered by a stable scheme with one prefix per
feature series:

| Prefix | Meaning |
|---|---|
| `Fnnn` | core features: scenario vocabulary and semantics, backend-independent |

Numbers advance in steps of 5, so that features can be inserted later
without renumbering; an inserted feature takes one of the free
numbers. The next free number is `F080`.

Features are developed through proposals in `docs/proposed/`, grouped
in three milestones (see the proposals for the milestone detail):

1. minimal loop — witness application on platform 1 (Web), the
   smallest feature set that runs the four reference scenarios, plus
   text and value entry, so the loop covers a successful login path;
2. wider ARIA vocabulary — states, the frozen MVP widget role set,
   structure and landmarks, focus;
3. beyond the reference scenarios — drag-and-drop, visual assertions
   (gated), action provenance.

| Id | Feature | Summary |
|---|---|---|---|
| F005 | Launch and window observation | run an application, assert a window appears |
| F010 | Text content of a window | assert the text a window contains |
| F015 | Button by accessible name | role + name lookup, enabled state |
| F020 | Press action | semantic activation of a control |
| F025 | Dialog appearance | role `dialog`, bounded `eventually` wait |
| F030 | Text fields and focus | textbox, password field, focus assertions |
| F035 | Text and value entry | typing, slider and spinbutton values |
| F040 | Alerts and status messages | live-region observations; completes milestone 1 |
| F045 | Widget states | checked, pressed, expanded, selected, required, invalid |
| F050 | MVP widget role set | frozen subset of the ARIA widget roles |
| F055 | Structure roles and landmarks | headings, lists, tables, landmarks, scoped lookup |
| F060 | Focus and keyboard navigation | focus movement, key presses, composite widgets |
| F065 | Semantic drag-and-drop | source-to-target drag, domain units |
| F070 | Region snapshots | visual assertions on semantic regions (gated) |
| F075 | Action provenance | recorded injection level per action |

The witness web application that milestone 1 needs is proposed in
`docs/proposed/witness_app_web.md`; it is test infrastructure, not a
feature.

## 2. Cross-feature specifications

Each specification carries a stable identifier `Snnn`. A number never
changes meaning, a removed specification is never reused.

### [S001] Scenario vocabulary independence

No scenario may mention a toolkit, an operating system, a selector
technology, or an input device. Scenarios use the common GUI vocabulary
defined by the project, with WAI-ARIA as the primary reference
(WAI-ARIA 1.2; 1.3 is a draft and is not relied upon).

### [S002] Executable documentation

Scenario pages under `docs/features/` are executable with `bbt` (or,
for GUI scenarios, with the GuiVerb runner once it exists) and stay
executable at all times.

### [S003] Semantic anchoring of visual assertions

A visual assertion (F070) is anchored on a semantic object — a named
region or widget — never on coordinates or DOM paths.

### [S004] Test plans follow the ARIA-AT structure

Test plans follow the [ARIA-AT](https://github.com/w3c/aria-at)
structure (see `docs/dev/references.md`): one plan per pattern, tests
as natural-language instructions, assertions stable and referenced by
id, results consolidated per platform.
