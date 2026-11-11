# rex-vibe-island-jump

Laat een klik op een sessie in [Vibe Island](https://vibeisland.app) springen naar de juiste pane in [Rex](https://www.superlogical.com/rex).

Vibe Island kent voor Rex alleen de standaardsprong: de app naar voren halen. Met een [custom jump rule](https://vibeisland.app/docs/custom-jump-rules/) opent Vibe Island bij een klik een URL met de sessiegegevens. `RexJump.app` ontvangt die URL, zoekt de bijbehorende Rex-pane en focust die.

## Hoe het werkt

1. Vibe Island ziet Rex-sessies onder de bundle id `com.superlogical.rex.server` en opent bij een klik de URL uit `vibe-island/rex.json`: `rexjump://focus?session=…&tty=…&pid=…&cwd=…&bundle=…`.
2. `RexJump.app` is een klein achtergrondappje dat het scheme `rexjump://` afhandelt. Het heeft geen venster of dockicoon.
3. Het appje verzamelt de pid's uit de URL, en bij een `tty` ook alle processen op die tty (via libproc).
4. Het verbindt met de unix-socket van de Rex-server (`~/Library/Application Support/rex/server.sock`) en praat het besturingsprotocol `rex.control.v1` (WebSocket op `/api/control`): `hello`, `session.attach_all`, daarna alle sessies en panes langs met `session.list`, `session.list_blocks` en `block.method process`.
5. Is er een pane waarvan de `foreground`-, `child`- of `ancestors`-pid overeenkomt, dan volgen `session.focus_block` en `client.perform` met `session.select`. Daarna haalt het appje Rex Beta naar voren.
6. Zonder match gebeurt er niets: er wordt nooit een nieuwe of andere pane geopend.

Een klik duurt ongeveer 0,1 s, waarvan het zoeken zelf enkele milliseconden is.

## Opbouw

- `Sources/main.swift` en `AppDelegate.swift`: start van het appje en ontvangst van de URL's.
- `JumpRequest.swift` en `ProcessLookup.swift`: pid's uit de URL, en alle processen op een tty.
- `RexConnection.swift`: socket, WebSocket-framing en `hello`. `RexClient.swift`: de API-aanroepen. `PaneMatcher.swift`: de vergelijking van pid's met het `process`-antwoord.
- `JumpHandler.swift`: de hele sprong, van URL tot focus. `RexApp.swift`: Rex Beta naar voren halen.
- `SingleInstance.swift`: voorkomt dat er meerdere kopieën naast elkaar blijven draaien. Een tweede kopie handelt de URL's af die hij zelf kreeg en sluit zich daarna af.
- `Resources/Info.plist`: bundle id en het URL-scheme `rexjump`.

## Installeren

Vereist Vibe Island 1.0.22 of nieuwer (niet de Mac App Store-editie), Rex Beta en Xcode of de command line tools.

```
./build.sh
cp vibe-island/rex.json ~/.vibe-island/integrations/rex.json
```

Herstart daarna Vibe Island, want die leest de integraties alleen bij het opstarten. `build.sh` compileert het appje, ondertekent het ad hoc en meldt het aan bij macOS. Het appje wordt bij de eerste klik vanzelf gestart en blijft daarna actief.

Het appje staat op de plek waar je het bouwt. Verplaats je de map, draai dan `./build.sh` opnieuw.

## Controleren

Een sprong handmatig proberen, met de tty van een Claude-sessie in Rex:

```
open "rexjump://focus?pid=&tty=%2Fdev%2Fttys001"
```

Elke sprong staat in `~/Library/Logs/rex-vibe-island-jump.log`, met `match`, `klaar` of de reden dat er niets gebeurde.

## Beperkingen

- De bundle id `com.superlogical.rex.server` en de Rex-app `com.superlogical.rex` staan vast in `vibe-island/rex.json` en `Sources/RexApp.swift`.
- Het appje gaat uit van API-revisie 10 van Rex. Een veel nieuwere Rex kan aanpassing vragen; fouten staan als `mislukt: …` in het log.
- Een native `rex://focus` in Rex zou dit overbodig maken. Zie `FEATURE-REQUEST.md`.
