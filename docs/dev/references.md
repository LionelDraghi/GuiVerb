# References <!-- omit from toc -->

External work this project builds on. One entry per source, with what
GuiVerb takes from it; the details live in the linked documents.

## Contents <!-- omit from toc -->
- [Methodological base](#methodological-base)
- [Normative and grounding references](#normative-and-grounding-references)

## Methodological base

- **ARIA-AT** (W3C ARIA and Assistive Technologies Community Group,
  https://github.com/w3c/aria-at) — the methodological base for
  GuiVerb test plans: a test plan per ARIA pattern, each test an
  instruction in natural language plus a catalogue of stable,
  referenced assertions, executed across screen readers and browsers.
  GuiVerb reuses this structure; the scope differs — ARIA-AT tests
  what assistive technologies convey, GuiVerb tests what a GUI
  exposes to any observer.

## Normative and grounding references

- **WAI-ARIA 1.2** (https://www.w3.org/TR/wai-aria-1.2/) — the
  role/state/property vocabulary GuiVerb scenarios use; 1.3 is a draft
  and is not relied upon.
- **Core Accessibility API Mappings** (https://w3c.github.io/core-aam/)
  — how ARIA semantics are exposed to platform accessibility APIs;
  what the Web backend may assume is already tested upstream (Web
  Platform Tests).
- **ARIA Authoring Practices**
  (https://www.w3.org/WAI/ARIA/apg/) — implementation patterns for the
  witness application and for well-formed test pages.
