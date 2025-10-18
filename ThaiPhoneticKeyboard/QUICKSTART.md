# Quick Start Guide

Get the Thai Phonetic Keyboard running on your iPhone/iPad in 15 minutes.

## Prerequisites

- Mac with Xcode 15+ installed
- iOS device running iOS 18.0+ or simulator
- Apple Developer account (free account works for testing)

## Step-by-Step Setup

### 1. Create Xcode Project (5 minutes)

All source files are ready. You just need to create the Xcode project:

```bash
# Navigate to project directory
cd /Users/fsonntag/Developer/thai-phon/ThaiPhoneticKeyboard
```

**Open Xcode and follow [SETUP.md](SETUP.md)** for detailed instructions.

**Quick version**:
1. File → New → Project → iOS App
2. Name: `ThaiPhoneticKeyboard`, Bundle ID: `com.fsonntag.ThaiPhoneticKeyboard`
3. File → New → Target → Custom Keyboard Extension
4. Name: `ThaiKeyboardExtension`
5. Add all source files (drag from Finder)
6. Ensure dictionary files are in keyboard extension's "Copy Bundle Resources"

### 2. Build & Run (2 minutes)

```bash
# Select iPhone 15 Pro simulator (or connected device)
# Press Cmd+R in Xcode
```

**Expected result**: App launches showing welcome screen.

### 3. Enable Keyboard (3 minutes)

On iOS device/simulator:

1. Open **Settings**
2. **General** → **Keyboard** → **Keyboards**
3. **Add New Keyboard...**
4. Under **Third-Party Keyboards**, select **"Thai Phonetic"**

### 4. Test (5 minutes)

1. Open **Notes** or **Messages**
2. Tap text field to show keyboard
3. Long-press **🌐** globe key
4. Select **"Thai Phonetic"**
5. Type: `sawatdi`
6. See: **สวัสดี** candidates
7. Tap candidate or press space

**Success!** 🎉

## What's Included

✅ All source code (21 files)
- Main app (welcome + tutorial)
- Keyboard extension (full implementation)
- Shared utilities

✅ Dictionaries (4.3MB total)
- 155,442 Thai words
- 198,123 romanization entries
- Bigram & trigram frequencies

✅ Documentation
- README.md - Complete documentation
- SETUP.md - Xcode project setup
- PROJECT_STRUCTURE.md - File organization
- This file - Quick start

## Usage Examples

| Type | See | Press Space | Get |
|------|-----|-------------|-----|
| `sawatdi` | สวัสดี | ✅ | สวัสดี |
| `khobkhun` | ขอบคุณ | ✅ | ขอบคุณ |
| `aroiy` | อร่อย | ✅ | อร่อย |
| `sabaidemai` | สบายดีไหม | ✅ | สบายดีไหม |
| `hello` | (no match) | ✅ | hello (English) |

## Keyboard Shortcuts

| Key | Action |
|-----|--------|
| **Space** | Commit first Thai candidate (or English if no match) |
| **Delete** | Remove character from buffer |
| **Return** | Commit and insert newline |
| **123** | Switch to numbers/punctuation |
| **🌐** | Switch keyboard |

## Troubleshooting

### Keyboard not in Settings?

**Check bundle IDs**:
```bash
# Should be:
# App: com.fsonntag.ThaiPhoneticKeyboard
# Extension: com.fsonntag.ThaiPhoneticKeyboard.extension
```

**Verify Info.plist** (keyboard extension):
- Must have `NSExtensionPointIdentifier = com.apple.keyboard-service`
- Must have `PrimaryLanguage = th`

### No candidates showing?

**Check Xcode console** for errors:
- "Failed to load dictionary" → Files not in bundle
- Check "Copy Bundle Resources" build phase

**Verify target membership**:
- `dictionary.json` → ✅ ThaiKeyboardExtension
- `ngram_frequencies.json` → ✅ ThaiKeyboardExtension

### Build errors?

**"No such module 'SwiftUI'"**:
- Set deployment target to iOS 18.0

**"Cannot find 'AppConstants'"**:
- Ensure `Shared/Constants.swift` has both targets checked

## File Checklist

Before building, verify these files exist:

**Main App** (4 files):
- [x] `ThaiPhoneticKeyboard/ThaiPhoneticKeyboardApp.swift`
- [x] `ThaiPhoneticKeyboard/ContentView.swift`
- [x] `ThaiPhoneticKeyboard/TutorialView.swift`
- [x] `ThaiPhoneticKeyboard/Info.plist`

**Keyboard Extension** (10 files):
- [x] `ThaiKeyboardExtension/KeyboardViewController.swift`
- [x] `ThaiKeyboardExtension/Views/CandidateBar.swift`
- [x] `ThaiKeyboardExtension/Views/KeyboardLayoutView.swift`
- [x] `ThaiKeyboardExtension/Views/KeyButtonView.swift`
- [x] `ThaiKeyboardExtension/Engine/ThaiPhoneticEngine.swift`
- [x] `ThaiKeyboardExtension/Engine/DictionaryLoader.swift`
- [x] `ThaiKeyboardExtension/Engine/FuzzyMatching.swift`
- [x] `ThaiKeyboardExtension/Models/KeyboardState.swift`
- [x] `ThaiKeyboardExtension/Resources/dictionary.json`
- [x] `ThaiKeyboardExtension/Resources/ngram_frequencies.json`
- [x] `ThaiKeyboardExtension/Info.plist`

**Shared** (2 files):
- [x] `Shared/Constants.swift`
- [x] `Shared/Extensions.swift`

**Total**: 16 code files + 2 JSON files + 2 Info.plist = **20 files ready** ✅

## Next Steps

After successful testing:

1. **Test thoroughly** (see PROJECT_STRUCTURE.md checklist)
2. **Create app icon** (use `ThaiPhoneticIM/ThaiPhonetic.tiff` as base)
3. **Take screenshots** for App Store
4. **Archive** → Upload to App Store Connect
5. **Submit for review**

## Resources

- **README.md** - Full documentation
- **SETUP.md** - Detailed Xcode setup
- **PROJECT_STRUCTURE.md** - Architecture overview
- **macOS version** - [../ThaiPhoneticIM/](../ThaiPhoneticIM/)

## Support

If you encounter issues:

1. Check [SETUP.md](SETUP.md) troubleshooting section
2. Review Xcode console output
3. Verify all files are in correct targets
4. Check Build Phases → Copy Bundle Resources

## Success Criteria

You'll know it's working when:

✅ App builds without errors
✅ Extension builds without errors
✅ Keyboard appears in Settings → Keyboards
✅ Typing "sawatdi" shows Thai candidates
✅ Tapping candidate inserts Thai text
✅ English input works naturally

**Time to first Thai character: ~15 minutes from Xcode project creation** 🚀
