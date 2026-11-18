# rexjump-for-vibeisland

Swift app `RexJump for VibeIsland.app` that makes a click in Vibe Island jump to the right Rex pane. User docs are in `README.md`.

## Structure

```
.
├── Sources/                 all Swift code
│   ├── JumpHandler.swift    the whole jump, from URL to focus (start here)
│   ├── AppDelegate.swift    receives the rexjump:// URLs
│   ├── main.swift           starts the app
│   ├── JumpRequest.swift    pid and tty from the URL
│   ├── ProcessLookup.swift  all processes on a tty (libproc)
│   ├── RexConnection.swift  unix socket and WebSocket, protocol rex.control.v1
│   ├── RexClient.swift      API calls: find panes, focus, session.select
│   ├── PaneMatcher.swift    compares pids with the process reply of a block
│   ├── RexApp.swift         brings Rex Beta to the front (bundle id is here)
│   ├── SingleInstance.swift prevents multiple copies
│   └── Log.swift, Failure.swift
├── Resources/               Info.plist (bundle id dev.de-vries.rexjumpforvibeisland, URL scheme rexjump) and "RexJump for VibeIsland.icns"
├── vibe-island/rex.json     the jump rule for ~/.vibe-island/integrations/
├── build.sh                 builds and signs RexJump for VibeIsland.app (ignored by git)
├── install.sh               puts the app in ~/Applications, the rule in ~/.vibe-island and starts the app
├── FEATURE-REQUEST.md       text for the Rex team (not posted yet)
└── icon/                    icon.svg (source), icon.png and social-preview.png (for GitHub)
```

## Commands

```
./build.sh                                           build
./install.sh                                         place the app and jump rule and start (stops the running version itself)
pkill -f "RexJump for VibeIsland.app"                stop the running app
open "rexjump://focus?pid=&tty=%2Fdev%2Fttys001"     do a jump by hand
tail -f ~/Library/Logs/rexjump-for-vibeisland.log    follow the log
osascript -e 'tell application "Vibe Island" to quit'; open -a "Vibe Island"   load the rule
```

## Good to know

- Vibe Island sees Rex sessions as `com.superlogical.rex.server` (the server). The Rex app itself is `com.superlogical.rex`. The rule uses the first, `RexApp.swift` the second.
- Vibe Island often passes no `pid` but does pass a `tty`. That is why the app looks up all processes on that tty.
- Vibe Island only reads rules at startup.
- The Rex protocol is on the server itself: `curl --unix-socket "$HOME/Library/Application Support/rex/server.sock" http://localhost/llms.txt`. The app uses API revision 10.
- A real click cannot be tested from here. Use `open "rexjump://…"` and read the log.

## Agreements

- The working language is English: code, log lines, docs, commit messages, branch names and pull requests.
- No comments in the Swift code. `build.sh` and `install.sh` do have short step headings.
- Changes go through a branch and a pull request, never directly to `main`. Merge only when the maintainer says so.
- No Claude attribution in commits or pull request texts.
- Names and logos of Vibe Island, Rex, Claude or Anthropic are not used as artwork. The icon is an original design; only plain-text mentions are allowed, with the disclaimer in `README.md`.
- No personal e-mail addresses anywhere in the repository; commits use the GitHub noreply address.
