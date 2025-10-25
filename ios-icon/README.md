# Thai Phonetic Keyboard - App Icon Generator

Generate professional app icons for both iOS and Android versions of the Thai Phonetic Keyboard, featuring the Thai letter **ส** (from สัทอักษร meaning "phonetic") on a modern indigo gradient background.

## Design

- **Background**: Deep indigo/purple gradient (#5856D6 → #4B4ACF) matching iOS keyboard theme
- **Character**: Large white **ส** with subtle drop shadow for depth
- **Font**: Thonburi Bold (macOS system Thai font)
- **Style**: Modern, flat design following [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/app-icons)

## Requirements

- Python 3.7 or higher
- macOS (for Thai system fonts)
- Pillow (Python Imaging Library)

## Setup & Usage

### 1. Create Virtual Environment

```bash
cd ios-icon
python3 -m venv venv
source venv/bin/activate
```

### 2. Install Dependencies

```bash
pip install -r requirements.txt
```

### 3. Generate Icons

```bash
python generate_ios_icons.py
```

This will automatically create icon sets for both platforms:

**iOS** (in `ThaiPhoneticKeyboard/.../Assets.xcassets`):
- `AppIcon.appiconset/` - 13 PNG files at all required iOS sizes (20px to 1024px)
- `AppIconDisplay.imageset/` - ContentView display icon (@1x, @2x, @3x)
- Proper `Contents.json` files with Xcode asset catalog metadata

**Android** (in `ThaiPhoneticAndroid/.../res`):
- `mipmap-mdpi/ic_launcher.png` - 48×48px
- `mipmap-hdpi/ic_launcher.png` - 72×72px
- `mipmap-xhdpi/ic_launcher.png` - 96×96px
- `mipmap-xxhdpi/ic_launcher.png` - 144×144px
- `mipmap-xxxhdpi/ic_launcher.png` - 192×192px

### 4. Build Projects

**iOS:**
1. Open your iOS project in Xcode
2. Build and run - the icons are already in place!
3. ContentView will automatically use the custom icon

**Android:**
1. Open your Android project in Android Studio
2. Build and run - icons are in mipmap folders
3. AndroidManifest.xml already references `@mipmap/ic_launcher`

### 5. Deactivate Virtual Environment (Optional)

```bash
deactivate
```

## Output Locations

Icons are generated directly in both projects:

**iOS:**
```
ThaiPhoneticKeyboard/ThaiPhoneticKeyboard/Assets.xcassets/
├── AppIcon.appiconset/         # iOS app icons (13 sizes)
└── AppIconDisplay.imageset/    # ContentView display icon
```

**Android:**
```
ThaiPhoneticAndroid/app/src/main/res/
├── mipmap-mdpi/ic_launcher.png
├── mipmap-hdpi/ic_launcher.png
├── mipmap-xhdpi/ic_launcher.png
├── mipmap-xxhdpi/ic_launcher.png
└── mipmap-xxxhdpi/ic_launcher.png
```

## Generated Icon Sizes

### iOS

The script generates all required iOS app icon sizes in `AppIcon.appiconset`:

### iPhone
- 40×40px (20pt @2x)
- 60×60px (20pt @3x)
- 58×58px (29pt @2x)
- 87×87px (29pt @3x)
- 80×80px (40pt @2x)
- 120×120px (40pt @3x, 60pt @2x)
- 180×180px (60pt @3x)

### iPad
- 20×20px (20pt @1x)
- 40×40px (20pt @2x)
- 29×29px (29pt @1x)
- 58×58px (29pt @2x)
- 40×40px (40pt @1x)
- 80×80px (40pt @2x)
- 76×76px (76pt @1x)
- 152×152px (76pt @2x)
- 167×167px (83.5pt @2x)

### App Store
- 1024×1024px (Marketing)

### Android

Android launcher icons for all density buckets:

- **mdpi (Medium):** 48×48px - Baseline density (160 dpi)
- **hdpi (High):** 72×72px - 1.5× baseline (240 dpi)
- **xhdpi (Extra-high):** 96×96px - 2× baseline (320 dpi)
- **xxhdpi (Extra-extra-high):** 144×144px - 3× baseline (480 dpi)
- **xxxhdpi (Extra-extra-extra-high):** 192×192px - 4× baseline (640 dpi)

## Customization

To change colors or design, edit the constants at the top of `generate_ios_icons.py`:

```python
# Design Configuration
TOP_COLOR = (88, 86, 214)      # #5856D6 - Top of gradient
BOTTOM_COLOR = (75, 74, 207)   # #4B4ACF - Bottom of gradient
CHAR_COLOR = (255, 255, 255)   # White
CHAR_SIZE_RATIO = 0.65         # 65% of icon size
```

Then regenerate:

```bash
python generate_ios_icons.py
```

## Design Rationale

### Why Indigo/Purple?
- Matches iOS native keyboard accent color (Settings > Keyboard)
- Creates immediate visual association with keyboard/input functionality
- Modern, professional, and distinctive

### Why Large Character?
- Follows Apple's "embrace simplicity" guideline
- Recognizable even at smallest sizes (20×20px)
- No text needed - the Thai character communicates the app's purpose

### Why Gradient?
- Adds depth and dimensionality (Apple HIG recommendation)
- More visually interesting than flat color
- Subtle enough not to distract from character

## Apple Guidelines Compliance

✅ **Embraces simplicity** - Single character, no clutter
✅ **Unique and memorable** - Distinctive Thai character
✅ **Expresses purpose** - Phonetic keyboard input
✅ **Layered design** - Gradient + shadow for depth
✅ **Vector graphics** - Clean text rendering at all sizes
✅ **Recognizable at small sizes** - Large, high-contrast character
✅ **No transparency** - Solid RGB output
✅ **Square format** - System applies rounded corners

## Troubleshooting

### Font Not Found Warning
If you see "Could not find Thai font, using default":
- Ensure you're running on macOS (required for Thonburi font)
- Check that Thonburi is installed: `/System/Library/Fonts/Supplemental/Thonburi.ttc`

### Icons Look Blurry in Xcode
- Ensure you're viewing @2x or @3x sizes in the asset catalog
- Check that the PNG files are sharp when opened individually

### Wrong Colors
- macOS uses P3 color space by default
- Colors may appear slightly different on different displays
- Preview on an actual iOS device for accurate colors

## License

Part of the Thai Phonetic Keyboard project.
