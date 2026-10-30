# Release parameters

The common release procedure lives in the reference repository,
[release_procedure.md](https://github.com/LionelDraghi/ada-project-template/blob/main/release_procedure.md),
and applies in full. This file provides the parameter values and the
project-specific additions; read both documents together.

| Parameter | Value |
|---|---|
| Changelog file | `docs/changelog.md` |
| Validation command | `make check` |
| Release-mode build | `make release` |
| Remote | `origin` |
| Release branch | `main` |
| Required CI checks | none yet |

## Project-specific additions

- The Alire crate is `guiverb`; it is not published yet.
- GuiVerb must be releasable without changing `bbt` (see
  `docs/roadmap.md`, phase 0A).
