# F065 — Semantic drag-and-drop

Source: `docs/proposed/candidate-features.md` (chess, TopoProof)
Milestone: 3 — beyond the reference scenarios

## Need

Drag-and-drop is a first-class GUI interaction in the candidate
features (chess moves, geometry manipulation), expressed with
domain-level objects and units, not pixels.

## Intended outcome

A scenario can express a drag from a semantic source to a semantic
target, optionally in domain units.

## Vocabulary introduced

- `When I drag the <name> <role> to the <name> <role>`;
- `When I drag the <name> <role> <distance> <unit> to the <direction>`
  (domain-unit variant, e.g. `1 cm to the left`);
- postcondition assertions on the result (`the piece is on <square>`).

## ARIA grounding

ARIA has no drag-and-drop semantics; HTML adds drag events, and
platform APIs offer various grab/drop services. This feature is
therefore the first deliberately non-ARIA part of the vocabulary: it
must be defined so that each backend can map it to its native
mechanism, and its feasibility differs per pilot target.

## References

- WAI-ARIA 1.2, the deprecated [aria-grabbed](https://www.w3.org/TR/wai-aria-1.2/#aria-grabbed) and [aria-dropeffect](https://www.w3.org/TR/wai-aria-1.2/#aria-dropeffect): evidence that ARIA deliberately carries no drag-and-drop semantics today

## Acceptance criteria

- The chess candidate scenario is expressible without pixels or
  device concepts.

## Executable scenarios

### Scenario: chess move (candidate)

- When I select square `C2`
- And I drag it to square `E3`
- Then the snapshot of square `C2` is equal to `empty_case.svg`
- And the snapshot of square `E3` is equal to `Knight.svg`

(The snapshot assertions belong to F070; this feature owns the drag
itself.)

## Verification beyond bbt

- None yet.

## Design implications

- First feature where the backend capability spread is wide: the
  capability report must state what drag support means per backend.

## Open questions

- None new.

## Finalization target

`docs/features/scenario_vocabulary.md` or a dedicated
`docs/features/drag_and_drop.md`.
