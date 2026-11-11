#!/bin/zsh
set -e
cd "${0:A:h}"

# Oude build opruimen en bundle-structuur aanmaken
rm -rf VibeIslandRexJump.app
mkdir -p VibeIslandRexJump.app/Contents/MacOS VibeIslandRexJump.app/Contents/Resources

# Swift-code compileren
swiftc -O -o VibeIslandRexJump.app/Contents/MacOS/VibeIslandRexJump Sources/*.swift

# Info.plist en icoon toevoegen
cp Resources/Info.plist VibeIslandRexJump.app/Contents/Info.plist
cp Resources/VibeIslandRexJump.icns VibeIslandRexJump.app/Contents/Resources/VibeIslandRexJump.icns

# Ondertekenen (ad-hoc)
codesign --force --sign - VibeIslandRexJump.app

echo "Vibe Island Rex Jump is gebouwd"
