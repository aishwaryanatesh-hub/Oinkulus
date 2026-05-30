#!/usr/bin/env bash
#
# Build Oinkulus and package it as a distributable DMG.
#
#   ./scripts/release.sh            # unsigned DMG ($0, no Apple account)
#   NOTARIZE=1 ./scripts/release.sh # signed + notarized DMG (needs Apple Developer Program)
#
# Run from the repo root.
set -euo pipefail

APP="Oinkulus"
SCHEME="Overlay"
PROJECT="Overlay.xcodeproj"
NOTARIZE="${NOTARIZE:-0}"
NOTARY_PROFILE="${NOTARY_PROFILE:-oinkulus-notary}"

cd "$(dirname "$0")/.."
rm -rf build
mkdir -p build

if [[ "$NOTARIZE" == "1" ]]; then
  # --- Signed + notarized path (requires Developer ID cert + ENABLE_HARDENED_RUNTIME=YES) ---
  echo "==> Archiving (Developer ID)…"
  xcodebuild -project "$PROJECT" -scheme "$SCHEME" -configuration Release \
    -archivePath "build/$APP.xcarchive" archive

  echo "==> Exporting…"
  xcodebuild -exportArchive -archivePath "build/$APP.xcarchive" \
    -exportOptionsPlist ExportOptions.plist -exportPath build/export
  APP_PATH="build/export/$APP.app"
else
  # --- Unsigned path (Xcode ad-hoc "Sign to Run Locally") ---
  echo "==> Building Release (unsigned)…"
  xcodebuild -project "$PROJECT" -scheme "$SCHEME" -configuration Release \
    -derivedDataPath build/dd build
  APP_PATH="build/dd/Build/Products/Release/$APP.app"
fi

echo "==> Creating DMG…"
mkdir -p build/dmg
cp -R "$APP_PATH" build/dmg/
ln -s /Applications build/dmg/Applications
hdiutil create -volname "$APP" -srcfolder build/dmg -ov -format UDZO "build/$APP.dmg"

if [[ "$NOTARIZE" == "1" ]]; then
  echo "==> Notarizing…"
  xcrun notarytool submit "build/$APP.dmg" --keychain-profile "$NOTARY_PROFILE" --wait
  xcrun stapler staple "build/$APP.dmg"
  echo "==> Notarized & stapled."
fi

echo "==> Done: build/$APP.dmg"
