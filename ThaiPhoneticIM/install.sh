#!/bin/bash
set -e

APP_PATH="./build/ThaiPhoneticIM.app"
SYSTEM_PATH="/Library/Input Methods/ThaiPhoneticIM.app"

if [ ! -d "$APP_PATH" ]; then
    echo "Error: Build not found. Run ./build.sh first"
    exit 1
fi

echo "Installing Thai Phonetic Input Method..."
echo ""

# Remove old installation
if [ -d "$SYSTEM_PATH" ]; then
    rm -rf "$SYSTEM_PATH"
fi

# Install to system location
cp -R "$APP_PATH" "$SYSTEM_PATH"
chown -R root:wheel "$SYSTEM_PATH"
chmod -R 755 "$SYSTEM_PATH"

# Re-register with LaunchServices
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f -R "$SYSTEM_PATH"

echo "✓ Installation complete!"
echo ""
echo "The input method has been updated."
echo "It should work immediately without logging out."
echo ""
echo "If you see duplicates in System Settings:"
echo "  1. Remove all 'Thai Phonetic' entries"
echo "  2. Close System Settings"
echo "  3. Reopen and add 'Thai Phonetic' again (should show only once)"
