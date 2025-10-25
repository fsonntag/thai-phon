#!/usr/bin/env python3
"""
Generate iOS App Icons for Thai Phonetic Keyboard
Creates all required icon sizes with gradient background and Thai letter ส
Following Apple Human Interface Guidelines for iOS app icons
"""

from PIL import Image, ImageDraw, ImageFont
import json
import os
from pathlib import Path

# Design Configuration
# Top color of gradient (iOS keyboard accent color)
TOP_COLOR = (88, 86, 214)  # #5856D6
# Bottom color of gradient (slightly darker)
BOTTOM_COLOR = (75, 74, 207)  # #4B4ACF
# Character color
CHAR_COLOR = (255, 255, 255)  # White
# Shadow color (black with low opacity)
SHADOW_COLOR = (0, 0, 0, 25)  # 10% opacity black
# Shadow offset (pixels relative to 1024px base)
SHADOW_OFFSET_RATIO = 0.002  # 2px at 1024px
# Character size (percentage of icon size)
CHAR_SIZE_RATIO = 0.65  # 65% of icon size


def create_gradient_background(size):
    """Create a vertical gradient from TOP_COLOR to BOTTOM_COLOR"""
    img = Image.new('RGB', (size, size))
    draw = ImageDraw.Draw(img)

    # Draw gradient line by line
    for y in range(size):
        # Calculate color for this line (linear interpolation)
        ratio = y / size
        r = int(TOP_COLOR[0] + (BOTTOM_COLOR[0] - TOP_COLOR[0]) * ratio)
        g = int(TOP_COLOR[1] + (BOTTOM_COLOR[1] - TOP_COLOR[1]) * ratio)
        b = int(TOP_COLOR[2] + (BOTTOM_COLOR[2] - TOP_COLOR[2]) * ratio)

        draw.line([(0, y), (size, y)], fill=(r, g, b))

    return img


def get_thai_font(size):
    """Get Thai-compatible system font at specified size"""
    # Try Thonburi Bold first (best for Thai)
    font_paths = [
        "/System/Library/Fonts/Supplemental/Thonburi.ttc",
        "/System/Library/Fonts/Supplemental/Thonburi-Bold.ttf",
        "/System/Library/Fonts/Supplemental/Ayuthaya.ttf",
        "/Library/Fonts/Thonburi.ttc",
    ]

    for font_path in font_paths:
        try:
            # For .ttc files, try to use the bold variant (index 1)
            if font_path.endswith('.ttc'):
                try:
                    return ImageFont.truetype(font_path, size, index=1)
                except:
                    return ImageFont.truetype(font_path, size, index=0)
            else:
                return ImageFont.truetype(font_path, size)
        except (OSError, IOError):
            continue

    # Fallback
    print(f"Warning: Could not find Thai font, using default")
    return ImageFont.load_default()


def create_icon(size):
    """Create a single icon at the specified size"""

    # Create gradient background
    img = create_gradient_background(size)

    # Convert to RGBA for transparency support in text layer
    img = img.convert('RGBA')

    # Calculate font size (make it bold and large)
    font_size = int(size * CHAR_SIZE_RATIO)
    font = get_thai_font(font_size)

    # Thai character
    text = "ส"

    # Create drawing context
    draw = ImageDraw.Draw(img)

    # Get text bounding box for centering
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]

    # Calculate position to center text
    x = (size - text_width) // 2 - bbox[0]
    y = (size - text_height) // 2 - bbox[1]

    # Draw shadow first (slight offset for depth)
    shadow_offset = max(1, int(size * SHADOW_OFFSET_RATIO))

    # Create a separate layer for shadow with proper alpha blending
    shadow_layer = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow_layer)
    shadow_draw.text(
        (x + shadow_offset, y + shadow_offset),
        text,
        fill=SHADOW_COLOR,
        font=font
    )

    # Composite shadow onto background
    img = Image.alpha_composite(img, shadow_layer)

    # Draw the main character in white
    draw = ImageDraw.Draw(img)
    draw.text((x, y), text, fill=CHAR_COLOR, font=font)

    # Convert back to RGB (iOS doesn't support transparency in icons)
    img = img.convert('RGB')

    return img


