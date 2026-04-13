#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
APP_PATH="$ROOT_DIR/LovaSlap-PET.app"
DMG_PATH="$DIST_DIR/LovaSlap-PET.dmg"
STAGING_DIR="$DIST_DIR/dmg-staging"

zsh "$ROOT_DIR/scripts/build_app_bundle.sh"

mkdir -p "$DIST_DIR"
rm -rf "$STAGING_DIR"
rm -f "$DMG_PATH" "$DIST_DIR/MiyeonSlap.dmg"

mkdir -p "$STAGING_DIR"
cp -R "$APP_PATH" "$STAGING_DIR/LovaSlap-PET.app"
ln -s /Applications "$STAGING_DIR/Applications"

hdiutil create -volname "LovaSlap-PET" -srcfolder "$STAGING_DIR" -ov -format UDZO "$DMG_PATH" >/tmp/lovaslap-pet-dmg.log
rm -rf "$STAGING_DIR"

shasum -a 256 "$DMG_PATH"
