# GuiVerb Manifesto <!-- omit from toc -->

## Contents <!-- omit from toc -->

- [Purpose](#purpose)
- [Relationship with `bbt`](#relationship-with-bbt)
- [Principles](#principles)
- [Behaviour vocabulary](#behaviour-vocabulary)
- [Architecture direction](#architecture-direction)
- [Pilot targets](#pilot-targets)
- [References](#references)

## Purpose

GuiVerb is a **Behaviour-Driven GUI Design** project. It turns readable descriptions of graphical-interface behaviour into executable, platform-independent documentation.

GuiVerb extends the central idea demonstrated by [`bbt`](https://github.com/LionelDraghi/bbt): **run the documentation; documentation is code**.

```gherkin
- When I run `myapp`
- Then a welcome window appears
- And the window contains `Hello World`
- And there is a button named `Continue`
- When I press the button `Continue`
- Then a login dialog appears
```

## Relationship with `bbt`

`bbt` remains the reference implementation and source of the original approach: Markdown documents, nearly natural English, black-box behaviour description, and direct execution of examples and specifications.

GuiVerb starts from that foundation but forms a separate experimental project because graphical interfaces introduce concerns that do not belong in the stable `bbt` core:

- semantic GUI objects and accessibility vocabularies;
- observation and action backends;
- asynchronous interface state;
- native desktop and browser execution environments;
- input-injection levels and end-to-end fidelity;
- visual assertions and graphical-session CI.

The separation follows these rules:

1. GuiVerb may reuse `bbt` through stable public behaviour, libraries, executable invocation, or exchanged files.
2. GuiVerb-specific dependencies and experimental protocols remain outside `bbt`.
3. `bbt` is not required to adopt GuiVerb release cadence, backend architecture, or GUI vocabulary.
4. Changes proposed to `bbt` must remain useful to `bbt` independently of GuiVerb.
5. GuiVerb must be capable of continuing as a standalone project if its architecture diverges.

## Principles

1. Scenarios describe user intent and observable results, not implementation details.
2. Scenarios are independent from toolkit, operating system, automation driver, and input device.
3. [WAI-ARIA](https://www.w3.org/WAI/standards-guidelines/aria/) provides the primary vocabulary for roles, states, properties, and relationships.
4. GuiVerb defines the missing behavioural semantics: lifecycle, actions, transitions, assertions, navigation, focus, and time.
5. Semantic actions such as `press`, `enter`, and `select` are preferred to `click`, `tap`, and raw keystrokes unless the input mechanism is itself under test.
6. Backends report how the interface was observed and how each action was injected.
7. Missing capability, configuration failure, backend failure, and failed application assertion are distinct outcomes.

## Behaviour vocabulary

```gherkin
- When I run `myapp`
- When I close the application
- When I press the button `Continue`
- When I enter `lionel` in the textbox `User`
- When I select `France` from the list `Country`
- When I check `Remember me`
- When I expand `Advanced options`
- When I move to the next control

- Then a login dialog appears
- Then the progress indicator disappears
- Then an alert named `Invalid password` is visible
- Then the button `Continue` is enabled
- Then the textbox `User` has focus
- Then the tab `General` is selected
- Then the table `Results` contains `3` rows
- Then the progress bar `Progress` has value `100`
- Then a status message `Up to date` eventually appears
```

## Architecture direction

```text
GuiVerb core
  <-> versioned backend protocol
        <-> external backend process
              [optional in-process probe]
                    <-> application or toolkit
```

Observation and action are logically separate. Four action levels are distinguished: system input, toolkit input, semantic action, and direct state manipulation. There is no silent fallback between levels.

## Pilot targets

The pilots represent observation models, not operating systems or popularity:

1. Web through DOM and accessibility semantics.
2. GTK through AT-SPI.
3. Adi2 through a retained widget tree and an optional in-process probe.
4. raygui through immediate-mode instrumentation.

## References

- [`bbt`](https://github.com/LionelDraghi/bbt)
- [WAI-ARIA overview](https://www.w3.org/WAI/standards-guidelines/aria/)
- [ARIA Authoring Practices Guide](https://www.w3.org/WAI/ARIA/apg/)
- [AT-SPI](https://docs.gtk.org/atspi2/)
- [Adi2](https://github.com/ovenpasta/adi2)
- [raygui](https://github.com/raysan5/raygui)
