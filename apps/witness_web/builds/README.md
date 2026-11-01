# witness_web build recipes

Static web application: plain HTML + JS + CSS, no build step, no
dependencies, no framework. The runner serves it as a `file://` URL
directly from the application directory (`apps/witness_web/`); no
server, no packaging, no per-platform recipe is needed.

If the application ever grows a real build step, add one
`builds/<platform>/` subdirectory per platform here, each with its own
build recipe (sub-crate, dependencies, local `make`), and never commit
the outputs.
