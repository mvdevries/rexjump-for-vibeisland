# Feature request: `rex://focus` URL for jumping to a pane

**Platform:** macOS (Rex Beta)

## What
A `rex://focus?pid=…&cwd=…` URL that makes Rex Beta select the session/tab/pane running that process.

## Why
Vibe Island (notch app for AI coding sessions) supports "custom jump rules": a JSON file with a bundle id and a URL template. On click it brings the app forward and opens the URL with `{pid}`, `{tty}`, `{cwd}`, `{session_id}` filled in. The terminal is expected to route that to the right pane. Rex already registers the `rex://` scheme (only `rex://settings/server` seems to be handled today), so a native `rex://focus` would make this work without helper apps.

## Proposal
- `rex://focus?pid=<pid>`: find the block whose `block.process` has `foreground.pid`, `child.pid` or any `ancestors[].pid` equal to `pid`; then `session.focus_block` + `session.select`.
- Optional fallbacks: `block=<block id>`, `cwd=<path>` (last resort only).
- No match: do nothing (don't open a new pane).

## Prototype
Works today with a helper app that talks to the control WebSocket (`/api/control`) directly (`session.list`, `session.list_blocks`, `block.method process`, `session.focus_block`, client action `session.select`); a full sweep takes about 3 ms. See `Sources/` in this repo.

## Open question
Vibe Island matches on the terminal's bundle id and sees Rex sessions as `com.superlogical.rex.server` (not `com.superlogical.rex`), because shells run under the Rex server. A `rex.json` rule has to use that id today; a native handler would need to be registered for it.
