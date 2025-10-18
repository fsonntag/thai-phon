#!/bin/bash

echo "Fixing duplicate Thai Phonetic input method entries..."
echo ""

# Kill System Settings if open
killall "System Settings" 2>/dev/null || true

# Kill Text Input services
killall TextInputMenuAgent 2>/dev/null || true

# Remove from user directory (shouldn't be there)
if [ -d ~/Library/Input\ Methods/ThaiPhoneticIM.app ]; then
    echo "Removing from user directory..."
    rm -rf ~/Library/Input\ Methods/ThaiPhoneticIM.app
fi

# Remove from build directory to prevent re-registration
if [ -d ~/Developer/thai-phon/ThaiPhoneticIM/build/ThaiPhoneticIM.app ]; then
    echo "Cleaning build directory..."
    rm -rf ~/Developer/thai-phon/ThaiPhoneticIM/build/ThaiPhoneticIM.app
fi

echo "Resetting LaunchServices database..."
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user

echo "Rebuilding LaunchServices database..."
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -seed

echo "Re-registering the input method..."
sudo /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f -R "/Library/Input Methods/ThaiPhoneticIM.app"

echo ""
echo "✓ Done!"
echo ""
echo "Now do the following:"
echo "1. Log out and log back in"
echo "2. Open System Settings > Keyboard > Input Sources"
echo "3. Remove ALL Thai Phonetic entries"
echo "4. Close System Settings"
echo "5. Open System Settings again"
echo "6. Add Thai Phonetic (should show only once now)"
