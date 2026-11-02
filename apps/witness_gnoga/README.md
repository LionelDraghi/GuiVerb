# witness_gnoga build notes <!-- omit from toc -->

The Gnoga projection of the reference application, for the Web
backend: a long-running HTTP server whose DOM is built client-side.

## Prerequisites

- Alire crate: `gnoga ^2.2.3` (pulls Simple Components and UxStrings).
- System packages: none needed for this minimal app. Alire warns that
  `libgnutls` and `unixodbc` are missing (HTTPS and database features,
  not exercised here); install `libgnutls28-dev` and `unixodbc-dev` if
  you want the warnings gone.

## Layout

```
apps/witness_gnoga/
  src/witness_gnoga.adb     application
  html/boot.html            boot page (from the gnoga templates)
  js/boot.js, jquery.min.js served assets (from the gnoga templates)
  serve                     server launcher: prints the URL to
                            /tmp/guiverb-serve.url, then execs
                            bin/witness_gnoga
  bin/witness_gnoga         built locally, never committed
```

## Automation notes

- The served page is an empty boot frame; the DOM is built once the
  WebSocket connects, so the backend navigates and then waits — it
  must not expect the content to be there at navigation time.
- The application is per-connection: elements are created on connect;
  run one connection per scenario (the runner kills the process
  between scenarios — also a requirement of the second-connection
  Object_Already_Created failure mode).
- Port 8080 is fixed in the launcher and the application default;
  two instances cannot run at the same time.
