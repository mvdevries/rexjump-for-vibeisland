<p align="center"><img src="icon/icon.png" width="160" alt="RexJump for VibeIsland"></p>

# RexJump for VibeIsland

Click a session in [Vibe Island](https://vibeisland.app) and [Rex](https://www.superlogical.com/rex) jumps to the pane where that session runs.

Without this, Vibe Island only brings Rex to the front. With RexJump for VibeIsland you land on the right session, the right tab and the right pane, even with dozens open.

## What it does

- Jumps to the exact pane in Rex where the agent runs on a click, and brings Rex Beta to the front.
- Works for every session Vibe Island shows, as long as it runs in Rex.
- Is fast: a jump takes about 0.1 seconds.
- Does nothing when no pane belongs to the session. It never opens a new or wrong pane.
- Runs invisibly in the background, without a Dock icon, and never twice.

## Installing

You need Vibe Island 1.0.22 or newer (not the Mac App Store edition), Rex Beta and Xcode or the command line tools.

```
./install.sh
```

This builds the app if it does not exist yet, puts it in `~/Applications/RexJump for VibeIsland.app`, places the jump rule in `~/.vibe-island/integrations/rex.json` and starts the app. If the rule changed, restart Vibe Island, because it only reads its integrations at startup. The app starts by itself on the first click. The very first click after a restart of your Mac takes about half a second; after that it is instant.

When the app is in `~/Applications`, macOS also finds it through Spotlight. After a change in the code, run `./build.sh` and then `./install.sh`: the running version is stopped and replaced.

## Using it

Nothing: click a session in Vibe Island that runs in Rex.

To try it by hand, use the tty of a session:

```
open "rexjump://focus?pid=&tty=%2Fdev%2Fttys001"
```

## When it does not work

Every jump is in `~/Library/Logs/rexjump-for-vibeisland.log`:

| In the log | Meaning |
|---|---|
| no `url` line after a click | Vibe Island does not use the rule. Check that `rex.json` is in place and restart Vibe Island. |
| `done` | The jump succeeded. |
| `not found in Rex` | That session does not run in a Rex pane. Nothing was done. |
| `no pid or tty` | Vibe Island passed no data. Nothing was done. |
| `failed: …` | Something went wrong with Rex, for example a server that is not running. The message is included. |

## Uninstalling

```
pkill -f "RexJump for VibeIsland.app"
rm ~/.vibe-island/integrations/rex.json
rm -rf "$HOME/Applications/RexJump for VibeIsland.app"
```

Then restart Vibe Island.

## The icon

The icon is an original design: a grid of panes with an arrow jumping to one of them. `icon/icon.svg` is the source, `icon/icon.png` the rendered version, `Resources/RexJump for VibeIsland.icns` the app version and `icon/social-preview.png` the image for the repository on GitHub.

## Limitations

- Only Rex Beta on macOS, with Vibe Island on the same Mac.
- Rex Beta runs under the bundle id `com.superlogical.rex`. If another build ever appears, change it in `Sources/RexApp.swift`.
- The app assumes version 10 of the Rex API. A much newer Rex may need changes.
- A built-in `rex://focus` in Rex would make this unnecessary. See `FEATURE-REQUEST.md`.

## Disclaimer

RexJump for VibeIsland is an independent project. It is not affiliated with, endorsed by or sponsored by Vibe Island or Superlogical (Rex). Vibe Island and Rex are the names of their respective owners and are used here only to say what this app works with.

## License

[MIT](LICENSE)
