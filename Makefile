# -----------------------------------------------------------------------------
# GuiVerb (https://github.com/LionelDraghi/GuiVerb)
# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2026, Lionel Draghi
# -----------------------------------------------------------------------------

# GuiVerb — build and validation entry points.
# `make help` lists all targets and is the documentation of record.

.SILENT:

.PHONY: help build release check clean

help:
	echo "Usage: make [target]"
	echo ""
	echo "Targets:"
	echo "  build    : build guiverb in validation mode (warnings are errors)"
	echo "  release  : build guiverb in release mode"
	echo "  check    : run the test suites (bbt scenarios in tests/)"
	echo "  f005 ... : replay one scenario by id, e.g. make f005"
	echo "  clean    : remove the build and test artifacts"
	echo ""
	echo "Headless   : the browser runs headless by default. To display it,"
	echo "             run with GUIVERB_HEADED set, e.g. GUIVERB_HEADED=1 make f005;"
	echo "             remove (unset) the variable to go back to headless."
	echo ""
	echo "See AGENTS.md and docs/dev/ for more details."

build:
	echo "--- build (validation mode)"
	alr build
	echo "OK"
	echo

release:
	echo "--- build (release mode)"
	alr build --release
	echo "OK"
	echo

check: build
	echo "--- check"
	bbt --cleanup=full tests/

# Replay a single scenario by id, e.g. make f005 runs
# bbt --cleanup=full on tests/f005_*.md
f%: build
	@f=`ls tests/$@_*.md 2>/dev/null | head -1`; \
	if [ -z "$$f" ]; then \
	   echo "no test file tests/$@_*.md"; exit 1; \
	fi; \
	bbt --cleanup=full "$$f"

clean:
	echo "--- clean"
	alr clean
	rm -rf bin
	echo "OK"
