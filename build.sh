#!/bin/zsh
set -e
cd "${0:A:h}"
rm -rf RexJump.app
mkdir -p RexJump.app/Contents/MacOS
swiftc -O -o RexJump.app/Contents/MacOS/RexJump main.swift
cp Info.plist RexJump.app/Contents/Info.plist
codesign --force --sign - RexJump.app
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f RexJump.app
