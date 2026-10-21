# Pilot Targets

## Matrix

| Criterion | Web / DOM | GTK / AT-SPI | Adi2 | raygui |
|---|---|---|---|---|
| Observation | DOM plus accessibility representation | External accessibility tree | Retained toolkit tree | Per-frame reconstruction |
| Boundary | External backend | External backend over D-Bus | In-process probe preferred | Instrumented in-process shim |
| Natural action | Browser automation | AT-SPI semantic action or system input | Toolkit or SDL/system input | Instrumented action or SDL/system input |
| Intrusiveness | Low | Low for observation | Medium | High |
| Production binary | Normally unchanged | Normally unchanged | Probe-enabled, to verify | Instrumented build likely |
| Main risk | CSS/XPath leakage | Environment and Wayland complexity | Toolkit API coupling | Identity, focus, text, frame synchronisation |
| MVP position | Include, probably first | Include | Experimental inclusion | Feasibility gate |

## Web

External browser backend. Canonical semantics cross the protocol; DOM nodes, CSS, XPath, and JavaScript handles remain private.

Work: compare Playwright and WebDriver/BiDi; implement snapshot, lookup, action, waits, and diagnostics; validate frames, shadow DOM, pages, and dialogs.

## GTK / AT-SPI

External backend based on `libatspi`. D-Bus names and AT-SPI object paths are opaque correlation tokens.

Work: canonical tree dump; event monitor; semantic action versus system input; reproducible local and headless profiles.

## Adi2

Used specifically to measure intrusiveness. Audit existing widget and MCP surfaces before introducing a new probe.

Work: tree enumeration; semantic mapping; probe lifecycle; toolkit action versus SDL/system input; exact record of source, build, and runtime differences.

## raygui

Immediate-mode hard case. Instrument control calls and emit one semantic generation per completed frame.

Work: minimal wrappers; identity and semantic keys; frame snapshots; button and text-entry actions; focus, pop-ups, repeated labels, and reordered controls.

## MVP gate

Keep raygui in the MVP only if semantic reconstruction remains localised. Otherwise retain immediate mode as an explicit post-MVP target rather than weakening the common model.
