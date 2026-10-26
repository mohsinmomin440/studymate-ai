import os
import math
from PIL import Image, ImageDraw

def create_gradient_squircle(size):
    # Render at 4x for extreme antialiasing
    scale = 4
    s = size * scale
    img = Image.new('RGBA', (s, s), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Gradient background from royal purple (91, 65, 217) to deep neon purple (124, 58, 237)
    # Rounded rectangle with radius ~22%
    radius = int(s * 0.24)
    padding = int(s * 0.04)
    rect = [padding, padding, s - padding, s - padding]

    # Create mask for rounded rectangle
    mask = Image.new('L', (s, s), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle(rect, radius=radius, fill=255)

    # Create gradient
    grad = Image.new('RGBA', (s, s))
    grad_draw = ImageDraw.Draw(grad)
    c_top = (91, 65, 217, 255)   # #5B41D9
    c_bot = (124, 58, 237, 255)  # #7C3AED

    for y in range(s):
        r_ratio = y / s
        r = int(c_top[0] + (c_bot[0] - c_top[0]) * r_ratio)
        g = int(c_top[1] + (c_bot[1] - c_top[1]) * r_ratio)
        b = int(c_top[2] + (c_bot[2] - c_top[2]) * r_ratio)
        grad_draw.line([(0, y), (s, y)], fill=(r, g, b, 255))

    img.paste(grad, (0, 0), mask)

    # Draw subtle neon inner border
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle(rect, radius=radius, outline=(255, 255, 255, 60), width=int(s * 0.012))

    # Center coordinates
    cx = s / 2
    cy = s / 2

    # Draw Graduation Cap (Mortarboard)
    # Top diamond coordinates
    cap_top_y = cy - s * 0.16
    cap_left_x = cx - s * 0.28
    cap_right_x = cx + s * 0.28
    cap_center_y = cy - s * 0.05
    cap_bottom_y = cy + s * 0.06

    diamond = [
        (cx, cap_top_y),
        (cap_right_x, cap_center_y),
        (cx, cap_bottom_y),
        (cap_left_x, cap_center_y)
    ]
    draw.polygon(diamond, fill=(255, 255, 255, 255))

    # Cap Skullcap/Underneath
    skull_rect = [cx - s * 0.16, cap_center_y, cx + s * 0.16, cy + s * 0.14]
    draw.chord(skull_rect, start=0, end=180, fill=(240, 240, 255, 255))

    # Golden Tassel
    tassel_color = (251, 191, 36, 255) # Amber gold #FBBF24
    draw.ellipse([cx - s * 0.025, cap_top_y + s * 0.09, cx + s * 0.025, cap_top_y + s * 0.14], fill=tassel_color)
    draw.line([(cx, cap_top_y + s * 0.11), (cap_right_x - s * 0.04, cy + s * 0.06)], fill=tassel_color, width=int(s * 0.018))
    # Tassel bob
    draw.rounded_rectangle([cap_right_x - s * 0.06, cy + s * 0.05, cap_right_x - s * 0.02, cy + s * 0.13], radius=int(s*0.01), fill=tassel_color)

    # Open Book beneath cap
    book_top_y = cy + s * 0.14
    book_height = s * 0.12
    bw = s * 0.24

    # Left page curve
    left_page = [
        (cx - s * 0.02, book_top_y),
        (cx - bw, book_top_y + s * 0.04),
        (cx - bw, book_top_y + s * 0.04 + book_height),
        (cx - s * 0.02, book_top_y + book_height)
    ]
    draw.polygon(left_page, fill=(255, 255, 255, 230))

    # Right page curve
    right_page = [
        (cx + s * 0.02, book_top_y),
        (cx + bw, book_top_y + s * 0.04),
        (cx + bw, book_top_y + s * 0.04 + book_height),
        (cx + s * 0.02, book_top_y + book_height)
    ]
    draw.polygon(right_page, fill=(255, 255, 255, 230))

    # Downsample with Lanczos
    return img.resize((size, size), Image.Resampling.LANCZOS)

def create_google_logo(size):
    scale = 4
    s = size * scale
    img = Image.new('RGBA', (s, s), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    cx = s / 2
    cy = s / 2
    outer_r = s * 0.44
    inner_r = s * 0.26
    stroke_w = outer_r - inner_r
    mid_r = (outer_r + inner_r) / 2

    # Draw the four colored arcs
    # Red: Top arc (from 140 to 270 deg / or -45 to -135)
    # Standard Google "G":
    # 0 deg is right (+X), 90 is down (+Y), 180 is left (-X), 270 is up (-Y)
    bbox = [cx - mid_r, cy - mid_r, cx + mid_r, cy + mid_r]
    thick = int(stroke_w)

    c_red = (234, 67, 53, 255)     # #EA4335
    c_yellow = (251, 188, 5, 255)  # #FBBC05
    c_green = (52, 168, 83, 255)   # #34A853
    c_blue = (66, 133, 244, 255)   # #4285F4

    # Draw arcs
    # Red: -45 to -145 (215 to 315)
    draw.arc(bbox, start=220, end=335, fill=c_red, width=thick)
    # Yellow: 135 to 225
    draw.arc(bbox, start=135, end=225, fill=c_yellow, width=thick)
    # Green: 45 to 140
    draw.arc(bbox, start=40, end=140, fill=c_green, width=thick)
    # Blue: -40 to 45 (320 to 45)
    draw.arc(bbox, start=320, end=45, fill=c_blue, width=thick)

    # Blue crossbar from center to right
    bar_left = cx
    bar_right = cx + outer_r
    bar_top = cy - stroke_w / 2
    bar_bot = cy + stroke_w / 2
    draw.rectangle([bar_left, bar_top, bar_right, bar_bot], fill=c_blue)

    return img.resize((size, size), Image.Resampling.LANCZOS)

if __name__ == '__main__':
    # Generate Android launcher icons
    mipmap_sizes = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192,
    }

    base_res = 'android/app/src/main/res'
    for folder, sz in mipmap_sizes.items():
        out_path = os.path.join(base_res, folder, 'ic_launcher.png')
        icon = create_gradient_squircle(sz)
        icon.save(out_path, 'PNG')
        print(f'Generated {out_path} ({sz}x{sz})')

    # Generate assets
    os.makedirs('assets/images', exist_ok=True)
    os.makedirs('assets/icons', exist_ok=True)

    app_logo = create_gradient_squircle(512)
    app_logo.save('assets/images/app_logo.png', 'PNG')
    print('Generated assets/images/app_logo.png (512x512)')

    google_logo = create_google_logo(128)
    google_logo.save('assets/icons/google.png', 'PNG')
    print('Generated assets/icons/google.png (128x128)')
