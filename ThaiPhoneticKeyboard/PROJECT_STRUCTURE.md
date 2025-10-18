# Project Structure

Complete file tree showing all components of the Thai Phonetic Keyboard iOS app.

```
ThaiPhoneticKeyboard/                           # Xcode project root
│
├── README.md                                    # Main documentation
├── SETUP.md                                     # Xcode setup instructions
├── PROJECT_STRUCTURE.md                         # This file
│
├── ThaiPhoneticKeyboard.xcodeproj/              # Xcode project (create via Xcode)
│   ├── project.pbxproj                          # Project configuration
│   └── xcshareddata/                            # Shared schemes
│
├── ThaiPhoneticKeyboard/                        # Main app target
│   ├── ThaiPhoneticKeyboardApp.swift            ✅ Entry point
│   ├── ContentView.swift                        ✅ Welcome screen
│   ├── TutorialView.swift                       ✅ Setup instructions
│   ├── Info.plist                               ✅ App configuration
│   └── Assets.xcassets/                         # App icons (create in Xcode)
│       └── AppIcon.appiconset/
│
├── ThaiKeyboardExtension/                       # Keyboard extension target
│   │
│   ├── KeyboardViewController.swift             ✅ Main controller
│   │
│   ├── Views/                                   # UI components
│   │   ├── CandidateBar.swift                   ✅ Thai candidates display
│   │   ├── KeyboardLayoutView.swift             ✅ QWERTY + number layouts
│   │   └── KeyButtonView.swift                  ✅ Individual key button
│   │
│   ├── Engine/                                  # Core logic
│   │   ├── ThaiPhoneticEngine.swift             ✅ Input engine (ported from macOS)
│   │   ├── DictionaryLoader.swift               ✅ Load JSON dictionaries
│   │   └── FuzzyMatching.swift                  ✅ Vowel variant matching
│   │
│   ├── Models/                                  # Data models
│   │   └── KeyboardState.swift                  ✅ UI state management
│   │
│   ├── Resources/                               # Data files
│   │   ├── dictionary.json                      ✅ 155k Thai words (2.3MB)
│   │   └── ngram_frequencies.json               ✅ Bigram/trigram data (2MB)
│   │
│   └── Info.plist                               ✅ Extension configuration
│
└── Shared/                                      # Code shared between app & extension
    ├── Constants.swift                          ✅ App-wide constants
    └── Extensions.swift                         ✅ Utility extensions
```

## File Count Summary

| Category | Files | Status |
|----------|-------|--------|
| Main App | 4 | ✅ Complete |
| Keyboard Extension | 10 | ✅ Complete |
| Shared Code | 2 | ✅ Complete |
| Resources | 2 | ✅ Complete |
| Documentation | 3 | ✅ Complete |
| **Total** | **21** | **Ready for Xcode** |

## Target Membership

Files must be added to the correct targets in Xcode:

