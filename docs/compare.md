# GuiVerb compared with current GUI testing approaches

## Purpose

GuiVerb aims to make a high-level GUI specification directly executable without requiring the author to write JavaScript, Python, C++, CSS selectors, XPath expressions, or platform-specific automation details.

The comparison therefore focuses on the following criteria:

- ability to express the expected system behaviour in a common domain-oriented language;
- readability as specification and documentation;
- independence from the operating system, GUI toolkit, browser, and automation driver;
- need for step definitions, scripts, selectors, or imperative code;
- use of semantic roles, names, states, and relationships;
- ability to reuse one scenario across several implementations;
- transparency about the effective observation and action mechanisms.

This document compares approaches, not product maturity. GuiVerb is a project hypothesis; the other solutions are existing tools or test infrastructures.

## Synthesis

| Approach | Specification level | Technical code required | Platform independence | Semantic targeting | Same scenario across GUI technologies | Main value | Main limitation relative to GuiVerb |
|---|---|---:|---|---|---|---|---|
| **GuiVerb** | High-level executable GUI behaviour | Intended: no backend code in ordinary scenarios | Target objective: Web and native toolkits through adapters | Canonical roles, accessible names, states, relations, and domain extensions | Core objective | Executable documentation independent from implementation details | Experimental; vocabulary, protocol, and backends remain to be proved |
| **W3C APG regression tests** | Technical regression tests tied to APG examples | JavaScript with AVA, Selenium, utilities, and selectors | Browser-oriented | ARIA behaviour is the subject, but tests target concrete Web examples | No generic cross-toolkit contract | Strong regression coverage for published APG implementations | Not written as a reusable natural-language system specification |
| **Playwright** | Imperative Web end-to-end tests | JavaScript/TypeScript or another supported client language | Cross-browser, but Web-specific | Strong role/name locators; CSS and test IDs also available | No native GTK/Windows/macOS toolkit portability | Mature Web actions, locators, waiting, diagnostics, and browser control | Tests still contain programming constructs and browser-specific concepts |
| **Cucumber / Gherkin with custom step definitions** | Readable scenarios over user-defined vocabulary | Yes, step definitions must be implemented and maintained | Depends entirely on the step-definition layer | Possible, but not imposed by Cucumber | Possible only if the project builds the abstraction itself | Mature BDD workflow and readable feature files | Gherkin alone does not provide a portable GUI semantic model or backends |
| **Cucumber-CPP CalcQt** | Gherkin over a Qt calculator example | C++ step definitions and Qt test integration | Qt/C++ example rather than common GUI abstraction | Exercises calculator logic through Qt signals/slots | No | Useful precedent for Gherkin around a GUI application | Does not establish generic semantic observation or portable GUI actions |
| **Dogtail + Behave/qecore** | Gherkin can describe workflows; Python implements steps | Python step definitions and AT-SPI automation code | Linux GNOME, Xorg and Wayland | AT-SPI accessibility objects | Not beyond the supported desktop stack without new adapters | Real desktop workflow automation through accessibility | Requires Python glue and remains tied to GNOME/AT-SPI infrastructure |
| **WayDriver** | Rust API for functional GTK/Wayland tests | Rust code; XPath locators over AT-SPI | Wayland/GTK-oriented | AT-SPI roles and properties, plus GActions and input | No common Web/native scenario layer | Isolated headless compositor, real input, screenshots, video, AT-SPI actions | Exposes Rust, XPath, compositor, and GTK/Wayland details to test authors |
| **Raw AT-SPI/libatspi** | Low-level accessibility API | Native-language API code | Linux accessibility stack | Excellent semantic access to roles, states, text, values, actions, relations | No | Rich observation and action foundation for a GuiVerb backend | API, D-Bus, object lifetime, and session configuration are implementation concerns |
| **APG-style generic test PoCs / platform accessibility tests** | Conformance-oriented technical tests | Web/platform scripts and adapter code | Varies by engine or accessibility API | Strong semantic focus | Varies; usually API-specific | Valuable source of assertions and mappings | Not a unified high-level application behaviour language |

## GuiVerb and W3C APG tests

The WAI-ARIA Authoring Practices repository maintains interactive Web examples and regression tests. Its test infrastructure uses the AVA runner, Selenium WebDriver, shared assertion utilities, and selective regression execution. Focus assertions, for example, poll the browser and inspect `document.activeElement` through WebDriver.

That approach is appropriate for maintaining the concrete APG examples. It verifies implementation details and documented keyboard, role, property, state, and focus behaviour in a browser.

GuiVerb addresses a different level:

```gherkin
- Given the toggle button `Mute` is not pressed
- And the toggle button `Mute` has focus
- When I press key `Space`
- Then the toggle button `Mute` is pressed
```

The scenario expresses the behavioural contract. It does not specify Selenium, JavaScript, `document.activeElement`, a CSS selector, or an HTML structure.

The intended separation is:

```text
APG documentation and patterns
        -> source of semantic requirements
GuiVerb scenario
        -> reusable executable contract
GuiVerb backend
        -> Playwright, AT-SPI, native accessibility API, or toolkit probe
```

### Added value over APG regression tests

GuiVerb aims to add:

1. **Specification readability**: the behavioural contract is visible without reading test code.
2. **Implementation independence**: the scenario targets a role, accessible name, state, and relationship rather than one APG DOM implementation.
3. **Backend portability**: the same contract can be attempted against Web, GTK/AT-SPI, Adi2, raygui, and future Windows or macOS backends.
4. **Action-path transparency**: a report distinguishes keyboard input, pointer input, toolkit event, semantic accessibility action, and direct manipulation.
5. **Domain extension**: the common GUI vocabulary may be extended with chess squares, geometric points, units, or region snapshots without reducing ordinary widgets to CSS or XPath.

