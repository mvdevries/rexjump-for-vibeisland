# RexJump for VibeIsland

A small macOS app in Swift that makes a click on a session in Vibe Island jump to the right pane in Rex. See
`README.md` for the structure and the commands. The rules for working in this repository are in `.claude/rules/`.

## Agreements

- **The working language is English**, see `.claude/rules/language.md`.
- **Never write comments in code**, see `.claude/rules/comments.md`. Let the code explain itself with small
  functions and descriptive names: too verbose is better than not clear enough.
- **No personal data and no third-party artwork**, see `.claude/rules/privacy.md`.
- Keep functions small and let them do one thing. A name describes what the function does.
- Plain Swift without dependencies, built with `swiftc` through `build.sh`.
- Changes go through a branch and a pull request, never directly to `main`. Merge only when the maintainer
  says so. No `Co-Authored-By` or other Claude attribution in commits and pull requests.
- Only install and start the app (`./install.sh`) when the maintainer asks, and restart it after every code change.
- Nothing is published or released without an explicit request.
- Test a jump with `open "rexjump://focus?pid=&tty=%2Fdev%2Fttys001"` and read the log; a real click cannot be
  tested from the terminal.

## Structure

```
Sources/        all Swift code, one type or concern per file (start with JumpHandler.swift)
Resources/      Info.plist and the app icon (.icns)
vibe-island/    the jump rule for ~/.vibe-island/integrations/
icon/           icon.svg (source), icon.png and social-preview.png
build.sh        builds and signs the app (the result is ignored by git)
install.sh      puts the app in ~/Applications, the rule in ~/.vibe-island and starts the app
```

The flow is: `AppDelegate` receives the `rexjump://` URL, `JumpRequest` reads the pid and tty, `ProcessLookup`
lists all processes on the tty, `RexClient` asks Rex for the panes, `PaneMatcher` finds the pane and `RexClient`
focuses it. `JumpHandler` ties this together.

## Things you need to know

- Vibe Island sees Rex sessions as `com.superlogical.rex.server` (the server). The Rex app itself is
  `com.superlogical.rex`. The rule uses the first, `RexApp.swift` the second.
- Vibe Island often passes no `pid` but does pass a `tty`. That is why the app looks up all processes on that tty.
- Vibe Island only reads rules at startup. Restart it after the rule changed.
- The Rex protocol is on the server itself:
  `curl --unix-socket "$HOME/Library/Application Support/rex/server.sock" http://localhost/llms.txt`. The app
  speaks protocol `rex.control.v1` and uses API revision 10.
- The bundle id is `dev.de-vries.rexjumpforvibeisland`; the URL scheme `rexjump` is what the jump rule uses.
- The log is `~/Library/Logs/rexjump-for-vibeisland.log`. A jump without a matching pane does nothing and never
  opens a new pane.