def generate_contents_json():
    """Generate Contents.json for Xcode Asset Catalog"""

    # iOS App Icon specification
    # Sizes in format: (size_pt, scale, idiom)
    icon_specs = [
        # iPhone
        (20, 2, "iphone"),    # 40x40
        (20, 3, "iphone"),    # 60x60
        (29, 2, "iphone"),    # 58x58
        (29, 3, "iphone"),    # 87x87
        (40, 2, "iphone"),    # 80x80
        (40, 3, "iphone"),    # 120x120
        (60, 2, "iphone"),    # 120x120 (duplicate for legacy)
        (60, 3, "iphone"),    # 180x180

        # iPad
        (20, 1, "ipad"),      # 20x20
        (20, 2, "ipad"),      # 40x40
        (29, 1, "ipad"),      # 29x29
        (29, 2, "ipad"),      # 58x58
        (40, 1, "ipad"),      # 40x40
        (40, 2, "ipad"),      # 80x80
        (76, 1, "ipad"),      # 76x76
        (76, 2, "ipad"),      # 152x152
        (83.5, 2, "ipad"),    # 167x167

        # App Store
        (1024, 1, "ios-marketing"),  # 1024x1024
    ]

    images = []
    for size_pt, scale, idiom in icon_specs:
        pixel_size = int(size_pt * scale)
        filename = f"icon_{pixel_size}x{pixel_size}.png"

        images.append({
            "filename": filename,
            "idiom": idiom,
            "scale": f"{int(scale)}x",
            "size": f"{size_pt:.1f}x{size_pt:.1f}".replace('.0', '')
        })

    contents = {
        "images": images,
        "info": {
            "author": "xcode",
            "version": 1
        }
    }

    return contents


def export_contentview_icon(script_dir):
    """Export a separate icon for use in ContentView UI"""
    print("\n📱 Exporting ContentView display icon...")

    # Path to Assets in the iOS project
    assets_dir = script_dir.parent / "ThaiPhoneticKeyboard" / "ThaiPhoneticKeyboard" / "Assets.xcassets"

    # Check if Assets directory exists
    if not assets_dir.exists():
        print(f"  ⚠️  Warning: Assets.xcassets not found at {assets_dir}")
        print("  Skipping ContentView icon export.")
        return False

    output_dir = assets_dir / "AppIconDisplay.imageset"
    output_dir.mkdir(parents=True, exist_ok=True)

    # Create @1x, @2x, @3x versions for proper iOS scaling
    sizes = [
        (512, "AppIconDisplay.png"),
        (1024, "AppIconDisplay@2x.png"),
        (1536, "AppIconDisplay@3x.png"),
    ]

    for img_size, filename in sizes:
        print(f"  Generating {filename} ({img_size}×{img_size}px)...", end=" ")
        icon = create_icon(img_size)
        filepath = output_dir / filename
        icon.save(filepath, 'PNG', optimize=True)
        print("✓")

    # Create Contents.json for the image set
    contents = {
        "images": [
            {
                "filename": "AppIconDisplay.png",
                "idiom": "universal",
                "scale": "1x"
            },
            {
                "filename": "AppIconDisplay@2x.png",
                "idiom": "universal",
                "scale": "2x"
            },
            {
                "filename": "AppIconDisplay@3x.png",
                "idiom": "universal",
                "scale": "3x"
            }
        ],
        "info": {
            "author": "xcode",
            "version": 1
        }
    }

    contents_path = output_dir / "Contents.json"
    with open(contents_path, 'w', encoding='utf-8') as f:
        json.dump(contents, f, indent=2, ensure_ascii=False)
    print("  ✓ Created Contents.json")
    print(f"  📁 Location: {output_dir}")

    return True


def export_android_icons(script_dir):
    """Export Android launcher icons for all density buckets"""
    print("\n🤖 Exporting Android launcher icons...")

    # Path to Android res directory
    android_res_dir = script_dir.parent / "ThaiPhoneticAndroid" / "app" / "src" / "main" / "res"

    # Check if Android project exists
    if not android_res_dir.exists():
        print(f"  ⚠️  Warning: Android res directory not found at {android_res_dir}")
        print("  Skipping Android icon export.")
        return False

    # Android icon sizes for different density buckets
    # Format: (density_name, size_px)
    android_densities = [
        ("mdpi", 48),      # Baseline (1x)
        ("hdpi", 72),      # 1.5x
        ("xhdpi", 96),     # 2x
        ("xxhdpi", 144),   # 3x
        ("xxxhdpi", 192),  # 4x
    ]

    for density, size in android_densities:
        print(f"  Generating mipmap-{density}/ic_launcher.png ({size}×{size}px)...", end=" ")

        # Create mipmap directory
        mipmap_dir = android_res_dir / f"mipmap-{density}"
        mipmap_dir.mkdir(parents=True, exist_ok=True)

        # Generate icon
        icon = create_icon(size)

        # Save as ic_launcher.png
        filepath = mipmap_dir / "ic_launcher.png"
        icon.save(filepath, 'PNG', optimize=True)
        print("✓")

    print(f"  📁 Location: {android_res_dir}")
    return True


def create_adaptive_icon_background(size):
    """Create background layer for adaptive icon (gradient only)"""
    # Background should fill entire 108dp canvas
    return create_gradient_background(size)


