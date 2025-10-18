#!/bin/bash
set -e

echo "Building Thai Phonetic Input Method..."

# Project paths
PROJECT_DIR="/Users/fsonntag/Developer/thai-phon/ThaiPhoneticIM"
BUILD_DIR="$PROJECT_DIR/build"
APP_NAME="ThaiPhoneticIM.app"
INSTALL_DIR="$HOME/Library/Input Methods"

# Clean previous build
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Compile Swift files
echo "Compiling Swift sources..."
swiftc \
    -target arm64-apple-macos11.0 \
    -framework Cocoa \
    -framework InputMethodKit \
    -o "$BUILD_DIR/ThaiPhoneticIM" \
    "$PROJECT_DIR/main.swift" \
    "$PROJECT_DIR/ThaiPhoneticIMController.swift" \
    "$PROJECT_DIR/ThaiCandidateWindow.swift"

# Create app bundle structure
echo "Creating app bundle..."
APP_PATH="$BUILD_DIR/$APP_NAME"
mkdir -p "$APP_PATH/Contents/MacOS"
mkdir -p "$APP_PATH/Contents/Resources"

# Copy executable
cp "$BUILD_DIR/ThaiPhoneticIM" "$APP_PATH/Contents/MacOS/"

# Copy Info.plist
cp "$PROJECT_DIR/Info.plist" "$APP_PATH/Contents/"

# Copy dictionary
cp "$PROJECT_DIR/dictionary.json" "$APP_PATH/Contents/Resources/"

# Copy icon
cp "$PROJECT_DIR/ThaiPhonetic.tiff" "$APP_PATH/Contents/Resources/"

# Set permissions
chmod +x "$APP_PATH/Contents/MacOS/ThaiPhoneticIM"

# Code sign the app (ad-hoc signing for local development)
echo "Code signing..."
codesign --force --deep --sign - "$APP_PATH"

echo "Build complete: $APP_PATH"

echo ""
echo "✓ Build complete!"
echo ""
echo "To install, run:"
echo "  sudo ./install.sh"
