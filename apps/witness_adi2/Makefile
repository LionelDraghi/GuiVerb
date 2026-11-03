# -----------------------------------------------------------------------------
# GuiVerb (https://github.com/LionelDraghi/GuiVerb)
# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2026, Lionel Draghi
# -----------------------------------------------------------------------------
# The Adi2 probe projection's local build. On Windows, the SDL3 runtime
# libraries are copied next to the executable: a must for a
# development-profile load, harmless for a validation/release build
# (the stub never calls them). MSYS2_DIR overrides the default
# C:/msys64; a missing directory is skipped (the Linux/WSL chain has
# the system packages instead).

.SILENT:

.PHONY: build clean dlls

build:
	echo "--- witness_adi2 build (Adi2 probe projection)"
	alr build
	$(MAKE) dlls
	echo "OK"

dlls:
	if [ -f bin/witness_adi2.exe ] && [ -d "$(MSYS2_DIR)/mingw64/bin" ]; then \
	  for dll in "$(MSYS2_DIR)"/mingw64/bin/SDL3*.dll; do \
	    cp -n "$$dll" bin/; \
	  done; \
	fi

clean:
	alr clean
