# RexJump for VibeIsland

A macOS app in Swift that makes a click on a session in Vibe Island jump to the right pane in Rex. `README.md`
is for users and `CONTRIBUTING.md` is for contributors. The rules for working here are in `.claude/rules/`.

## Rules

Each rule is a short file in `.claude/rules/`. Follow them in every task:

- `language.md`: everything in the repository is in English.
- `comments.md`: never add comments or docstrings to code.
- `code-style.md`: small functions, plain Swift, one concern per file, never open a wrong pane.
- `testing.md`: try every change by hand with a jump and read the log.
- `git-and-pull-requests.md`: branch and pull request, branch name prefixes, squash merge, no attribution.
- `running-and-installing.md`: install and start the app only when asked, release through the pipeline.
- `no-secrets-or-personal-data.md`: no secrets, e-mail addresses or personal data in the repository.
- `no-third-party-artwork.md`: no names or logos of other products as artwork.

## Project structure

```
Sources/         All Swift code, one type or concern per file (start with JumpHandler.swift)
Resources/       Info.plist and the app icon (.icns)
vibe-island/     The jump rule for ~/.vibe-island/integrations/
assets/          Icon sources and rendered icon, README header (1280x400) and social preview (1280x640)
.github/         Workflows (pull request, release) and Dependabot
build.sh         Builds and signs the app and fills in VERSION (the result is ignored by git)
dmg.sh           Puts the built app in a disk image (RexJump-for-VibeIsland-<version>.dmg) with an Applications shortcut
install.sh       Puts the app in ~/Applications, the rule in ~/.vibe-island and starts the app
```

## Commands

| Task | Command |
|---|---|
| Set up | Nothing: macOS with Xcode or the command line tools is enough |
| Build | `./build.sh` (`VERSION=1.2.3 ./build.sh` fills in a version) |
| Disk image | `VERSION=1.2.3 ./dmg.sh` (builds the app first if needed) |
| Install and start | `./install.sh` (stops the running version itself) |
| Stop | `pkill -f "RexJump for VibeIsland.app"` |
| Try a jump | `open "rexjump://focus?pid=&tty=%2Fdev%2Fttys001"` |
| Follow the log | `tail -f ~/Library/Logs/rexjump-for-vibeisland.log` |
| Load the rule | `osascript -e 'tell application "Vibe Island" to quit'; open -a "Vibe Island"` |
| Deploy | Merge a pull request to `main`; the release pipeline does the rest |

Deploying: `.github/workflows/release.yml` runs on every merge to `main` that changes the app (not only docs,
assets or workflows) and can be started by hand. It determines the version from the branch name of the merged
pull request, runs the checks, builds the app with that version, puts it in a disk image and creates a tag and GitHub release with the disk image
and `rex.json`. The version in `Info.plist` is filled in during the build and not committed.

## Architecture

A jump is a straight line through small files:

- `AppDelegate` receives the `rexjump://` URL and `JumpRequest` reads the pid and tty from it.
- `ProcessLookup` lists all processes on the tty, `RexClient` asks Rex for its panes, `PaneMatcher` finds the
  pane and `RexClient` focuses it. `JumpHandler` ties this together.
- `RexConnection` speaks protocol `rex.control.v1` over the unix socket and a WebSocket, API revision 10. The
  protocol is described by the server itself:
  `curl --unix-socket "$HOME/Library/Application Support/rex/server.sock" http://localhost/llms.txt`.
- `RexApp` brings Rex Beta to the front, `SingleInstance` prevents multiple copies and `Log` writes
  `~/Library/Logs/rexjump-for-vibeisland.log`.

Things to know:

- Vibe Island sees Rex sessions as `com.superlogical.rex.server` (the server). The Rex app itself is
  `com.superlogical.rex`. The rule uses the first, `RexApp.swift` the second.
- Vibe Island often passes no `pid` but does pass a `tty`. That is why the app looks up all processes on that tty.
- Vibe Island only reads rules at startup. Restart it after the rule changed.
- The bundle id is `dev.de-vries.rexjumpforvibeisland`; the URL scheme `rexjump` is what the jump rule uses.
- A jump without a matching pane does nothing and never opens a new pane.

## Pipelines

- Pull requests run a branch name check and a build validation: Info.plist and the jump rule are validated, the
  app is built, signed and verified, and the built app is uploaded as an artifact.
- Dependabot groups minor and patch updates of the GitHub Actions in one pull request and major updates in a
  separate one.
- The app is signed ad hoc and not notarized, so a downloaded copy needs
  `xattr -dr com.apple.quarantine` on the first start (see `README.md`).