def create_adaptive_icon_foreground(size):
    """Create foreground layer for adaptive icon (character on transparent)"""
    # Foreground: transparent background with character
    # Character should be sized for 66dp safe zone (centered in 108dp canvas)
    # This means we need more padding than the regular icon

    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))

    # For adaptive icons, the character should fit in the 66dp safe zone
    # which is 61% of the 108dp canvas (66/108 = 0.611)
    # We'll use 55% to have some extra breathing room
    font_size = int(size * 0.55)
    font = get_thai_font(font_size)
    text = "ส"

    draw = ImageDraw.Draw(img)
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]

    # Center the character
    x = (size - text_width) // 2 - bbox[0]
    y = (size - text_height) // 2 - bbox[1]

    # Add subtle shadow for depth
    shadow_offset = max(1, int(size * SHADOW_OFFSET_RATIO))
    shadow_layer = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow_layer)
    shadow_draw.text(
        (x + shadow_offset, y + shadow_offset),
        text,
        fill=SHADOW_COLOR,
        font=font
    )
    img = Image.alpha_composite(img, shadow_layer)

    # Draw the main white character
    draw = ImageDraw.Draw(img)
    draw.text((x, y), text, fill=CHAR_COLOR, font=font)

    return img


def create_adaptive_icon_monochrome(size):
    """Create monochrome layer for themed icons (Android 13+)"""
    # Monochrome: transparent background with black character
    # Used by system for themed icons in App Suggestions, Quick Settings, etc.

    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))

    # Same sizing as foreground for consistency
    font_size = int(size * 0.55)
    font = get_thai_font(font_size)
    text = "ส"

    draw = ImageDraw.Draw(img)
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]

    # Center the character
    x = (size - text_width) // 2 - bbox[0]
    y = (size - text_height) // 2 - bbox[1]

    # Draw black character (system will colorize it)
    # Use pure black (not white) as per Android guidelines
    draw.text((x, y), text, fill=(0, 0, 0, 255), font=font)

    return img


def export_android_adaptive_icons(script_dir):
    """Export Android adaptive icon layers (background + foreground)"""
    print("\n📱 Exporting Android adaptive icons...")

    # Path to Android res directory
    android_res_dir = script_dir.parent / "ThaiPhoneticAndroid" / "app" / "src" / "main" / "res"

    # Check if Android project exists
    if not android_res_dir.exists():
        print(f"  ⚠️  Warning: Android res directory not found at {android_res_dir}")
        print("  Skipping Android adaptive icon export.")
        return False

    # Adaptive icon sizes (108dp base for all layers)
    # Format: (density_name, size_px for 108dp)
    adaptive_densities = [
        ("mdpi", 108),      # Baseline (1x)
        ("hdpi", 162),      # 1.5x
        ("xhdpi", 216),     # 2x
        ("xxhdpi", 324),    # 3x
        ("xxxhdpi", 432),   # 4x
    ]

    for density, size in adaptive_densities:
        # Generate background layer
        print(f"  Generating mipmap-{density}/ic_launcher_background.png ({size}×{size}px)...", end=" ")
        mipmap_dir = android_res_dir / f"mipmap-{density}"
        mipmap_dir.mkdir(parents=True, exist_ok=True)

        background = create_adaptive_icon_background(size)
        bg_path = mipmap_dir / "ic_launcher_background.png"
        background.save(bg_path, 'PNG', optimize=True)
        print("✓")

        # Generate foreground layer
        print(f"  Generating mipmap-{density}/ic_launcher_foreground.png ({size}×{size}px)...", end=" ")
        foreground = create_adaptive_icon_foreground(size)
        fg_path = mipmap_dir / "ic_launcher_foreground.png"
        foreground.save(fg_path, 'PNG', optimize=True)
        print("✓")

        # Generate monochrome layer (for themed icons)
        print(f"  Generating mipmap-{density}/ic_launcher_monochrome.png ({size}×{size}px)...", end=" ")
        monochrome = create_adaptive_icon_monochrome(size)
        mono_path = mipmap_dir / "ic_launcher_monochrome.png"
        monochrome.save(mono_path, 'PNG', optimize=True)
        print("✓")

    # Create adaptive icon XML files
    print("  Creating adaptive icon XML...", end=" ")

    # Create mipmap-anydpi-v26 directory
    adaptive_dir = android_res_dir / "mipmap-anydpi-v26"
    adaptive_dir.mkdir(parents=True, exist_ok=True)

    # Adaptive icon XML content (with monochrome for themed icons)
    adaptive_icon_xml = '''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@mipmap/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
    <monochrome android:drawable="@mipmap/ic_launcher_monochrome"/>
</adaptive-icon>'''

    # Write ic_launcher.xml
    with open(adaptive_dir / "ic_launcher.xml", 'w', encoding='utf-8') as f:
        f.write(adaptive_icon_xml)

    # Write ic_launcher_round.xml (same content)
    with open(adaptive_dir / "ic_launcher_round.xml", 'w', encoding='utf-8') as f:
        f.write(adaptive_icon_xml)

    print("✓")
    print(f"  📁 Location: {android_res_dir}")

    return True


