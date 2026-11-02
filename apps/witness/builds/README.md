# witness build recipes

One application, one directory, one build per platform projection:

- Web: `index.html` + JS + CSS — no build step, no dependencies, no
  framework: the runner serves it as a `file://` URL directly from
  `apps/witness/`.
- GTK4: the local sub-crate of this directory (`make -C apps/witness
  build`, `alr build` inside) — builds `bin/witness`, the binary the
  GTK backend spawns.

If a projection ever grows a real build step, add one
`builds/<platform>/` subdirectory here, each with its own build
recipe (sub-crate, dependencies, local `make`), and never commit the
outputs.
