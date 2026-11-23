#!/usr/bin/env python3
"""
Generate StudyMate AI app icon with brand gradient (#6C5CE7 → #8E7BFF)
"""
from PIL import Image, ImageDraw, ImageFont
import os

def create_icon(size, output_path):
    """Create a square icon with the brand gradient and an 'S' or brain symbol"""
    # Create base image with gradient
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Draw gradient background (diagonal from top-left to bottom-right)
    for y in range(size):
        for x in range(size):
            # Calculate position in gradient (0 to 1)
            t = (x + y) / (2 * size)
            # Interpolate between #6C5CE7 and #8E7BFF
            r = int(0x6C + t * (0x8E - 0x6C))
            g = int(0x5C + t * (0x7B - 0x5C))
            b = int(0xE7 + t * (0xFF - 0xE7))
            draw.point((x, y), fill=(r, g, b, 255))

    # Add a subtle glow/overlay
    # Draw a rounded rectangle mask for modern look
    corner_radius = size // 5
    mask = Image.new('L', (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle(
        [(0, 0), (size, size)],
        radius=corner_radius,
        fill=255
    )
    img.putalpha(mask)

    # Draw central symbol - using "S" for StudyMate
    try:
        # Try to use a system font
        font_size = size // 2
        font = ImageFont.truetype("arial.ttf", font_size)
    except:
        # Fallback to default
        font = ImageFont.load_default()
        font_size = size // 3

    # Draw "S" in white with subtle shadow for depth
    text = "S"
    text_bbox = draw.textbbox((0, 0), text, font=font)
    text_width = text_bbox[2] - text_bbox[0]
    text_height = text_bbox[3] - text_bbox[1]

    x = (size - text_width) // 2
    y = (size - text_height) // 2 - size // 20  # Slightly up for optical centering

    # Shadow
    draw.text((x + 2, y + 2), text, font=font, fill=(0, 0, 0, 80))
    # Main text
    draw.text((x, y), text, font=font, fill=(255, 255, 255, 255))

    # Add a subtle highlight at top for glassmorphism effect
    highlight = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    highlight_draw = ImageDraw.Draw(highlight)
    highlight_draw.ellipse(
        [(-size//2, -size//2), (size*1.5, size//3)],
        fill=(255, 255, 255, 30)
    )
    img = Image.alpha_composite(img, highlight)

    img.save(output_path)
    print(f"Created {output_path} ({size}x{size})")

if __name__ == "__main__":
    output_dir = os.path.dirname(os.path.abspath(__file__))

    # Generate icons for various sizes
    sizes = [1024, 512, 192, 144, 128, 96, 72, 48, 36]
    for size in sizes:
        output_path = os.path.join(output_dir, f"icon-{size}.png")
        create_icon(size, output_path)

    print("Done!")