def main():
    """Generate all iOS app icons and Contents.json"""

    script_dir = Path(__file__).parent

    # Path to Assets in the iOS project
    assets_dir = script_dir.parent / "ThaiPhoneticKeyboard" / "ThaiPhoneticKeyboard" / "Assets.xcassets"

    # Check if Assets directory exists
    if not assets_dir.exists():
        print(f"⚠️  Error: Assets.xcassets not found at {assets_dir}")
        print("Please ensure the script is in the correct location relative to the iOS project.")
        return

    print("🎨 Generating iOS App Icons for Thai Phonetic Keyboard")
    print(f"📁 Assets location: {assets_dir}")
    print()

    # Create output directory for app icons
    output_dir = assets_dir / "AppIcon.appiconset"
    output_dir.mkdir(exist_ok=True)

    # Get all unique sizes needed
    sizes_needed = {
        20, 29, 40, 58, 60, 76, 80, 87, 120, 152, 167, 180, 1024
    }

    # Generate each icon
    for size in sorted(sizes_needed):
        print(f"  Generating {size}×{size}px...", end=" ")
        icon = create_icon(size)

        # Save as PNG
        filename = f"icon_{size}x{size}.png"
        filepath = output_dir / filename
        icon.save(filepath, 'PNG', optimize=True)
        print("✓")

    # Generate Contents.json
    print("\n  Generating Contents.json...", end=" ")
    contents = generate_contents_json()
    contents_path = output_dir / "Contents.json"

    with open(contents_path, 'w', encoding='utf-8') as f:
        json.dump(contents, f, indent=2, ensure_ascii=False)
    print("✓")

    print()
    print("✅ Success! iOS app icons generated.")

    # Export ContentView icon
    contentview_exported = export_contentview_icon(script_dir)

    # Export Android icons
    android_exported = export_android_icons(script_dir)

    # Export Android adaptive icons
    adaptive_exported = export_android_adaptive_icons(script_dir)

    print()
    print("=" * 60)
    print("📦 Summary")
    print("=" * 60)

    print("\niOS Icons:")
    print("  ✓ AppIcon.appiconset/ - All iOS app icons (13 sizes)")
    if contentview_exported:
        print("  ✓ AppIconDisplay.imageset/ - ContentView display icon (@1x, @2x, @3x)")
    print(f"  📁 {assets_dir}")

    if android_exported:
        print("\nAndroid Legacy Icons (API < 26):")
        print("  ✓ mipmap-mdpi/ic_launcher.png (48×48px)")
        print("  ✓ mipmap-hdpi/ic_launcher.png (72×72px)")
        print("  ✓ mipmap-xhdpi/ic_launcher.png (96×96px)")
        print("  ✓ mipmap-xxhdpi/ic_launcher.png (144×144px)")
        print("  ✓ mipmap-xxxhdpi/ic_launcher.png (192×192px)")
        android_res = script_dir.parent / "ThaiPhoneticAndroid" / "app" / "src" / "main" / "res"
        print(f"  📁 {android_res}")

    if adaptive_exported:
        print("\nAndroid Adaptive Icons (API 26+):")
        print("  ✓ mipmap-anydpi-v26/ic_launcher.xml")
        print("  ✓ mipmap-anydpi-v26/ic_launcher_round.xml")
        print("  ✓ Background layers (5 densities, 108dp base)")
        print("  ✓ Foreground layers (5 densities, 108dp base)")
        print("  ✓ Monochrome layers (5 densities, for themed icons)")
        print(f"  📁 {android_res}")

    print("\n" + "=" * 60)
    print("✅ Ready to use!")
    print("=" * 60)

    print("\niOS:")
    print("  1. Open Xcode project")
    print("  2. Build and run - icons are already in Assets.xcassets")

    if android_exported or adaptive_exported:
        print("\nAndroid:")
        print("  1. Open Android Studio project")
        print("  2. AndroidManifest.xml already references @mipmap/ic_launcher")
        if adaptive_exported:
            print("  3. Adaptive icons will be used on Android 8.0+ (API 26+)")
            print("  4. Legacy icons will be used on Android 7.1 and below")
        print("  5. Build and run to see the proper icon (no white circle!)")

    print("\n🎯 Icon design:")
    print("  • Background: Indigo gradient (iOS keyboard theme)")
    print("  • Character: White ส (Thai phonetic)")
    print("  • Android: Adaptive icon with separate background/foreground layers")
    print("  • Style: Modern, flat, Apple HIG & Material Design compliant")
    print()


if __name__ == "__main__":
    main()
