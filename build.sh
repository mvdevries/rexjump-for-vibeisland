#!/bin/zsh
set -e
cd "${0:A:h}"

# Instellingen
dest="$HOME/Applications/RexJump.app"
staging="$(mktemp -d)"
trap 'rm -rf "$staging"' EXIT
app="$staging/RexJump.app"

# Bundle-structuur aanmaken in een tijdelijke map
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"

# Swift-code compileren
swiftc -O -o "$app/Contents/MacOS/RexJump" Sources/*.swift

# Info.plist en icoon toevoegen
cp Resources/Info.plist "$app/Contents/Info.plist"
cp Resources/RexJump.icns "$app/Contents/Resources/RexJump.icns"

# Ondertekenen (ad-hoc)
codesign --force --sign - "$app"

# Draaiende versie stoppen
pkill -x RexJump || true

# Op zijn plek zetten in ~/Applications
mkdir -p "$HOME/Applications"
rm -rf "$dest"
ditto "$app" "$dest"

# Starten
open "$dest"
echo "RexJump staat in $dest"
