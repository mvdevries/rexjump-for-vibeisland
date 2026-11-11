#!/bin/zsh
set -e
cd "${0:A:h}"

# Instellingen
app_name="VibeIsland Rex Jump"
app="$app_name.app"
app_dest="$HOME/Applications/$app"
rule_dest="$HOME/.vibe-island/integrations/rex.json"

# Bouwen als er nog geen app is
[[ -d $app ]] || ./build.sh

# Draaiende versie en oudere namen stoppen
pkill -f "$app/Contents/MacOS" || true
pkill -x RexJump || true
pkill -x VibeIslandRexJump || true

# Apps met een oudere naam verwijderen
rm -rf "$HOME/Applications/RexJump.app" "$HOME/Applications/VibeIslandRexJump.app"

# App op zijn plek zetten in ~/Applications
mkdir -p "$HOME/Applications"
rm -rf "$app_dest"
ditto "$app" "$app_dest"

# Jump rule voor Vibe Island plaatsen
mkdir -p "${rule_dest:h}"
rule_changed=true
cmp -s vibe-island/rex.json "$rule_dest" && rule_changed=false
cp vibe-island/rex.json "$rule_dest"

# App starten
open "$app_dest"

# Melden wat er is gebeurd
echo "$app_name staat in $app_dest"
echo "Jump rule staat in $rule_dest"
if $rule_changed; then
  echo "De jump rule is veranderd: herstart Vibe Island, want die leest rules alleen bij het opstarten."
fi
