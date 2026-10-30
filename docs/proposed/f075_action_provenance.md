# F075 — Action provenance

Source: `docs/proposed/candidate-features.md` (cross-cutting: record whether
        an action was performed through system input, toolkit input,
        semantic action, or direct manipulation); `docs/dev/ci-strategy.md`
Milestone: 3 — beyond the reference scenarios

## Need

The same scenario line can be executed at different injection levels,
with different fidelity. The architecture makes "end-to-end fidelity"
explicit, and the CI strategy requires a capability report to state
the injection level used. This must be visible, not implicit.

## Intended outcome

Every executed action carries a recorded provenance: system input,
toolkit input, semantic action, or direct manipulation; reports and
diagnostics expose it.

## Vocabulary introduced

None in scenarios: provenance is a report and diagnostic concern, not
a scenario concern. At most a diagnostic output convention.

## ARIA grounding

None: this is a GuiVerb execution-model concept that cuts across
backends.

## References

- [ARIA-AT](https://github.com/w3c/aria-at) — model for results consolidated per platform; see `docs/dev/references.md`

## Acceptance criteria

- A run report states, per action, the injection level used.
- A backend that silently degrades from one level to another is
  detectable.

## Executable scenarios

Not applicable: no scenario syntax. The check is a run-report
property.

## Verification beyond bbt

- Unit tests on the report model, when unit tests exist.

## Design implications

- Ties the action-tier model (F020, F060) to the capability report
  and to the CI strategy profiles.

## Open questions

- Q008.

## Finalization target

`docs/features/execution_model.md` (to create).
