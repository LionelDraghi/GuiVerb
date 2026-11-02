# -----------------------------------------------------------------------------
# GuiVerb (https://github.com/LionelDraghi/GuiVerb)
# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2026, Lionel Draghi
# -----------------------------------------------------------------------------

# GuiVerb — build and validation entry points.
# `make help` lists all targets and is the documentation of record.

.SILENT:

.PHONY: help build release check check-gtk check-gnoga gtk gnoga step clean

help:
	echo "Usage: make [target]"
	echo ""
	echo "Targets:"
	echo "  build    : build guiverb in validation mode (warnings are errors)"
	echo "  release  : build guiverb in release mode"
	echo "  check    : run the shared scenario suite (tests/scenarios/),"
	echo "             with the guiverb runner (default: web backend,"
	echo "             default app witness)"
	echo "  gtk      : build the reference application's GTK projection"
	echo "             (apps/witness sub-crate)"
	echo "  gnoga    : build the reference application's Gnoga projection"
	echo "             (apps/witness_gnoga sub-crate)"
	echo ""
	echo "Backends   : select the observation chain with GUIVERB_BACKEND or"
	echo "             --backend=web|gtk (default web). The application is"
	echo "             resolved from the scenario name, in apps/<name>/ —"
	echo "             Web: index.html, or serve for a server application"
	echo "             (spawns it, waits for its URL, kills it); GTK:"
	echo "             bin/<name>, run with GTK_A11Y=atspi (set by the backend)."
	echo "             GUIVERB_APP overrides the application the scenario"
	echo "             names: GUIVERB_APP=witness_gnoga make check-gnoga."
	echo "  check-gtk   : run the shared suite against the GTK projection"
	echo "                (fails until F010-F020 have a GTK backend: red"
	echo "                is the conformance matrix status, kept visible)"
	echo "  check-gnoga : run the shared suite against the Gnoga projection"
	echo "  f005 ... : replay one feature's scenarios by id, e.g. make f020"
	echo "  step     : interactive step-by-step replay, e.g. make step"
	echo "             STEP=f005 for one scenario, bare make step for the"
	echo "             whole suite (the browser is displayed)"
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
	@status=0; \
	for f in tests/scenarios/*.md; do \
	   echo ""; \
	   echo "--- $$f"; \
	   bin/guiverb "$$f" || status=1; \
	done; \
	if [ $$status -ne 0 ]; then \
	   echo ""; \
	   echo "check FAILED"; exit 1; \
	fi; \
	echo ""; \
	echo "check OK"

# Build the GTK reference application (self-contained sub-crate with
# its own dependencies and local make).
gtk:
	make -C apps/witness build

# Run the shared suite against the GTK projection (same scenarios,
# same vocabulary — S001). Expected red while F010-F020 have no GTK
# implementation: the failure is the conformance matrix status.
check-gtk: build gtk
	GUIVERB_BACKEND=gtk $(MAKE) check

# Build the Gnoga reference application, then run the shared suite
# against it (same scenarios, same vocabulary — S001).
check-gnoga: build gnoga
	GUIVERB_BACKEND=web GUIVERB_APP=witness_gnoga $(MAKE) check

gnoga:
	make -C apps/witness_gnoga build

# Replay every scenario of one feature, e.g. make f020 runs the f020
# scenarios of all reference applications.
f%: build
	@status=0; found=0; \
	for f in tests/scenarios/$@*.md; do \
	   if [ ! -e "$$f" ]; then continue; fi; \
	   found=1; \
	   echo "--- $$f"; \
	   bin/guiverb "$$f" || status=1; \
	done; \
	if [ $$found -eq 0 ]; then \
	   echo "no scenario matching tests/scenarios/$@*.md"; exit 1; \
	fi; \
	if [ $$status -ne 0 ]; then echo "FAILED"; exit 1; fi

# Interactive step-by-step replay: make step STEP=f005 replays one
# scenario, bare make step replays the whole suite; guiverb shows each
# upcoming step and waits for Enter before running it. The browser is
# displayed.
step: build
	@if [ -n "$(STEP)" ]; then \
	   f=`ls tests/scenarios/$(STEP)*.md 2>/dev/null | head -1`; \
	   if [ -z "$$f" ]; then \
	      echo "no scenario matching tests/scenarios/$(STEP)*.md"; exit 1; \
	   fi; \
	   echo "--- step-by-step replay of $$f (browser displayed)"; \
	   GUIVERB_HEADED=1 bin/guiverb --step "$$f"; \
	   exit $$?; \
	fi; \
	echo "--- step-by-step replay of the whole suite (browser displayed)"; \
	for f in tests/scenarios/*.md; do \
	   echo ""; echo "--- $$f"; \
	   GUIVERB_HEADED=1 bin/guiverb --step "$$f" || exit 1; \
	done

clean:
	echo "--- clean"
	alr clean
	rm -rf bin
	echo "OK"
