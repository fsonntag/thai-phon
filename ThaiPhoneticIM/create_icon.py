#!/usr/bin/env python3
"""
Create icon for Thai Phonetic Input Method
Generates multi-resolution TIFF (16x16 and 32x32) matching macOS input method style
Uses Thai letter ส (from สัทอักษร meaning "phonetic")
"""

from PIL import Image, ImageDraw, ImageFont, ImageChops
import subprocess
import os

def create_icon_at_size(size, font_size, radius):
    """Create icon at specified size with rounded rectangle background and cut-out letter"""

    # For template images with TISIconIsTemplate (matching Pinyin style):
    # Create: black rounded rect background with transparent letter cut-out
    # This renders as: white rounded pill with transparent letter in menu bar

    # Start with transparent background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Draw rounded rectangle background (black, will render as white pill in menu bar)
    padding = max(1, size // 16)
    draw.rounded_rectangle(
        [padding, padding, size - padding - 1, size - padding - 1],
        radius=radius,
        fill=(0, 0, 0, 255)
    )

    # Use Thai-compatible system font
    try:
        font = ImageFont.truetype("/System/Library/Fonts/Supplemental/Thonburi.ttc", font_size)
    except:
        try:
            font = ImageFont.truetype("/System/Library/Fonts/Supplemental/Ayuthaya.ttf", font_size)
        except:
            print(f"Warning: Thai font not found for size {size}, using default")
            font = ImageFont.load_default()

    # Draw the Thai letter ส centered (from สัทอักษร meaning "phonetic")
    text = "ส"

    # Create a mask for the text to cut it out
    text_mask = Image.new('L', (size, size), 0)
    text_draw = ImageDraw.Draw(text_mask)

    # Get text bounding box for centering
    bbox = text_draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]

    x = (size - text_width) // 2 - bbox[0]
    y = (size - text_height) // 2 - bbox[1]

    # Draw white letter on mask
    text_draw.text((x, y), text, fill=255, font=font)

    # Apply mask to cut out the letter from the background
    img_array = img.convert('RGBA')
    r, g, b, a = img_array.split()

    # Where text mask is white (255), make the image transparent (cut out letter)
    text_mask_inv = Image.eval(text_mask, lambda x: 255 - x)
    a = ImageChops.multiply(a.convert('L'), text_mask_inv)

    img_array = Image.merge('RGBA', (r, g, b, a))

    return img_array

def main():
    project_dir = "/Users/fsonntag/Developer/thai-phon/ThaiPhoneticIM"

    # Create both resolutions matching Pinyin style
    # 16x16: radius ~2 (subtle rounding), larger font to fill space like Pinyin
    # 32x32: radius ~4 (2x scale)
    icon_16 = create_icon_at_size(16, font_size=14, radius=2)
    icon_32 = create_icon_at_size(32, font_size=28, radius=4)

    # Save directly as TIFF with correct DPI (PIL handles this better than sips)
    tiff_16 = f"{project_dir}/ThaiPhonetic_16.tiff"
    tiff_32 = f"{project_dir}/ThaiPhonetic_32.tiff"

    # Save 16x16 at 72 DPI
    icon_16.save(tiff_16, 'TIFF', dpi=(72, 72), compression='tiff_lzw')
    print(f"Created {tiff_16} @ 72 DPI")

    # Save 32x32 at 144 DPI (retina @2x)
    icon_32.save(tiff_32, 'TIFF', dpi=(144, 144), compression='tiff_lzw')
    print(f"Created {tiff_32} @ 144 DPI")

    # Combine into multi-resolution TIFF using tiffutil
    # Use -cat instead of -cathidpicheck to preserve DPI settings
    output_tiff = f"{project_dir}/ThaiPhonetic.tiff"
    result = subprocess.run(
        ['tiffutil', '-cat', tiff_16, tiff_32, '-out', output_tiff],
        capture_output=True,
        text=True
    )

    if result.returncode == 0:
        # Verify the DPI settings
        verify = subprocess.run(['tiffutil', '-info', output_tiff], capture_output=True, text=True)

        print(f"\n✓ Created multi-resolution TIFF: {output_tiff}")

        # Check if 144 DPI is present for 32x32
        if '144' in verify.stdout:
            print("  - 16x16 @ 72 DPI")
            print("  - 32x32 @ 144 DPI (retina @2x)")
        else:
            print("  WARNING: DPI might not be set correctly")
            print("  Check with: tiffutil -info ThaiPhonetic.tiff")

        # Clean up intermediate files
        import os
        for f in [tiff_16, tiff_32]:
            if os.path.exists(f):
                os.remove(f)
    else:
        print(f"Error creating multi-resolution TIFF: {result.stderr}")

if __name__ == '__main__':
    main()
