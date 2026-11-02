# -----------------------------------------------------------------------------
# GuiVerb (https://github.com/LionelDraghi/GuiVerb)
# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2026, Lionel Draghi
# -----------------------------------------------------------------------------
# The reference application's local build. The GTK projection is built
# here (sub-crate with its own dependencies); the Web projection needs
# no build step.

.SILENT:

.PHONY: build clean

build:
	echo "--- witness build (GTK projection)"
	alr build
	echo "OK"

clean:
	alr clean
