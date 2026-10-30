# F070 — Region snapshots and visual assertions <!-- omit from toc -->

Source: `docs/proposed/candidate-features.md` (chess snapshots, comparison
        policies)
Milestone: 3 — beyond the reference scenarios (gated)

## Contents <!-- omit from toc -->
- [Need](#need)
- [Intended outcome](#intended-outcome)
- [Vocabulary introduced](#vocabulary-introduced)
- [ARIA grounding](#aria-grounding)
- [References](#references)
- [Acceptance criteria](#acceptance-criteria)
- [Executable scenarios](#executable-scenarios)
- [Verification beyond bbt](#verification-beyond-bbt)
- [Design implications](#design-implications)
- [Open questions](#open-questions)
- [Finalization target](#finalization-target)
- [Gate](#gate)

## Need

Some assertions are visual by nature: a chessboard square is empty, a
rendering matches a reference image. The candidate features ask for
region-scoped snapshots and configurable comparison rules.

## Intended outcome

A scenario can capture a semantic region and compare it, under
explicit policies.

## Vocabulary introduced

- `the snapshot of <target> is equal to <asset>`;
- comparison policies: scaling, antialiasing, colour tolerance.

## ARIA grounding

None: this is deliberately outside the ARIA vocabulary. It must not
compete with semantic assertions: the candidate features list
"explicit distinction between semantic state assertions and visual
rendering assertions" as a cross-cutting requirement, and S001
forbids toolkit-dependent scenarios. A visual assertion is anchored on
a semantic region (a named object), never on coordinates.

## References

- None in ARIA: visual assertions are deliberately outside the ARIA vocabulary (see [S003] in `docs/specifications.md`)

## Acceptance criteria

- A region-scoped comparison passes and fails with a readable diff on
  the chess demo, once F065 exists.

## Executable scenarios

- See the chess scenario in F065.

## Verification beyond bbt

- None yet.

## Design implications

- New object kind in the canonical model: a visual attachment attached
  to a semantic object; ties into the protocol attachment design
  (concern Q018).

## Open questions

- Q018.

## Finalization target

`docs/features/visual_assertions.md` (to create).

## Gate

Promote only after milestone 2: this feature risks dragging the
protocol into image management before the semantic core is stable.
