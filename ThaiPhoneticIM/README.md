# Thai Phonetic Input Method - macOS InputMethodKit

A custom input method for typing Thai using phonetic romanization (like Pinyin for Chinese).

## Features

- **Pinyin-like input experience** - Type romanization, see it underlined in the editor, select candidates to commit Thai text
- **Custom candidate window** - Clean, native-looking window with rounded selection styling
- **Cursor-relative positioning** - Candidate window appears right next to your cursor
- **Real-time candidate suggestions** as you type
- **Number key selection** (1-9) or arrow keys to navigate candidates
- **Multiple romanization support**: `sawasdee`, `sawatdee`, `sawadee`, `sawadi`, etc.
- **198,123 romanization entries** from 155,442 Thai words
- **Smart candidate ordering** by word length (simpler words first)

## Key Learnings (What Makes It Work)

Based on [this article](https://www.logcg.com/en/archives/2078.html), we discovered:

### Critical Requirements:

1. **Bundle Identifier must contain "inputmethod"**
   ```xml
   <key>CFBundleIdentifier</key>
   <string>com.fsonntag.inputmethod.ThaiPhoneticIM</string>
   ```
   ❌ `com.example.ThaiPhoneticIM` - WON'T WORK
   ✅ `com.example.inputmethod.ThaiPhoneticIM` - WORKS

2. **Must be installed in `/Library/Input Methods/`** (system-wide)
   - User directory `~/Library/Input Methods/` doesn't work on modern macOS
   - Requires `sudo` for installation

3. **Bundle Package Type should be `BNDL`**
   ```xml
   <key>CFBundlePackageType</key>
   <string>BNDL</string>
   ```

4. **Must have proper TIS keys**
   ```xml
   <key>TISIntendedLanguage</key>
   <string>th</string>
   <key>TISInputSourceID</key>
   <string>com.fsonntag.inputmethod.ThaiPhoneticIM</string>
   ```

## Installation

### First Time Setup:

```bash
cd /Users/fsonntag/Developer/thai-phon/ThaiPhoneticIM
./build.sh
sudo cp -R build/ThaiPhoneticIM.app "/Library/Input Methods/"
```

Then **log out and log back in**.

### Updating After Code Changes:

```bash
./reinstall.sh  # Builds and installs in one command
```

### Adding to System Settings:

1. Go to **System Settings → Keyboard → Input Sources → Edit**
2. Click **"+"** button
3. Search for **"Thai Phonetic"** or look under **"Others"**
4. Select it and click **Add**

## Usage

1. Switch to Thai Phonetic input (Control+Space or menu bar)
2. Type romanization: `fa`
3. See romanization underlined in your editor (Pinyin-style)
4. Candidate window appears with Thai options: ฟ้า, ฝา, ผา, etc.
5. Press **Space** to select first candidate, or **1-9** to select specific one
6. Result: **ฟ้า** (romanization is replaced with Thai text)

### Keyboard Shortcuts:

- **Space**: Commit first candidate
- **1-9**: Select specific candidate by number
- **Left/Right Arrow**: Navigate between candidates
- **Enter**: Commit romanization as-is (bypass conversion)
- **Escape**: Cancel input without committing
- **Backspace**: Delete character from romanization buffer

## Troubleshooting

### Input method shows up multiple times:

This happens when there are multiple copies registered. Clean up:

```bash
# Empty macOS Trash
# Then:
rm -rf ~/Library/Input\ Methods/ThaiPhoneticIM.app
./reinstall.sh
```

Log out and back in to refresh.

### Input method doesn't show up:

1. Check it's installed: `ls "/Library/Input Methods/"`
2. Check bundle ID contains "inputmethod":
   ```bash
   defaults read "/Library/Input Methods/ThaiPhoneticIM.app/Contents/Info.plist" CFBundleIdentifier
   ```
3. Re-register:
   ```bash
   sudo /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f -R "/Library/Input Methods/ThaiPhoneticIM.app"
   ```
4. Log out and back in

## Development

### Project Structure:

```
ThaiPhoneticIM/
├── Info.plist                      # Bundle configuration
├── main.swift                      # App entry point
├── ThaiPhoneticIMController.swift  # Input handling logic
├── ThaiCandidateWindow.swift       # Custom candidate window UI
├── TestCandidateWindow.swift       # Standalone test app for candidate window
├── dictionary.json                 # Thai romanization dictionary (13MB)
├── ThaiPhonetic.tiff               # Input method icon
├── create_icon.py                  # Icon generation script
├── build.sh                        # Build script
├── install.sh                      # Install script
├── reinstall.sh                    # Build + install script
├── test_window.sh                  # Quick test candidate window UI
└── build/                          # Build output
    └── ThaiPhoneticIM.app
```

### Building:

```bash
./build.sh
```

This compiles Swift sources, creates app bundle, code signs it, and copies to `~/Library/Input Methods/`.

### Installing System-Wide:

```bash
./reinstall.sh  # Requires sudo password
```

### Testing:

#### Test Candidate Window UI (without full installation):
```bash
./test_window.sh
```

This opens a standalone window to test the candidate UI quickly without reinstalling the input method. Press Q to quit, arrow keys to navigate, 1-9 to select, R to reload with different candidates.

#### Test Full Input Method:
Run directly to see logs:
```bash
/Library/Input\ Methods/ThaiPhoneticIM.app/Contents/MacOS/ThaiPhoneticIM
```

You should see:
```
Initializing IMKServer with connection: ThaiPhonetic_Connection, bundle: com.fsonntag.inputmethod.ThaiPhoneticIM
IMKServer initialized successfully
```

## Dictionary

The dictionary is generated from the Thai2Rom dataset (648K entries). Only single words are included (phrases filtered out).

To regenerate:
```bash
python3 ../export_dictionary_json.py
```

## macOS Compatibility

Tested on:
- macOS 15.7.1 (Sequoia) ✅

Should work on macOS 11.0+ (Big Sur and later).

## License

MIT License
