# Instructions for coding agents <!-- omit from toc -->

This file is the entry point for agents working on GuiVerb.

- The owner reviews the changes BEFORE staging, and is the only one who
  approves them.
- The owner works on the files at the same time as the agent: if a file
  is modified, the owner made the change; if it is staged, the owner
  approved it. An agent never overwrites such a file on the grounds
  that it did not make the changes itself.
- Use the Ada MCP (Serena), not grep.


**Before any other action, read the shared template referenced below
and follow it.**

The shared rules for Lionel's Ada projects live in the [reference
repository on GitHub](https://github.com/LionelDraghi/ada-project-template/blob/main/AGENTS.md)
and apply here in full: non-negotiable git rules (in brief: no `git
add`, commit, push, tag, release or Alire publish without the owner's
explicit, post-review consent; never modify a golden file, `expected_*`,
without the owner's agreement), procedure choice, reference policy,
skills, Ada tooling (Serena MCP first). This file keeps only what is
specific to GuiVerb.

## Contents <!-- omit from toc -->

- [Project identity](#project-identity)
- [Enabled capabilities](#enabled-capabilities)
- [Project commands](#project-commands)
- [Project-specific paths or release parameters](#project-specific-paths-or-release-parameters)
- [Exceptions](#exceptions)

## Project identity

- Name: GuiVerb
- Purpose: behaviour-driven GUI design — turn readable GUI behaviour,
  expressed with a WAI-ARIA-based vocabulary, into executable,
  platform-independent documentation.
- Primary language: Ada

GuiVerb originates from `bbt` and uses it as its conceptual and
practical reference, but is a separate project: no GUI dependency,
protocol complexity, or architectural churn may leak into `bbt`.
See `docs/manifesto.md` and `docs/architecture.md`.

The project is at the architectural-exploration stage: the repository
is mostly documentation, and the build skeleton is a placeholder. Do
not invent implementation beyond the current phase (see
`docs/roadmap.md`).

## Enabled capabilities

| Capability | Enabled | Project parameter, if any |
|---|---:|---|
| bbt executable specifications | yes | `make check` (no scenario yet) |
| Unit tests | no | not yet; to add with the first sources |
| SPARK analysis | no | N/A |
| Formal proof | no | N/A |
| Static analysis / metrics | no | N/A |
| Alire release | yes | crate `guiverb`; not published yet |
| Platform packages | no | N/A |

## Project commands

- Build: `make build` (Alire build, validation profile)
- Quick validation: `make check`
- Full validation: `make check` (single suite for now)
- Generate reports: N/A

The Web backend needs `chromedriver` on PATH, with a major version
matching the installed Chromium (see
`docs/dev/design_discussions.md`, "Web driver for the minimal loop").
Set `GUIVERB_HEADED` (any value) to run the browser visibly instead
of headless; scenarios must not depend on it.

The Adi2 backend (`make check-adi2`) runs the witness's Adi2 probe
projection (`apps/witness_adi2/`, Adi2 pinned at the audited commit —
see its `alire.toml`) and speaks the development-only Adi2.MCP
file-IPC bridge; window observation only at this stage
(`docs/proposed/adi2_probe_audit.md` for the audit record). The
GTK/AT-SPI chain is Linux-only (libatspi): the runner links it on
POSIX only (`guiverb.gpr`, platform-conditional Linker switches).

## Project-specific paths or release parameters

- `docs/dev/ci-strategy.md` is an additional maintainer document
  beyond the standard tree; open design questions live in
  `docs/dev/concerns.md` (kind `Design`).
- `docs/proposed/candidate-features.md` holds the candidate-scenario
  inbox (former `docs/proposed_features.md`).
- `examples/reference-scenarios.md` holds the reference scenarios;
  they move to `docs/features/` when they become executable.
- Release parameters: `docs/dev/release_procedure.md`.

## Exceptions

None.
