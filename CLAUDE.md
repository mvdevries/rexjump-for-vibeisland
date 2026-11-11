# rex-vibe-island-jump

Swift-appje `RexJump.app` dat een klik in Vibe Island laat springen naar de juiste Rex-pane. Gebruikersdocs staan in `README.md`.

## Waar staat wat

```
.
├── Sources/                 alle Swift-code
│   ├── JumpHandler.swift    de hele sprong, van URL tot focus (begin hier)
│   ├── AppDelegate.swift    ontvangt de rexjump://-URL's
│   ├── main.swift           start de app
│   ├── JumpRequest.swift    pid en tty uit de URL
│   ├── ProcessLookup.swift  alle processen op een tty (libproc)
│   ├── RexConnection.swift  unix-socket en WebSocket, protocol rex.control.v1
│   ├── RexClient.swift      API-aanroepen: panes zoeken, focussen, session.select
│   ├── PaneMatcher.swift    vergelijkt pid's met het process-antwoord van een block
│   ├── RexApp.swift         haalt Rex Beta naar voren (bundle id staat hier)
│   ├── SingleInstance.swift voorkomt meerdere kopieën
│   └── Log.swift, Failure.swift
├── Resources/               Info.plist (bundle id nl.martyn.rexjump, URL-scheme rexjump) en RexJump.icns
├── vibe-island/rex.json     de jump rule voor ~/.vibe-island/integrations/
├── build.sh                 bouwt en ondertekent RexJump.app (genegeerd door git)
├── FEATURE-REQUEST.md       tekst voor het Rex-team (nog niet gepost)
└── icon/                    icon.png (bron van het icoon) en social-preview.png (voor GitHub)
```

## Commando's

```
./build.sh                                  bouwen (draai eerst pkill -x RexJump)
pkill -x RexJump                            draaiend appje stoppen
open "rexjump://focus?pid=&tty=%2Fdev%2Fttys001"   handmatig een sprong doen
tail -f ~/Library/Logs/rex-vibe-island-jump.log    log volgen
cp vibe-island/rex.json ~/.vibe-island/integrations/rex.json
osascript -e 'tell application "Vibe Island" to quit'; open -a "Vibe Island"   rule inladen
```

## Goed om te weten

- Vibe Island ziet Rex-sessies als `com.superlogical.rex.server` (de server). De Rex-app zelf is `com.superlogical.rex`. De rule gebruikt de eerste, `RexApp.swift` de tweede.
- Vibe Island geeft vaak geen `pid` mee maar wel een `tty`. Daarom zoekt het appje alle processen op die tty.
- Vibe Island leest rules alleen bij het opstarten.
- Het Rex-protocol staat op de server zelf: `curl --unix-socket "$HOME/Library/Application Support/rex/server.sock" http://localhost/llms.txt`. Het appje gebruikt API-revisie 10.
- Testen kan niet met een echte klik vanuit hier. Gebruik `open "rexjump://…"` en lees het log.

## Afspraken

- Nederlands, ook in commitberichten en logregels.
- Geen commentaar in de code.
- Wijzigingen via een branch en een pull request (`gh-bot pr create`), nooit direct naar `main`. Mergen alleen als Martyn dat zegt.
- Geen Claude-attributie in commits of PR-teksten.
- Het icoon is samengesteld uit de iconen van Vibe Island en Claude. Houd de repo privé, of vervang het icoon als hij ooit openbaar gaat.
