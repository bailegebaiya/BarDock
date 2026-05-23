#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/.build/release"
APP_DIR="$ROOT_DIR/dist/BarDock.app"
CONTENTS_DIR="$APP_DIR/Contents"
MODULE_CACHE_DIR="$ROOT_DIR/.build/module-cache"

cd "$ROOT_DIR"
mkdir -p "$BUILD_DIR" "$MODULE_CACHE_DIR"
export CLANG_MODULE_CACHE_PATH="$MODULE_CACHE_DIR"
export SWIFTPM_MODULECACHE_OVERRIDE="$MODULE_CACHE_DIR"
swiftc \
  -O \
  -parse-as-library \
  -target arm64-apple-macosx13.0 \
  -module-cache-path "$MODULE_CACHE_DIR" \
  Sources/BarDock/*.swift \
  -o "$BUILD_DIR/BarDock"

swift "$ROOT_DIR/Scripts/make_icon.swift"

rm -rf "$APP_DIR"
mkdir -p "$CONTENTS_DIR/MacOS" "$CONTENTS_DIR/Resources"
cp "$BUILD_DIR/BarDock" "$CONTENTS_DIR/MacOS/BarDock"
cp "$ROOT_DIR/Packaging/Info.plist" "$CONTENTS_DIR/Info.plist"
cp "$ROOT_DIR/Assets/BarDock.icns" "$CONTENTS_DIR/Resources/BarDock.icns"

chmod +x "$CONTENTS_DIR/MacOS/BarDock"

echo "$APP_DIR"
