# Architecture <!-- omit from toc -->

## Contents <!-- omit from toc -->

- [Project boundary with `bbt`](#project-boundary-with-bbt)
- [Core boundary](#core-boundary)
- [Canonical semantic object](#canonical-semantic-object)
- [Observation and action](#observation-and-action)
- [Logical backend contract](#logical-backend-contract)
- [Object resolution](#object-resolution)
- [Temporal semantics](#temporal-semantics)
- [Protocol frontier](#protocol-frontier)

## Project boundary with `bbt`

GuiVerb is architecturally separate from `bbt`.

```text
bbt                             GuiVerb
CLI behaviour runner            GUI behaviour design and execution
stable core                     experimental backends and protocol
no GUI dependencies             platform-specific GUI adaptors
independent release path        independent release path
```

Permitted integration directions include invoking the `bbt` executable, reusing a stable parser/library if one is intentionally exposed, or exchanging documented scenario/results files. GuiVerb must not require GUI-specific code inside the `bbt` core.

## Core boundary

```text
GuiVerb core
  <-> versioned backend protocol
        <-> external backend process
              [optional in-process probe]
                    <-> application or toolkit
```

## Canonical semantic object

```text
Semantic_Object
- reference
- role
- name
- description
- value
- states
- relations
- children
- actions
- bounds
- generation
```

ARIA is the primary ontology, not a backend API. Accessible name, visible text, technical identifier, and description remain distinct. Every property distinguishes known value, known absence, and unsupported or unknown.

## Observation and action

```text
GUI Session
- Observation Provider
- Action Provider
- Correlation Policy
```

Action injection levels:

1. system input;
2. toolkit input;
3. semantic accessibility or automation action;
4. direct state manipulation.

No silent fallback occurs between these levels.

## Logical backend contract

```text
Describe_Backend
Open_Session
Launch / Attach
Snapshot
Find
Subscribe
Perform
Wait_Until
Close_Session
```

## Object resolution

Initial rule:

```text
role + exact accessible name + optional ancestor scope
```

Zero results means not found. Multiple results means ambiguous. The engine never selects the first result silently.

## Temporal semantics

- `is visible` checks current state;
- `appears` checks an absent-to-present transition;
- `eventually appears` waits within a configured deadline.

Timing configuration does not belong in ordinary behavioural prose.

## Protocol frontier

The protocol carries versions, capabilities, sessions, canonical snapshots, semantic references, changes, actions, actual injection level, structured errors, diagnostics, and attachment references.

Native handles, DOM nodes, CSS, XPath, AT-SPI object paths, and toolkit APIs remain backend-private. Parsing scenario English remains in `bbt`.
