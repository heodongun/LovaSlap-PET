#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
EXECUTABLE_NAME="LovaSlapPET"
PUBLIC_APP_NAME="LovaSlap-PET"
BUILD_DIR="$ROOT_DIR/.build/debug"
BUNDLE_DIR="$ROOT_DIR/$PUBLIC_APP_NAME.app"
CONTENTS_DIR="$BUNDLE_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
ICON_PATH="$ROOT_DIR/Assets/AppIcon/LovaSlap-PET.icns"

swift build --package-path "$ROOT_DIR" --product "$EXECUTABLE_NAME"

rm -rf "$BUNDLE_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"
cp "$BUILD_DIR/$EXECUTABLE_NAME" "$MACOS_DIR/$PUBLIC_APP_NAME"
chmod +x "$MACOS_DIR/$PUBLIC_APP_NAME"

if [[ -f "$ICON_PATH" ]]; then
    cp "$ICON_PATH" "$RESOURCES_DIR/LovaSlap-PET.icns"
fi

cat > "$CONTENTS_DIR/Info.plist" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>LovaSlap-PET</string>
    <key>CFBundleIdentifier</key>
    <string>com.heodongun.lovaslappet</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleIconFile</key>
    <string>LovaSlap-PET.icns</string>
    <key>CFBundleDisplayName</key>
    <string>LovaSlap-PET</string>
    <key>CFBundleName</key>
    <string>LovaSlap-PET</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>0.3.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
EOF

printf 'Built app bundle at %s\n' "$BUNDLE_DIR"