| File | ThaiPhoneticKeyboard | ThaiKeyboardExtension |
|------|---------------------|----------------------|
| ThaiPhoneticKeyboardApp.swift | ✅ | - |
| ContentView.swift | ✅ | - |
| TutorialView.swift | ✅ | - |
| KeyboardViewController.swift | - | ✅ |
| All Views/*.swift | - | ✅ |
| All Engine/*.swift | - | ✅ |
| All Models/*.swift | - | ✅ |
| dictionary.json | - | ✅ |
| ngram_frequencies.json | - | ✅ |
| Shared/*.swift | ✅ | ✅ (both!) |

## Build Phases

### ThaiKeyboardExtension - Copy Bundle Resources

**Must include**:
- `dictionary.json` (2.3MB)
- `ngram_frequencies.json` (2MB)

These files must be embedded in the keyboard extension bundle so they can be loaded at runtime.

## Bundle Identifiers

| Target | Bundle ID |
|--------|-----------|
| App | `com.fsonntag.ThaiPhoneticKeyboard` |
| Extension | `com.fsonntag.ThaiPhoneticKeyboard.extension` |

## Deployment Target

Both targets: **iOS 18.0** (minimum)

## Code Architecture

### Data Flow

```
User types "sawatdi"
    ↓
KeyboardViewController.handleKeyTap()
    ↓
ThaiPhoneticEngine.appendCharacter()
    ↓
ThaiPhoneticEngine.updateCandidates()
    ├─→ Try exact match in dictionary
    ├─→ Try fuzzy matching (vowel variants)
    └─→ Try multi-word segmentation
    ↓
CandidateBar displays: ["สวัสดี", "สวัสดี", ...]
    ↓
User taps candidate OR presses space
    ↓
KeyboardViewController.handleCandidateTap()
    ↓
textDocumentProxy.insertText("สวัสดี")
    ↓
Result appears in app's text field
```

### Component Hierarchy

```
KeyboardViewController (UIKit)
    └── UIHostingController
        └── KeyboardLayoutView (SwiftUI)
            ├── CandidateBar (shows when candidates exist)
            │   └── ScrollView with Thai candidates
            └── LetterKeyboardLayout / NumberKeyboardLayout
                └── Multiple KeyRow components
                    └── Multiple KeyButtonView components
```

## Key Dependencies

### Frameworks
- **UIKit**: For UIInputViewController
- **SwiftUI**: For keyboard UI
- **Combine**: For @Published properties
- **OSLog**: For logging
- **Foundation**: For JSON loading

### No External Dependencies
All code is self-contained. No CocoaPods, SPM packages, or third-party libraries.

## Size Estimates

| Component | Size |
|-----------|------|
| App Binary | ~0.5 MB |
| Extension Binary | ~1.5 MB |
| dictionary.json | 2.3 MB |
| ngram_frequencies.json | 2.0 MB |
| App Icon | 0.5 MB |
| **Total IPA** | **~7-8 MB** |

## Memory Usage (Target)

| Component | Memory |
|-----------|--------|
| Dictionary (loaded) | ~4 MB |
| N-grams (loaded) | ~3 MB |
| SwiftUI Views | ~2 MB |
| Runtime | ~3 MB |
| **Total** | **~12 MB** |
| iOS Limit | 48 MB |
| **Safety Margin** | **36 MB** ✅ |

## Testing Checklist

Use this checklist when testing the app:

### Installation
- [ ] App builds without errors
- [ ] Extension builds without errors
- [ ] App launches and shows welcome screen
- [ ] Tutorial view displays correctly

### Keyboard Activation
- [ ] Keyboard appears in Settings → Keyboard → Keyboards
- [ ] Can be added via "Add New Keyboard"
- [ ] Globe key (🌐) switches to Thai Phonetic

### Thai Input
- [ ] Type "sawatdi" shows "สวัสดี" candidates
- [ ] Tap candidate inserts Thai text
- [ ] Space bar commits first candidate
- [ ] Candidates update as typing progresses
- [ ] Multi-word: "khobkhun" → "ขอบคุณ"

### English Input
- [ ] Type "hello" (no Thai match) works as English
- [ ] Space after English word inserts space
- [ ] Numbers and punctuation work

### UI/UX
- [ ] Keyboard height is appropriate
- [ ] Keys are tappable and responsive
- [ ] Candidate bar scrolls horizontally
- [ ] Dark mode works correctly
- [ ] Portrait and landscape work
- [ ] Works on iPhone and iPad

### Apps Compatibility
- [ ] Messages
- [ ] Notes
- [ ] Safari (address bar and text fields)
- [ ] Mail
- [ ] Third-party apps

### Edge Cases
- [ ] Delete removes from buffer correctly
- [ ] Return commits and adds newline
- [ ] Empty buffer behaves correctly
- [ ] Very long inputs don't crash
- [ ] Rapid typing doesn't lag
- [ ] Memory stays under 30MB
