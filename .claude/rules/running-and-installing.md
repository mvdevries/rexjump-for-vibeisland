# Rule: running and installing

- **Only install and start the app when the maintainer asks.** Use `./install.sh` and restart the app after
  every code change. Do not leave `RexJump for VibeIsland.app` in the repository: it is build output.
- **Only publish a build on explicit request.** Releases are made by the release pipeline when a pull request
  is merged to `main`; do not create releases or tags by hand.
