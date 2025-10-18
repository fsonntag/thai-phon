# Thai Phonetic Keyboard - iOS

A custom iOS keyboard extension for typing Thai using phonetic romanization, similar to Pinyin input for Chinese.

## Features

- **Pinyin-Style Input**: Type romanization, see candidates above keyboard, tap or press space to select
- **Smart Fuzzy Matching**: Handles multiple romanization variants (sawatdi, sawatdee, sawasdee, etc.)
- **Multi-Word Segmentation**: Automatically segments longer inputs (e.g., "sabaidemai" → "สบายดีไหม")
- **N-gram Frequency Ranking**: Uses bigram and trigram frequencies for intelligent candidate ordering
- **Seamless English Input**: Type English naturally when not matching Thai words
- **Universal Support**: Works on iPhone and iPad, portrait and landscape
- **Stock Appearance**: Matches iOS system keyboard design
- **No Network Required**: All data bundled with keyboard, no "Full Access" needed

## Project Structure

```
ThaiPhoneticKeyboard/
├── ThaiPhoneticKeyboard/           # Container app
│   ├── ThaiPhoneticKeyboardApp.swift
│   ├── ContentView.swift           # Welcome screen
│   ├── TutorialView.swift          # Setup instructions
│   └── Info.plist
├── ThaiKeyboardExtension/          # Keyboard extension
│   ├── KeyboardViewController.swift # Main controller
│   ├── Views/
│   │   ├── CandidateBar.swift      # Thai candidate selection UI
│   │   ├── KeyboardLayoutView.swift # QWERTY layout
│   │   └── KeyButtonView.swift     # Key button component
│   ├── Engine/
│   │   ├── ThaiPhoneticEngine.swift # Core input logic
│   │   ├── DictionaryLoader.swift   # Load dictionaries
│   │   └── FuzzyMatching.swift      # Vowel variant matching
│   ├── Models/
│   │   └── KeyboardState.swift      # UI state management
│   ├── Resources/
│   │   ├── dictionary.json          # 155k Thai words (2.3MB)
│   │   └── ngram_frequencies.json   # Bigram/trigram data (2MB)
│   └── Info.plist
└── Shared/                          # Shared code
    ├── Constants.swift
    └── Extensions.swift
```

## Requirements

- **Xcode**: 15.0 or later
- **iOS**: 18.0 or later
- **Swift**: 5.9 or later

## Building

### 1. Open Xcode Project

```bash
cd ThaiPhoneticKeyboard
open ThaiPhoneticKeyboard.xcodeproj
```

### 2. Configure Signing

- Select the `ThaiPhoneticKeyboard` target
- Go to "Signing & Capabilities"
- Select your Development Team
- Repeat for `ThaiKeyboardExtension` target

### 3. Build and Run

- Select your target device or simulator
- Press Cmd+R to build and run
- The container app will launch on your device

### 4. Enable Keyboard on Device

1. On your iOS device: **Settings → General → Keyboard → Keyboards**
2. Tap **"Add New Keyboard..."**
3. Under **Third-Party Keyboards**, select **"Thai Phonetic"**
4. Switch to the keyboard using the 🌐 globe key

## Usage

### Basic Thai Input

1. Switch to Thai Phonetic keyboard (🌐 key)
2. Type romanization: `sawatdi`
3. Candidates appear: สวัสดี, สวัสดี, สวัสดิ์
4. Tap candidate or press **space** to select first
5. Result: **สวัสดี**

### Multi-Word Input

Type multiple words together:
- `sabaidemai` → สบายดีไหม (How are you?)
- `khobkhun` → ขอบคุณ (Thank you)
- `aroiy` → อร่อย (Delicious)

### English Input

Type English naturally - if no Thai matches are found after 3+ characters, the keyboard automatically treats it as English input.

### Keyboard Shortcuts

- **Space**: Commit first Thai candidate (or English if no matches)
- **Return**: Commit current selection and insert newline
- **Delete**: Remove character from romanization buffer (or from text if buffer is empty)
- **123**: Switch to numbers/punctuation
- **🌐**: Switch to next keyboard

## Architecture

### Core Components

