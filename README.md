# GuiVerb

**Behaviour-Driven GUI Design**

GuiVerb turns readable GUI behaviour into executable, platform-independent documentation.

```gherkin
- When I run `myapp`
- Then a welcome window appears
- And there is a button named `Continue`
- When I press the button `Continue`
- Then a login dialog appears
```

## Goals

- execute readable Markdown scenarios against graphical applications;
- use WAI-ARIA as the primary common GUI vocabulary;
- keep scenarios independent from Web, GTK, Adi2, raygui, operating systems, and automation drivers;
- make observation mechanism, action mechanism, and end-to-end fidelity explicit;
- preserve the `bbt` philosophy that documentation is directly executable.

## Relationship with `bbt`

GuiVerb originates from [`bbt`](https://github.com/LionelDraghi/bbt) and uses it as its conceptual and practical reference for Markdown scenarios, behaviour description, and executable documentation.

The projects nevertheless have separate scopes:

- `bbt` remains a small, stable black-box behaviour runner for command-line applications;
- GuiVerb explores graphical-interface semantics, observation backends, action providers, accessibility APIs, and native GUI execution environments.

GuiVerb experimentation must not impose GUI dependencies, protocol complexity, release constraints, or architectural churn on `bbt`. Integration with `bbt` should occur only through stable, deliberately chosen boundaries. GuiVerb may initially reuse `bbt` as a runner or parser, but it must be able to evolve as a separate project.

## Pilot targets

1. Web / DOM and accessibility semantics.
2. GTK / AT-SPI.
3. Adi2 / retained widget tree.
4. raygui / immediate-mode instrumentation.

## Documentation

- [Manifesto](docs/manifesto.md)
- [Architecture](docs/architecture.md)
- [Pilot targets](docs/pilot-targets.md)
- [Proposed features](docs/proposed/candidate-features.md)
- [Roadmap](docs/roadmap.md)
- [Concerns and open questions](docs/dev/concerns.md)
- [CI strategy](docs/dev/ci-strategy.md)
- [Reference scenarios](examples/reference-scenarios.md)

## Status

Architectural exploration. The provisional MVP includes Web, GTK/AT-SPI, and Adi2. raygui starts as a feasibility spike.
