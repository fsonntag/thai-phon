# Thai Phonetic Keyboard - Android

A phonetic Thai keyboard for Android, inspired by Pinyin input. Type romanization (e.g., "pomgin") and get Thai script (ผมกิน).

## Project Status

**Current State: Feature Complete** ✨

The Android keyboard is fully functional with a modern Material Design 3 UI built with Jetpack Compose.

### ✅ Completed Features

**Core Functionality:**
- ✅ Full Thai phonetic engine ported from iOS
- ✅ Dictionary-based word suggestions (dictionary.json)
- ✅ N-gram frequency ranking (ngram_frequencies.json)
- ✅ Multi-candidate selection with number keys (1-9)
- ✅ Case-preserving input (Thai suggestions work regardless of case)
- ✅ Real-time candidate updates

**UI/UX:**
- ✅ Material Design 3 styling throughout
- ✅ Jetpack Compose-based keyboard UI
- ✅ QWERTY keyboard layout
- ✅ Smart shift key (single tap = next letter uppercase, long press = caps lock)
- ✅ Three keyboard layers:
  - Layer 1: Letters (QWERTY)
  - Layer 2: Numbers + common symbols (@#$%...)
  - Layer 3: Brackets + extended symbols ([]{}<>...)
- ✅ Long-press support with visual hints:
  - Letters → numbers/symbols (q→1, a→@, etc.)
  - Comma → ๆ (maiyamok)
  - Period → ฯ (paiyannoi)
  - Numbers → Thai numerals (1→๑, 2→๒, etc.)
  - Hyphen → ๏ (fongman)
- ✅ Comma and period on main keyboard (left/right of space)
- ✅ Consistent 123/ABC button positioning for easy toggling
- ✅ Pill-shaped candidate buttons with number badges
- ✅ Proper keyboard height and padding

**Technical:**
- ✅ Lifecycle management for Compose in InputMethodService
- ✅ Proper state management with MutableState
- ✅ Modern Kotlin 2.2.0 with Compose 1.7.8
- ✅ Android SDK 35 (target and compile)
- ✅ Minimum SDK 24 (Android 7.0)

### 🎯 Known Behavior

- Special characters (punctuation, symbols) commit any pending Thai text first (matches iOS behavior)
- Thai suggestions are generated from lowercase input regardless of visual case
- Shift state auto-resets after one character in ONCE mode

## Architecture

### Technology Stack

- **Language:** Kotlin 2.2.0
- **UI Framework:** Jetpack Compose 1.7.8
- **Design System:** Material Design 3
- **Target SDK:** Android 14 (API 35)
- **Min SDK:** Android 7.0 (API 24)

### Key Components

```
ThaiPhoneticIME.kt          # Main InputMethodService
├── Lifecycle management    # LifecycleOwner + SavedStateRegistryOwner
├── State management        # Shift state, keyboard mode, candidates
├── Input handling          # Character, special chars, backspace, enter
└── Mode switching          # Letters ↔ Symbols1 ↔ Symbols2

ThaiPhoneticEngine.kt       # Core phonetic engine
├── Dictionary loading      # dictionary.json (25,000+ entries)
├── N-gram frequencies      # ngram_frequencies.json
├── Fuzzy matching          # Levenshtein distance-based
└── Candidate generation    # Sorted by frequency

UI Components (Jetpack Compose):
├── CandidateBar.kt         # Thai word suggestions
├── KeyboardScreen.kt       # Main QWERTY layout
└── SymbolKeyboardScreen.kt # Symbol layers 1 & 2
```

## Building and Running

### Prerequisites

- Android Studio Ladybug or later
- JDK 17 or later
- Android SDK 35

### From Android Studio

1. Open Android Studio
2. Click **File → Open**
3. Navigate to `/Users/fsonntag/Developer/thai-phon/ThaiPhoneticAndroid`
4. Click **Open**
5. Wait for Gradle sync to complete
6. Click the green "Run" button (or Ctrl+R)
7. Select an emulator or connected device

### From Command Line

```bash
# Build APK
./gradlew assembleDebug

# Build and install on connected device
./gradlew installDebug

# Run tests
./gradlew test
```

The APK will be generated in `app/build/outputs/apk/debug/`

## Enabling the Keyboard

After installing:

1. Go to **Settings → System → Languages & input**
2. Select **Virtual keyboard** (or **On-screen keyboard**)
3. Tap **Manage keyboards**
4. Enable **"Thai Phonetic"**
5. Open any app with text input (Messages, Notes, etc.)
6. Tap the keyboard icon in the navigation bar
7. Select **"Thai Phonetic"**

## Usage

### Basic Input

1. Type romanization using QWERTY layout (e.g., "sawatdee")
2. Thai word suggestions appear in the candidate bar
3. Tap a suggestion or press the number key (1-9) to select
4. Continue typing for the next word

### Special Keys

- **Shift** (⇧): Single tap = uppercase next letter, long press = caps lock (⇪)
- **123**: Switch to numbers/symbols layer
- **ABC**: Switch back to letters
- **=\\<**: Switch to extended symbols layer
- **Space**: Commit top candidate and insert space
- **Enter**: Commit and send
- **Backspace**: Delete last character from buffer

### Long-Press Features

**On Letter Keys:**
- Each letter shows its alternate in the top-right corner
- Long-press to insert: numbers (q→1), symbols (a→@), or punctuation

**On Symbol Keys:**
- Numbers → Thai numerals (1→๑, 2→๒, etc.)
- Period → ฯ (paiyannoi - Thai abbreviation mark)
- Comma → ๆ (maiyamok - Thai repetition mark)
- Hyphen → ๏ (fongman - Thai section mark)

## Project Structure

```
ThaiPhoneticAndroid/
├── app/
│   ├── src/main/
│   │   ├── kotlin/com/fsonntag/thaiphonetic/
│   │   │   ├── ime/
│   │   │   │   └── ThaiPhoneticIME.kt          # InputMethodService + lifecycle
│   │   │   ├── engine/
│   │   │   │   └── ThaiPhoneticEngine.kt       # Phonetic engine
│   │   │   ├── ui/
│   │   │   │   ├── CandidateBar.kt             # Compose candidate bar
│   │   │   │   ├── KeyboardScreen.kt           # Compose QWERTY layout
│   │   │   │   └── SymbolKeyboardScreen.kt     # Compose symbol layouts
│   │   │   └── settings/
│   │   │       └── SettingsActivity.kt         # Settings (Compose)
│   │   ├── res/
│   │   │   ├── layout/                         # (unused - migrated to Compose)
│   │   │   ├── values/                         # Strings, colors
│   │   │   ├── mipmap/                         # App icons
│   │   │   └── xml/
│   │   │       └── method.xml                  # IME configuration
│   │   ├── assets/
│   │   │   ├── dictionary.json                 # 25,000+ Thai words
│   │   │   └── ngram_frequencies.json          # Word frequency data
│   │   └── AndroidManifest.xml
│   └── build.gradle.kts
├── gradle/
├── build.gradle.kts
├── settings.gradle.kts
└── README.md
```

## Development Notes

### Compose in InputMethodService

Special considerations for using Jetpack Compose in an IME:

1. **Lifecycle Management**: InputMethodService doesn't provide a LifecycleOwner by default. We implement both `LifecycleOwner` and `SavedStateRegistryOwner` manually.

2. **ViewTree Setup**: Both the window's decorView and ComposeView need lifecycle owners set:
```kotlin
window.window?.decorView?.setViewTreeLifecycleOwner(this)
composeView.setViewTreeLifecycleOwner(this)
```

3. **Composition Strategy**: Use `DisposeOnDetachedFromWindow` to properly clean up when the keyboard is hidden.

### State Management

- `shiftState`: ShiftState enum (OFF, ONCE, LOCKED)
- `keyboardModeState`: KeyboardMode enum (LETTERS, SYMBOLS_1, SYMBOLS_2)
- `candidatesState`: List of Thai word suggestions
- `inputBuffer`: StringBuilder for current romanization input

All states use `mutableStateOf()` for reactive UI updates.

## Testing

### Tested Devices

- ✅ Pixel 8a (Android 16) - Physical device
- ✅ Pixel 8a AVD (Android 16) - Emulator
- ✅ Pixel 7 AVD (Android 10) - Emulator

### Manual Testing Checklist

- [ ] Basic input (type "sawatdee", select candidate)
- [ ] Shift key (single tap, long press)
- [ ] Mode switching (123 → ABC)
- [ ] Long-press on letters (q → 1, a → @, etc.)
- [ ] Long-press on punctuation (, → ๆ, . → ฯ)
- [ ] Long-press on numbers (1 → ๑, etc.) in symbol mode
- [ ] Backspace behavior
- [ ] Space commits top candidate
- [ ] Enter key
- [ ] Case-preserving input

## Reference Projects

- **iOS Version** (`../ThaiPhoneticKeyboard`) - Original implementation
- **Mac Version** (`../ThaiPhoneticIM`) - macOS implementation
- **FlorisBoard** (`~/Developer/FlorisBoard`) - Modern Kotlin keyboard reference
- **Simple Keyboard** (`~/Developer/simple-keyboard`) - Minimal keyboard reference

## Troubleshooting

### Keyboard not appearing

1. Ensure the keyboard is enabled in Settings → System → Languages & input
2. Try restarting the device/emulator
3. Check logcat for errors: `adb logcat | grep ThaiPhonetic`

### Candidates not showing

1. Verify `dictionary.json` exists in `app/src/main/assets/`
2. Check logcat for dictionary loading errors
3. Try typing common words like "sawatdee", "arai"

### Build errors

1. Clean build: `./gradlew clean`
2. Invalidate caches in Android Studio (File → Invalidate Caches)
3. Check Kotlin version is 2.2.0 in `build.gradle.kts`

## License

TODO: Add license
