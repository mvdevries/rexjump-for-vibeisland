# Security policy

## Supported versions

Only the latest released version of RexJump for VibeIsland receives security fixes.

## Reporting a vulnerability

Please do not open a public issue for a security problem.

Report it privately through GitHub: open the **Security** tab of this repository and choose
**Report a vulnerability**. Include what you found, the version of the app, and the steps to reproduce it.

This is a hobby project maintained in spare time. You can expect an acknowledgement within a week and an
update on the fix as soon as there is one. Once a fix is released, the report can be made public together
with credit to you, if you want that.

## What is in scope

- The app code in this repository, including the handling of `rexjump://` URLs and the connection to the Rex
  server.
- The install script and the jump rule that are placed on your Mac.

## What is out of scope

- Vulnerabilities in Vibe Island, Rex, macOS or other software themselves; report those to their
  maintainers. Dependency updates are handled by Dependabot.
- Problems that need a malicious process that already runs as you on the same Mac, since it could talk to the
  Rex server itself.
