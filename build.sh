#!/bin/zsh
set -e
cd "${0:A:h}"

# Oude build opruimen en bundle-structuur aanmaken
rm -rf RexJump.app
mkdir -p RexJump.app/Contents/MacOS RexJump.app/Contents/Resources

# Swift-code compileren
swiftc -O -o RexJump.app/Contents/MacOS/RexJump Sources/*.swift

# Info.plist en icoon toevoegen
cp Resources/Info.plist RexJump.app/Contents/Info.plist
cp Resources/RexJump.icns RexJump.app/Contents/Resources/RexJump.icns

# Ondertekenen (ad-hoc)
codesign --force --sign - RexJump.app

echo "RexJump.app is gebouwd"