**ThaiPhoneticEngine**: Ported from macOS implementation
- Dictionary management (155k words)
- Fuzzy matching with vowel variants
- Greedy longest-match word segmentation
- N-gram frequency scoring (bigrams + trigrams)

**KeyboardViewController**: Main UIKit controller
- Manages keyboard lifecycle
- Handles text input via `UITextDocumentProxy`
- Bridges UIKit and SwiftUI

**KeyboardLayoutView**: SwiftUI keyboard UI
- QWERTY layout (letters + numbers)
- Candidate bar (horizontal scrolling)
- Adaptive layout for iPhone/iPad
- Dark mode support

### Data Files

**dictionary.json** (2.3MB):
- Format: `{ "romanization": ["thai1", "thai2", ...] }`
- 198,123 romanization entries
- 155,442 unique Thai words
- Sorted by frequency (most common first)

**ngram_frequencies.json** (2MB):
- Bigrams: `{ "word1|word2": frequency }`
- Trigrams: `{ "word1|word2|word3": frequency }`
- Used for multi-word phrase scoring

## Testing

### On Simulator

1. Build and run on iPhone or iPad simulator
2. Open any app with text input (Notes, Messages)
3. Tap text field to show keyboard
4. Long-press 🌐 globe key, select "Thai Phonetic"
5. Type and test

### On Device

1. Connect iPhone/iPad via USB
2. Select device in Xcode
3. Build and run (Cmd+R)
4. Enable keyboard in Settings (see instructions above)
5. Test in various apps

### Test Cases

- [ ] Type "sawatdi" → see "สวัสดี" candidates
- [ ] Tap candidate → inserts Thai text
- [ ] Press space → commits first candidate
- [ ] Type "hello" → passes through as English
- [ ] Delete key removes from buffer
- [ ] Multi-word: "khobkhun" → "ขอบคุณ"
- [ ] Numbers/punctuation mode (123)
- [ ] Keyboard switcher (🌐)
- [ ] Works in: Messages, Notes, Safari, Mail
- [ ] Portrait and landscape orientations
- [ ] iPhone and iPad layouts
- [ ] Dark mode appearance

## Memory Optimization

The keyboard is designed to stay under iOS's ~48MB extension memory limit:

- Dictionary: ~2.3MB (loaded on startup)
- N-grams: ~2MB (loaded on startup)
- Code: ~2MB
- Runtime: ~5-10MB
- **Total**: ~15-20MB (well under limit)

If memory becomes an issue:
1. Reduce dictionary to top 100k words
2. Load dictionaries on-demand (lazy loading)
3. Use Core Data or SQLite instead of JSON

## Troubleshooting

### Keyboard doesn't appear in Settings

- Ensure bundle IDs are correct:
  - App: `com.fsonntag.ThaiPhoneticKeyboard`
  - Extension: `com.fsonntag.ThaiPhoneticKeyboard.extension`
- Check Info.plist has `NSExtensionPointIdentifier = com.apple.keyboard-service`
- Rebuild and reinstall

### No candidates showing

- Check dictionary files are included in extension target
- Look at Xcode console for loading errors
- Verify files are in "Copy Bundle Resources" build phase

### Crashes on launch

- Check memory usage in Instruments
- Verify dictionary JSON is valid
- Look for crashes in Xcode console

## Distribution

### App Store Preparation

1. **App Store Connect**: Create app listing
2. **Screenshots**: iPhone (6.5", 5.5") and iPad (12.9")
3. **Description**: Write clear description of features
4. **Privacy Policy**: Not required (no data collection)
5. **Archive**: Product → Archive in Xcode
6. **Upload**: Organizer → Distribute App → App Store

### TestFlight

1. Archive app in Xcode
2. Upload to App Store Connect
3. Add external testers
4. Distribute beta builds

## License

MIT License (same as parent project)

## Credits

- **Dictionary**: Thai2Rom dataset + TNC corpus
- **Architecture**: Inspired by vChewing and iOS Pinyin keyboard
- **macOS Version**: [ThaiPhoneticIM](../ThaiPhoneticIM/)

## Future Enhancements

- [ ] Custom romanization schemes (user preferences)
- [ ] Learning from user selections
- [ ] iCloud sync for learned words
- [ ] Widget for quick phrase access
- [ ] Emoji suggestions
- [ ] Voice input integration
