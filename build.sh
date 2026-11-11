#!/bin/zsh
set -e
cd "${0:A:h}"

# Instellingen
app_name="VibeIsland Rex Jump"
app="$app_name.app"

# Oude build opruimen en bundle-structuur aanmaken
rm -rf "$app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"

# Swift-code compileren
swiftc -O -o "$app/Contents/MacOS/$app_name" Sources/*.swift

# Info.plist en icoon toevoegen
cp Resources/Info.plist "$app/Contents/Info.plist"
cp "Resources/$app_name.icns" "$app/Contents/Resources/$app_name.icns"

# Ondertekenen (ad-hoc)
codesign --force --sign - "$app"

echo "$app_name is gebouwd"
