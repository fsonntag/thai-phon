# Xcode Project Setup Instructions

Since Xcode project files are complex binary/XML structures that are best created using Xcode itself, follow these steps to create the project:

## Quick Setup (10 minutes)

### Step 1: Create New Xcode Project

1. Open Xcode
2. File → New → Project
3. Choose **iOS → App**
4. Configure:
   - **Product Name**: `ThaiPhoneticKeyboard`
   - **Team**: Select your team
   - **Organization Identifier**: `com.fsonntag`
   - **Bundle Identifier**: `com.fsonntag.ThaiPhoneticKeyboard`
   - **Interface**: SwiftUI
   - **Language**: Swift
   - **Minimum Deployment**: iOS 18.0
5. Save to: `/Users/fsonntag/Developer/thai-phon/ThaiPhoneticKeyboard/`

### Step 2: Add Keyboard Extension Target

1. File → New → Target
2. Choose **iOS → Custom Keyboard Extension**
3. Configure:
   - **Product Name**: `ThaiKeyboardExtension`
   - **Team**: Same as app
   - **Language**: Swift
   - **Embed in Application**: ThaiPhoneticKeyboard
4. Click **Finish**
5. Click **Activate** when prompted

### Step 3: Configure Project Settings

#### Main App Target (`ThaiPhoneticKeyboard`)

1. Select project in Navigator
2. Select `ThaiPhoneticKeyboard` target
3. **General** tab:
   - Set **Minimum Deployment**: iOS 18.0
   - Set **Bundle Identifier**: `com.fsonntag.ThaiPhoneticKeyboard`
4. **Signing & Capabilities**:
   - Select your Development Team
   - Enable Automatic Signing

#### Keyboard Extension Target (`ThaiKeyboardExtension`)

1. Select `ThaiKeyboardExtension` target
2. **General** tab:
   - Set **Minimum Deployment**: iOS 18.0
   - Set **Bundle Identifier**: `com.fsonntag.ThaiPhoneticKeyboard.extension`
3. **Signing & Capabilities**:
   - Select your Development Team
   - Enable Automatic Signing
4. **Build Settings**:
   - Search for "Swift Language Version"
   - Set to **Swift 5**

### Step 4: Add Source Files

#### Main App Files

Delete the default files and add our files:

1. **Delete**: `ContentView.swift` (default), `ThaiPhoneticKeyboardApp.swift` (default)
2. **Add to ThaiPhoneticKeyboard group**:
   - `ThaiPhoneticKeyboard/ThaiPhoneticKeyboardApp.swift` ✅
   - `ThaiPhoneticKeyboard/ContentView.swift` ✅
   - `ThaiPhoneticKeyboard/TutorialView.swift` ✅
   - `ThaiPhoneticKeyboard/Info.plist` ✅

**Drag these files from Finder into the ThaiPhoneticKeyboard group in Xcode**

#### Keyboard Extension Files

Delete the default `KeyboardViewController.swift` and add our files:

1. **Delete**: `KeyboardViewController.swift` (default)
2. **Create groups** in `ThaiKeyboardExtension`:
   - Views
   - Engine
   - Models
   - Resources

3. **Add to ThaiKeyboardExtension**:
   - `KeyboardViewController.swift` ✅ (root)
   - **Views/**:
     - `CandidateBar.swift` ✅
     - `KeyboardLayoutView.swift` ✅
     - `KeyButtonView.swift` ✅
   - **Engine/**:
     - `ThaiPhoneticEngine.swift` ✅
     - `DictionaryLoader.swift` ✅
     - `FuzzyMatching.swift` ✅
   - **Models/**:
     - `KeyboardState.swift` ✅
   - **Resources/**:
     - `dictionary.json` ✅ (important: check "Copy items if needed")
     - `ngram_frequencies.json` ✅ (important: check "Copy items if needed")
   - `Info.plist` ✅ (replace default)

#### Shared Files

1. **Create group**: `Shared` (at project root level)
2. **Add to Shared**:
   - `Shared/Constants.swift` ✅
   - `Shared/Extensions.swift` ✅
3. **Configure target membership**:
   - Select each file in `Shared`
   - In File Inspector (right panel), check BOTH:
     - ☑️ ThaiPhoneticKeyboard
     - ☑️ ThaiKeyboardExtension

### Step 5: Verify Build Phases

#### Keyboard Extension Target

1. Select `ThaiKeyboardExtension` target
2. Go to **Build Phases** tab
3. Expand **Copy Bundle Resources**
4. **Verify these files are included**:
   - `dictionary.json` ✅
   - `ngram_frequencies.json` ✅

If missing, click **+** and add them.

### Step 6: Update Info.plist References

If Xcode doesn't automatically recognize the Info.plist files:

1. Select `ThaiPhoneticKeyboard` target
2. **Build Settings** tab
3. Search for **"Info.plist"**
4. Set **Info.plist File** to: `ThaiPhoneticKeyboard/Info.plist`

Repeat for `ThaiKeyboardExtension` target:
- Set to: `ThaiKeyboardExtension/Info.plist`

### Step 7: Build and Run

1. Select a simulator (iPhone 15 Pro) or connected device
2. Select `ThaiPhoneticKeyboard` scheme
3. Press **Cmd+R** to build and run
4. If successful, the app launches showing the welcome screen

### Step 8: Enable Keyboard

On the device/simulator:
1. Settings → General → Keyboard → Keyboards
2. Add New Keyboard...
3. Select "Thai Phonetic"
4. Test in Notes or Messages

## Troubleshooting

### Build Errors

**"No such module 'SwiftUI'"**
- Solution: Set deployment target to iOS 18.0 in both targets

**"Cannot find 'AppConstants' in scope"**
- Solution: Verify `Shared/Constants.swift` has both targets checked in File Inspector

**"Could not find resource bundle"**
- Solution: Verify dictionary files are in "Copy Bundle Resources" for keyboard extension target

**"Multiple commands produce Info.plist"**
- Solution: Ensure only one Info.plist per target, and set path correctly in Build Settings

### Runtime Errors

**Keyboard doesn't show in Settings**
- Check bundle IDs:
  - App: `com.fsonntag.ThaiPhoneticKeyboard`
  - Extension: `com.fsonntag.ThaiPhoneticKeyboard.extension`
- Check `Info.plist` has `NSExtensionPointIdentifier = com.apple.keyboard-service`

**No candidates showing**
- Check Xcode console for loading errors
- Verify dictionary files are included in extension target

## Alternative: Command-Line Build

If you prefer command-line tools:

```bash
# Build using xcodebuild (after creating project in Xcode)
cd ThaiPhoneticKeyboard
xcodebuild -project ThaiPhoneticKeyboard.xcodeproj \
           -scheme ThaiPhoneticKeyboard \
           -sdk iphoneos \
           -configuration Release \
           clean build
```

## Next Steps

After successful build:
1. Test on device
2. Use Instruments to check memory usage
3. Test in various apps (Messages, Notes, Safari)
4. Submit to App Store (see README.md)
