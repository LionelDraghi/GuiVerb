# Open Questions

## Semantic model

- Is `window` a canonical role?
- Is `screen` an object or an application-state alias?
- Which value types and ARIA relations belong in the MVP?

## Backend contract

- Does `Find` belong to the backend or the core?
- Does launch reuse generic process management inherited from or delegated to `bbt`?
- What defines minimum backend conformance?

## Observation and action

- Which correlation tokens may cross provider boundaries?
- Can fallback between action levels ever be automatic?
- What consistency is required between lookup and action?

## Object resolution

- Do `a`, `an`, and `the` express cardinality?
- Is exact case-sensitive matching the default?
- Are partial and ordinal matching required?

## Time

- Does `appears` wait implicitly?
- How is a transition baseline captured?
- Do consecutive assertions share a deadline?

## Protocol

- Standard I/O or local socket?
- JSON, CBOR, or another encoding?
- How are attachments transferred and versions negotiated?

## MVP

- Can Adi2 expose sufficient semantics without core modification?
- Can raygui support identity, focus, and text entry with localised instrumentation?
- Playwright or WebDriver/BiDi for the Web backend?
