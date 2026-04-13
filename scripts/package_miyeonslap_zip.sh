#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
APP_PATH="$ROOT_DIR/MiyeonSlap.app"
ZIP_PATH="$DIST_DIR/MiyeonSlap.zip"

zsh "$ROOT_DIR/scripts/build_app_bundle.sh"

mkdir -p "$DIST_DIR"
rm -f "$ZIP_PATH"
ditto -c -k --sequesterRsrc --keepParent "$APP_PATH" "$ZIP_PATH"

shasum -a 256 "$ZIP_PATH"
