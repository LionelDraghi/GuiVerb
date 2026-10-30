# Development workflow

This project follows the shared lifecycle — Explore, Propose,
Implement, Refactor, Finalize, Release — defined in the reference
repository's [lifecycle.md](https://github.com/LionelDraghi/ada-project-template/blob/main/lifecycle.md).
Read it before any work; this file only records what is specific to
this project.

## Project conventions

- Quick validation: `make check`
- Full validation: `make check` (single suite for now)
- Domain rules the agent must know: `docs/manifesto.md` (intent),
  `docs/architecture.md` (architecture), `docs/roadmap.md` (current
  phase and exits)

## Conditional readings

- To understand what GuiVerb must and must not be: `docs/manifesto.md`
- To understand or challenge the architecture: `docs/architecture.md`,
  `docs/dev/design_discussions.md`
- To know the current phase and its exit criteria: `docs/roadmap.md`
- To check whether a question or concern is already tracked: `docs/dev/concerns.md`
- To plan CI for a backend: `docs/dev/ci-strategy.md`
- To write or review candidate scenarios: `docs/proposed/candidate-features.md`,
  `examples/reference-scenarios.md`, and the bbt skill
- To prepare or run a release: the [common release procedure on GitHub](https://github.com/LionelDraghi/ada-project-template/blob/main/release_procedure.md),
  with the GuiVerb parameters in `docs/dev/release_procedure.md`
