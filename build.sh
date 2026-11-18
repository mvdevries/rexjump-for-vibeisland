#!/bin/zsh
set -e
cd "${0:A:h}"

# Settings
app_name="RexJump for VibeIsland"
app="$app_name.app"
version="${VERSION:-0.0.0-dev}"

# Clean up the old build and create the bundle structure
rm -rf "$app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"

# Compile the Swift code
swiftc -O -o "$app/Contents/MacOS/$app_name" Sources/*.swift

# Add Info.plist and icon
cp Resources/Info.plist "$app/Contents/Info.plist"
cp "Resources/$app_name.icns" "$app/Contents/Resources/$app_name.icns"

# Fill in the version
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $version" "$app/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Add :CFBundleShortVersionString string $version" "$app/Contents/Info.plist"

# Sign (ad hoc)
codesign --force --sign - "$app"

echo "$app_name $version is built"