GuiVerb does not replace APG. APG remains a primary source for interaction requirements, roles, states, properties, and example widgets.

## GuiVerb and Playwright

Playwright is the strongest existing candidate for the GuiVerb Web backend. Its recommended locators include role, label, text, and other user-facing attributes. A typical Playwright test is already relatively semantic:

```javascript
await page.getByLabel('User Name').fill('John');
await page.getByRole('button', { name: 'Sign in' }).click();
await expect(page.getByText('Welcome, John!')).toBeVisible();
```

The equivalent GuiVerb scenario would move the programming and browser details behind the backend:

```gherkin
- When I enter `John` in the textbox `User Name`
- And I press the button `Sign in`
- Then `Welcome, John!` is visible
```

Playwright contributes mature browser control, locating, auto-waiting, and diagnostics. GuiVerb contributes a higher-level portable specification and a common contract shared with non-Web backends.

## GuiVerb and Cucumber

Cucumber provides Gherkin and a mature BDD execution model. Its standard workflow requires scenario phrases to be connected to executable step definitions in a programming language.

GuiVerb retains the readable scenario idea but proposes a standard GUI vocabulary and standard backend contract. Ordinary phrases such as these should not require project-specific step code:

```gherkin
- When I press the button `Continue`
- Then a dialog named `Login` appears
```

Application-domain extensions may still require explicit adapters or vocabulary extensions, but common GUI roles and actions should be built into GuiVerb.

The Cucumber-CPP CalcQt example is a useful precedent because it places Gherkin around a Qt GUI application. However, its step definitions exercise calculator logic through Qt signals and slots. That demonstrates Gherkin integration, not a generic cross-platform GUI observation and action model.

## GuiVerb and Dogtail with Behave

Dogtail is a Python GUI automation framework built on AT-SPI. It can be combined with Behave and qecore so that Gherkin feature files describe workflows while Python step definitions traverse accessible objects and inject actions.

This stack is close to GuiVerb in spirit:

- Gherkin-readable scenarios;
- accessibility-based object discovery;
- real desktop workflow automation;
- support for GNOME on Xorg and Wayland.

Its main difference is architectural. The scenario vocabulary and portability depend on Python step implementations written by each test project. GuiVerb intends common phrases, canonical semantics, backend capability reporting, and reuse beyond the GNOME/AT-SPI stack.

Dogtail remains a candidate implementation dependency or reference for a GTK backend, not a competing semantic standard that GuiVerb needs to replace.

## GuiVerb and WayDriver

WayDriver provides a Rust library for headless GTK/Wayland testing. It starts an isolated compositor session, interacts through AT-SPI and real Wayland input, and captures screenshots and video. Its locator API uses XPath over the AT-SPI tree.

WayDriver closely matches several GuiVerb backend requirements:

- controlled headless session;
- explicit semantic versus real-input action paths;
- AT-SPI observation;
- screenshots and recordings;
- CI isolation.

The distinction is at the authoring boundary. A WayDriver author writes Rust and XPath such as a button query over the AT-SPI tree. A GuiVerb author should write:

```gherkin
- When I press the button `Sign in`
```

A GTK backend could potentially use WayDriver internally while keeping Rust, XPath, Mutter, D-Bus, and PipeWire outside the behavioural document.

## GuiVerb and raw accessibility APIs

AT-SPI exposes accessible objects and interfaces for actions, collections, components, editable text, selection, tables, text, and values. It is an excellent backend foundation, but it is not itself an executable specification language.

The same distinction will apply to future Windows UI Automation and macOS accessibility backends:

- platform accessibility APIs provide observation and actions;
- GuiVerb provides the portable specification vocabulary and execution contract.

## Positioning statement

GuiVerb is not intended to outperform specialised automation engines at their native layer. It is intended to sit above them.

```text
High-level executable GUI specification
                    GuiVerb
                       |
          common semantic backend contract
             /         |          \
       Playwright   AT-SPI     toolkit probe
          Web       GTK/Linux   Adi2/raygui
```

Its differentiator is therefore:

> One readable behavioural specification, expressed with semantic GUI concepts, executable through several platform-specific engines without embedding their programming languages, selectors, or deployment details in the document.

## Validation questions

The comparison creates concrete hypotheses that the project must prove:

1. Can the common vocabulary cover APG widgets without falling back to CSS or JavaScript?
2. Can one scenario run unchanged against at least Web and GTK implementations?
3. Can GuiVerb expose action level and backend limitations without burdening ordinary scenarios?
4. Can application-specific concepts be extended without fragmenting the common language?
5. Is the reduction in step code and platform jargon material compared with Cucumber plus custom automation steps?
6. Can existing engines such as Playwright, Dogtail, or WayDriver be reused behind backends rather than reimplemented?

## References

- [WAI-ARIA Authoring Practices repository](https://github.com/w3c/aria-practices)
- [Playwright locators](https://playwright.dev/docs/locators)
- [Playwright accessibility testing](https://playwright.dev/docs/accessibility-testing)
- [Cucumber tutorial](https://cucumber.io/docs/guides/10-minute-tutorial/)
- [Cucumber-CPP CalcQt example](https://github.com/cucumber/cucumber-cpp/tree/main/examples/CalcQt)
- [Dogtail repository](https://github.com/vhumpa/dogtail)
- [WayDriver repository](https://github.com/BohdanTkachenko/waydriver)
- [AT-SPI API](https://docs.gtk.org/atspi2/)
