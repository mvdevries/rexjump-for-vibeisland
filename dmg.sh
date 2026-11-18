#!/bin/zsh
set -e
cd "${0:A:h}"

app_name="RexJump for VibeIsland"
app="$app_name.app"
version="${VERSION:-0.0.0-dev}"
dmg="RexJump-for-VibeIsland-$version.dmg"
staging="$(mktemp -d)"

[[ -d $app ]] || ./build.sh

ditto "$app" "$staging/$app"
ln -s /Applications "$staging/Applications"

rm -f "$dmg"
hdiutil create -volname "$app_name" -srcfolder "$staging" -ov -format UDZO "$dmg" > /dev/null
rm -rf "$staging"

echo "$dmg is created"
