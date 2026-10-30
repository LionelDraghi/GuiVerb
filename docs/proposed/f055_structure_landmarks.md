# F055 — Structure roles and landmarks

Source: ARIA 1.2 document structure and landmark taxonomies
Milestone: 2 — wider ARIA vocabulary (Web)

## Need

Real applications are more than widgets: titles, lists, tables, and
regions. Structure roles serve two purposes: asserting structure, and
scoping other queries to a region.

## Intended outcome

A scenario can assert structural elements and scope lookups to a named
region.

## Vocabulary introduced

- Structure: `heading` (with level), `list` / `listitem`,
  `table` / `row` / `cell` / `columnheader`;
- Landmarks: `main`, `navigation`, `banner`, `contentinfo`,
  `complementary`, `search`, and named `region`;
- Scoping: `in the <name> <role>` qualifier on existing assertions.

## ARIA grounding

Document structure roles and landmark roles of the ARIA taxonomy.
Landmarks are the GuiVerb replacement for XPath-ish scoping: a
scenario scopes to `the main region`, never to a DOM path.

## References

- WAI-ARIA 1.2, [document structure roles](https://www.w3.org/TR/wai-aria-1.2/#document_structure_roles) and [landmark roles](https://www.w3.org/TR/wai-aria-1.2/#landmark_roles)

## Acceptance criteria

- A scenario can assert a heading and scope a button lookup to a
  navigation region on an extended witness page.

## Executable scenarios

### Scenario: scoped lookup

- Given the application is open
- Then the main region contains a heading `Settings`
- And in the navigation region there is a link named `Home`

## Verification beyond bbt

- None yet.

## Design implications

- First composite object: a region containing other objects. The
  canonical model must define containment and scoped lookup (phase 1).

## Open questions

- None.

## Finalization target

`docs/features/scenario_vocabulary.md`.
