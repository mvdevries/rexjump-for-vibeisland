#!/bin/zsh
set -e
cd "${0:A:h}"

# Settings
app_name="RexJump for VibeIsland"
app="$app_name.app"
app_dest="$HOME/Applications/$app"
rule_dest="$HOME/.vibe-island/integrations/rex.json"

# Build if there is no app yet
[[ -d $app ]] || ./build.sh

# Stop the running version
pkill -f "$app/Contents/MacOS" || true

# Put the app in ~/Applications
mkdir -p "$HOME/Applications"
rm -rf "$app_dest"
ditto "$app" "$app_dest"

# Place the jump rule for Vibe Island
mkdir -p "${rule_dest:h}"
rule_changed=true
cmp -s vibe-island/rex.json "$rule_dest" && rule_changed=false
cp vibe-island/rex.json "$rule_dest"

# Start the app
open "$app_dest"

# Report what happened
echo "$app_name is in $app_dest"
echo "The jump rule is in $rule_dest"
if $rule_changed; then
  echo "The jump rule changed: restart Vibe Island, because it only reads rules at startup."
fi
