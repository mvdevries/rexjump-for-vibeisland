#!/bin/zsh
set -e
cd "${0:A:h}"
rm -rf RexJump.app
mkdir -p RexJump.app/Contents/MacOS
swiftc -O -o RexJump.app/Contents/MacOS/RexJump Sources/*.swift
mkdir -p RexJump.app/Contents/Resources
cp Resources/Info.plist RexJump.app/Contents/Info.plist
cp Resources/RexJump.icns RexJump.app/Contents/Resources/RexJump.icns
codesign --force --sign - RexJump.app
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f RexJump.app
