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


def main():
    """Generate all iOS app icons and Contents.json"""

    # Create output directory
    script_dir = Path(__file__).parent
    output_dir = script_dir / "AppIcon.appiconset"
    output_dir.mkdir(exist_ok=True)

    print("🎨 Generating iOS App Icons for Thai Phonetic Keyboard")
    print(f"📁 Output directory: {output_dir}")
    print()

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
    print("✅ Success! All icons generated.")
    print()
    print("📦 Next steps:")
    print("  1. Open your Xcode project")
    print("  2. Navigate to Assets.xcassets")
    print("  3. Delete the existing AppIcon (if any)")
    print(f"  4. Drag the entire 'AppIcon.appiconset' folder into Assets.xcassets")
    print()
    print("🎯 Icon design:")
    print(f"  • Background: Indigo gradient (iOS keyboard theme)")
    print(f"  • Character: White ส (Thai phonetic)")
    print(f"  • Style: Modern, flat, Apple HIG compliant")
    print()


if __name__ == "__main__":
    main()
