#!/bin/zsh
set -e
cd "${0:A:h}"

# Instellingen
app_dest="$HOME/Applications/RexJump.app"
rule_dest="$HOME/.vibe-island/integrations/rex.json"

# Bouwen als er nog geen app is
[[ -d RexJump.app ]] || ./build.sh

# Draaiende versie stoppen
pkill -x RexJump || true

# App op zijn plek zetten in ~/Applications
mkdir -p "$HOME/Applications"
rm -rf "$app_dest"
ditto RexJump.app "$app_dest"

# Jump rule voor Vibe Island plaatsen
mkdir -p "${rule_dest:h}"
rule_changed=true
cmp -s vibe-island/rex.json "$rule_dest" && rule_changed=false
cp vibe-island/rex.json "$rule_dest"

# App starten
open "$app_dest"

# Melden wat er is gebeurd
echo "RexJump staat in $app_dest"
echo "Jump rule staat in $rule_dest"
if $rule_changed; then
  echo "De jump rule is veranderd: herstart Vibe Island, want die leest rules alleen bij het opstarten."
fi
