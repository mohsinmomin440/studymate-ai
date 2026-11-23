import math
from PIL import Image, ImageDraw, ImageFilter
import os

def create_super_icon(size=1024):
    # Render at 2x for ultra anti-aliasing
    scale = 2
    W = size * scale
    H = size * scale

    # Create base canvas with transparency
    img = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # 1. Background Squircle / Rounded Rect
    corner = int(W * 0.22)
    bg = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    bg_draw = ImageDraw.Draw(bg)

    # Premium dark cosmic gradient background: #0B0D1B -> #1A1338 -> #27164F
    for y in range(H):
        t = y / H
        # Deep indigo to rich violet
        r = int(12 + t * (42 - 12))
        g = int(14 + t * (24 - 14))
        b = int(32 + t * (85 - 32))
        bg_draw.line([(0, y), (W, y)], fill=(r, g, b, 255))

    # Ambient radial glow in upper-center (cyan/purple glow)
    glow_layer = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow_layer)
    cx, cy = int(W * 0.5), int(H * 0.45)
    max_r = int(W * 0.45)
    for r_step in range(max_r, 0, -8):
        alpha = int(35 * (1 - r_step / max_r))
        glow_draw.ellipse([cx - r_step, cy - r_step, cx + r_step, cy + r_step], fill=(108, 92, 231, alpha))

    # Inner bright cyan ambient dot
    inner_r = int(W * 0.25)
    for r_step in range(inner_r, 0, -6):
        alpha = int(45 * (1 - r_step / inner_r))
        glow_draw.ellipse([cx - r_step, cy - r_step, cx + r_step, cy + r_step], fill=(0, 212, 200, alpha))

    bg = Image.alpha_composite(bg, glow_layer)

    # Mask for squircle
    mask = Image.new('L', (W, H), 0)
    mask_draw = ImageDraw.Draw(mask)
    margin = int(W * 0.02)
    mask_draw.rounded_rectangle([margin, margin, W - margin, H - margin], radius=corner, fill=255)
    
    # Border stroke (subtle neon rim)
    rim = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    rim_draw = ImageDraw.Draw(rim)
    rim_draw.rounded_rectangle([margin, margin, W - margin, H - margin], radius=corner, outline=(142, 123, 255, 120), width=int(6 * scale))

    bg.putalpha(mask)
    img = Image.alpha_composite(img, bg)
    img = Image.alpha_composite(img, rim)

    # 2. Main Illustration Layer:
    # Stylized 3D Open Book + Floating Graduation Cap + Radiant Gemini AI Star
    fg = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    fg_draw = ImageDraw.Draw(fg)

    # --- A. Open Book Pages (Bottom) ---
    # Left page & Right page forming a sleek modern chevron
    # Spine center at (W*0.5, H*0.74)
    spine_x = W * 0.5
    spine_y = H * 0.74
    page_w = W * 0.32
    page_h = H * 0.16

    # Left Page
    left_poly = [
        (spine_x, spine_y - page_h * 0.2),
        (spine_x - page_w, spine_y - page_h * 0.9),
        (spine_x - page_w * 0.95, spine_y + page_h * 0.35),
        (spine_x, spine_y + page_h * 0.55),
    ]
    # Right Page
    right_poly = [
        (spine_x, spine_y - page_h * 0.2),
        (spine_x + page_w, spine_y - page_h * 0.9),
        (spine_x + page_w * 0.95, spine_y + page_h * 0.35),
        (spine_x, spine_y + page_h * 0.55),
    ]

    # Draw book pages with rich indigo-purple gradient
    page_layer = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    page_draw = ImageDraw.Draw(page_layer)
    page_draw.polygon(left_poly, fill=(108, 92, 231, 230))
    page_draw.polygon(right_poly, fill=(142, 123, 255, 240))

    # Inner page glow lines
    line_pen_l = (255, 255, 255, 160)
    page_draw.line([(spine_x - page_w * 0.2, spine_y), (spine_x - page_w * 0.75, spine_y - page_h * 0.4)], fill=line_pen_l, width=int(4 * scale))
    page_draw.line([(spine_x - page_w * 0.2, spine_y + page_h * 0.22), (spine_x - page_w * 0.72, spine_y - page_h * 0.18)], fill=line_pen_l, width=int(4 * scale))
    
    page_draw.line([(spine_x + page_w * 0.2, spine_y), (spine_x + page_w * 0.75, spine_y - page_h * 0.4)], fill=line_pen_l, width=int(4 * scale))
    page_draw.line([(spine_x + page_w * 0.2, spine_y + page_h * 0.22), (spine_x + page_w * 0.72, spine_y - page_h * 0.18)], fill=line_pen_l, width=int(4 * scale))

    fg = Image.alpha_composite(fg, page_layer)

    # --- B. Graduation Cap (Mortarboard) in 3D Isometric View ---
    cap_layer = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    cap_draw = ImageDraw.Draw(cap_layer)
    
    cap_cx = W * 0.5
    cap_cy = H * 0.42
    rx = W * 0.35
    ry = H * 0.14

    # Top Diamond of Cap
    diamond = [
        (cap_cx, cap_cy - ry),       # Top
        (cap_cx + rx, cap_cy),       # Right
        (cap_cx, cap_cy + ry),       # Bottom
        (cap_cx - rx, cap_cy),       # Left
    ]

    # Skull cap (underneath 3D base)
    skull = [
        (cap_cx - rx * 0.65, cap_cy + ry * 0.35),
        (cap_cx + rx * 0.65, cap_cy + ry * 0.35),
        (cap_cx + rx * 0.65, cap_cy + ry * 1.35),
        (cap_cx, cap_cy + ry * 1.8),
        (cap_cx - rx * 0.65, cap_cy + ry * 1.35),
    ]
    cap_draw.polygon(skull, fill=(40, 32, 90, 255))
    
    # Diamond with vibrant neon violet gradient
    cap_draw.polygon(diamond, fill=(91, 66, 243, 255))
    
    # Highlight facet on upper half of diamond
    facet = [
        (cap_cx, cap_cy - ry),
        (cap_cx + rx, cap_cy),
        (cap_cx, cap_cy),
    ]
    cap_draw.polygon(facet, fill=(125, 102, 255, 180))

    # Tassel hanging to left side
    tassel_pts = [
        (cap_cx, cap_cy),
        (cap_cx - rx * 0.7, cap_cy + ry * 0.6),
        (cap_cx - rx * 0.78, cap_cy + ry * 1.6),
    ]
    cap_draw.line(tassel_pts, fill=(0, 229, 255, 255), width=int(5 * scale))
    # Tassel pendant
    cap_draw.ellipse([
        cap_cx - rx * 0.78 - 8 * scale, cap_cy + ry * 1.6,
        cap_cx - rx * 0.78 + 8 * scale, cap_cy + ry * 1.6 + 24 * scale
    ], fill=(0, 229, 255, 255))

    # Button on center of cap
    cap_draw.ellipse([cap_cx - 10 * scale, cap_cy - 8 * scale, cap_cx + 10 * scale, cap_cy + 8 * scale], fill=(0, 245, 212, 255))

    fg = Image.alpha_composite(fg, cap_layer)

    # --- C. Radiant 4-Point AI Sparkle Star (Gemini Style) ---
    star_layer = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    star_draw = ImageDraw.Draw(star_layer)

    star_cx = W * 0.76
    star_cy = H * 0.26
    star_outer = W * 0.14
    star_inner = W * 0.035

    def draw_gemini_star(ctx, cx, cy, rout, rin, color):
        points = []
        for i in range(8):
            angle = i * (math.pi / 4) - math.pi / 2
            r = rout if i % 2 == 0 else rin
            px = cx + r * math.cos(angle)
            py = cy + r * math.sin(angle)
            points.append((px, py))
        ctx.polygon(points, fill=color)

    # Outer star glow
    for g_r in range(int(star_outer * 1.8), int(star_outer * 0.8), -6):
        alpha = int(40 * (1 - (g_r - star_outer * 0.8) / (star_outer)))
        draw_gemini_star(star_draw, star_cx, star_cy, g_r, int(g_r * 0.25), (0, 245, 212, max(0, alpha)))

    # Main Star in brilliant Cyan & White
    draw_gemini_star(star_draw, star_cx, star_cy, star_outer, star_inner, (0, 245, 212, 255))
    draw_gemini_star(star_draw, star_cx, star_cy, star_outer * 0.65, star_inner * 0.65, (255, 255, 255, 255))

    # Secondary Mini AI Sparkle on Left
    mini_cx = W * 0.22
    mini_cy = H * 0.29
    mini_out = W * 0.065
    mini_in = W * 0.018
    draw_gemini_star(star_draw, mini_cx, mini_cy, mini_out, mini_in, (255, 214, 0, 240))
    draw_gemini_star(star_draw, mini_cx, mini_cy, mini_out * 0.5, mini_in * 0.5, (255, 255, 255, 255))

    fg = Image.alpha_composite(fg, star_layer)

    # --- D. Glassmorphism Top Sheen ---
    sheen = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    sheen_draw = ImageDraw.Draw(sheen)
    sheen_draw.polygon([
        (0, 0), (W, 0), (W, int(H * 0.35)), (0, int(H * 0.58))
    ], fill=(255, 255, 255, 22))
    sheen.putalpha(mask)
    fg = Image.alpha_composite(fg, sheen)

    img = Image.alpha_composite(img, fg)

    # Downsample to target size with highest quality Lanczos filter
    final_img = img.resize((size, size), Image.Resampling.LANCZOS)
    return final_img

if __name__ == '__main__':
    output_dir = os.path.join('assets', 'icon')
    os.makedirs(output_dir, exist_ok=True)
    
    print("Generating ultra-premium 1024x1024 StudyMate AI app icon...")
    icon_1024 = create_super_icon(1024)
    icon_1024.save(os.path.join(output_dir, 'icon-1024.png'), 'PNG')
    print("Saved assets/icon/icon-1024.png")

    # Generate standard fallback sizes
    sizes = [512, 192, 144, 128, 96, 72, 48, 36]
    for s in sizes:
        resized = icon_1024.resize((s, s), Image.Resampling.LANCZOS)
        resized.save(os.path.join(output_dir, f'icon-{s}.png'), 'PNG')
        print(f"Saved assets/icon/icon-{s}.png")

    print("\nAll icons generated successfully!")
