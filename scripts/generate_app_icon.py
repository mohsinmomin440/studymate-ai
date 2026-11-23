import math
import os
from PIL import Image, ImageDraw, ImageFilter

def create_super_app_icon():
    # Supersampled 2048x2048 for silky anti-aliasing
    size = 2048
    cx, cy = size // 2, size // 2

    # -------------------------------------------------------------
    # 1. Background Canvas (Deep Royal Navy & Electric Violet Mesh)
    # -------------------------------------------------------------
    bg = Image.new('RGBA', (size, size), (11, 13, 27, 255))
    bg_draw = ImageDraw.Draw(bg)

    # 45-degree rich gradient: Deep Midnight Violet -> Rich Indigo -> Dark Abyss
    # Vectorized / scanned line-by-line
    top_c = (20, 15, 45)       # Deep violet navy
    mid_c = (49, 27, 105)      # Rich royal purple
    bot_c = (10, 14, 30)       # Deep obsidian navy

    for y in range(size):
        fy = y / size
        for x in range(0, size, 2):  # step by 2 for speed, filled smoothly
            fx = x / size
            t = (fx * 0.4 + fy * 0.6)
            if t < 0.5:
                p = t / 0.5
                r = int(top_c[0] + p * (mid_c[0] - top_c[0]))
                g = int(top_c[1] + p * (mid_c[1] - top_c[1]))
                b = int(top_c[2] + p * (mid_c[2] - top_c[2]))
            else:
                p = (t - 0.5) / 0.5
                r = int(mid_c[0] + p * (bot_c[0] - mid_c[0]))
                g = int(mid_c[1] + p * (bot_c[1] - mid_c[1]))
                b = int(mid_c[2] + p * (bot_c[2] - mid_c[2]))
            bg_draw.point((x, y), fill=(r, g, b, 255))
            bg_draw.point((x + 1, y), fill=(r, g, b, 255))

    # Ambient Glow Layers
    glow = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    gdraw = ImageDraw.Draw(glow)

    # Violet/Indigo aura
    for r in range(int(size * 0.42), 0, -12):
        alpha = int(45 * (1 - r / (size * 0.42)) ** 1.5)
        gdraw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(124, 58, 237, alpha))

    # Electric Cyan focal glow
    for r in range(int(size * 0.22), 0, -8):
        alpha = int(50 * (1 - r / (size * 0.22)) ** 1.3)
        gdraw.ellipse([cx - r, cy - int(r * 0.9) - 40, cx + r, cy + int(r * 0.9) - 40], fill=(6, 182, 212, alpha))

    # Center bright burst
    for r in range(int(size * 0.10), 0, -4):
        alpha = int(40 * (1 - r / (size * 0.10)))
        gdraw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(255, 255, 255, alpha))

    bg = Image.alpha_composite(bg, glow)

    # -------------------------------------------------------------
    # 2. Foreground Artwork Layer (Strictly inside safe zone circle)
    # Safe radius = size * 0.33 (~675px from center)
    # -------------------------------------------------------------
    fg = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    fdraw = ImageDraw.Draw(fg)

    # Sub-layer for drop shadows
    shadow = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(shadow)

    # --- A. Modern Open Book Base ---
    # Center position of book: lower third of safe zone
    book_cx = cx
    book_cy = cy + int(size * 0.16)
    book_w = int(size * 0.30)
    book_h = int(size * 0.12)

    # Shadow under book
    sdraw.ellipse([
        book_cx - int(book_w * 1.1), book_cy + int(book_h * 0.5),
        book_cx + int(book_w * 1.1), book_cy + int(book_h * 1.2)
    ], fill=(0, 0, 0, 90))

    # Glowing pedestal / book spine arc
    spine_pts = [
        (book_cx - book_w, book_cy + int(book_h * 0.4)),
        (book_cx, book_cy + int(book_h * 0.75)),
        (book_cx + book_w, book_cy + int(book_h * 0.4)),
        (book_cx + int(book_w * 0.96), book_cy + int(book_h * 0.55)),
        (book_cx, book_cy + int(book_h * 0.9)),
        (book_cx - int(book_w * 0.96), book_cy + int(book_h * 0.55)),
    ]
    fdraw.polygon(spine_pts, fill=(99, 102, 241, 230)) # Indigo glow cover

    # Left Page (Soft gradient lavender/white)
    left_page = [
        (book_cx - 4, book_cy - int(book_h * 0.1)),
        (book_cx - book_w, book_cy - int(book_h * 0.6)),
        (book_cx - int(book_w * 0.96), book_cy + int(book_h * 0.45)),
        (book_cx - 4, book_cy + int(book_h * 0.7)),
    ]
    fdraw.polygon(left_page, fill=(237, 233, 254, 255), outline=(167, 139, 250, 255), width=6)

    # Right Page (Crisp luminous white)
    right_page = [
        (book_cx + 4, book_cy - int(book_h * 0.1)),
        (book_cx + book_w, book_cy - int(book_h * 0.6)),
        (book_cx + int(book_w * 0.96), book_cy + int(book_h * 0.45)),
        (book_cx + 4, book_cy + int(book_h * 0.7)),
    ]
    fdraw.polygon(right_page, fill=(255, 255, 255, 255), outline=(196, 181, 253, 255), width=6)

    # Bookmark Ribbon in center
    ribbon = [
        (book_cx - 14, book_cy + int(book_h * 0.2)),
        (book_cx + 14, book_cy + int(book_h * 0.2)),
        (book_cx + 14, book_cy + int(book_h * 1.1)),
        (book_cx, book_cy + int(book_h * 0.95)),
        (book_cx - 14, book_cy + int(book_h * 1.1)),
    ]
    fdraw.polygon(ribbon, fill=(245, 158, 11, 255)) # Amber gold

    # Minimalist decorative page line accents (AI code/study lines)
    page_line_col_left = (139, 92, 246, 120)
    page_line_col_right = (6, 182, 212, 130)
    
    # Left lines
    fdraw.line([(book_cx - int(book_w * 0.25), book_cy + int(book_h * 0.1)),
                (book_cx - int(book_w * 0.75), book_cy - int(book_h * 0.2))],
               fill=page_line_col_left, width=7)
    fdraw.line([(book_cx - int(book_w * 0.25), book_cy + int(book_h * 0.35)),
                (book_cx - int(book_w * 0.70), book_cy + int(book_h * 0.1))],
               fill=page_line_col_left, width=7)

    # Right lines
    fdraw.line([(book_cx + int(book_w * 0.25), book_cy + int(book_h * 0.1)),
                (book_cx + int(book_w * 0.75), book_cy - int(book_h * 0.2))],
               fill=page_line_col_right, width=7)
    fdraw.line([(book_cx + int(book_w * 0.25), book_cy + int(book_h * 0.35)),
                (book_cx + int(book_w * 0.70), book_cy + int(book_h * 0.1))],
               fill=page_line_col_right, width=7)


    # --- B. 3D Floating Graduation Cap (Centerpiece) ---
    cap_cx = cx
    cap_cy = cy - int(size * 0.04)
    cap_rx = int(size * 0.31)
    cap_ry = int(size * 0.12)

    # Cap Skullcap / Base Cylinder Underneath
    skull_w = int(cap_rx * 0.58)
    skull_top = cap_cy + int(cap_ry * 0.35)
    skull_bot = cap_cy + int(cap_ry * 1.55)
    
    skull_pts = [
        (cap_cx - skull_w, skull_top),
        (cap_cx + skull_w, skull_top),
        (cap_cx + skull_w, skull_bot - int(cap_ry * 0.2)),
        (cap_cx, skull_bot + int(cap_ry * 0.3)),
        (cap_cx - skull_w, skull_bot - int(cap_ry * 0.2)),
    ]
    # Deep purple skullcap
    fdraw.polygon(skull_pts, fill=(30, 27, 75, 255), outline=(79, 70, 229, 200), width=6)

    # Skullcap rim highlight
    fdraw.arc([cap_cx - skull_w, skull_bot - int(cap_ry * 0.4),
               cap_cx + skull_w, skull_bot + int(cap_ry * 0.35)],
              start=10, end=170, fill=(129, 140, 248, 255), width=6)

    # Diamond Top Shadow
    sdraw.polygon([
        (cap_cx, cap_cy - cap_ry + 20),
        (cap_cx + cap_rx, cap_cy + 20),
        (cap_cx, cap_cy + cap_ry + 20),
        (cap_cx - cap_rx, cap_cy + 20),
    ], fill=(0, 0, 0, 110))

    # Diamond Left Facet (Lighted Royal Blue / Violet)
    diamond_left = [
        (cap_cx, cap_cy - cap_ry),
        (cap_cx - cap_rx, cap_cy),
        (cap_cx, cap_cy + cap_ry),
        (cap_cx, cap_cy),
    ]
    fdraw.polygon(diamond_left, fill=(79, 70, 229, 255)) # Vibrant Indigo

    # Diamond Right Facet (Lighter Electric Violet)
    diamond_right = [
        (cap_cx, cap_cy - cap_ry),
        (cap_cx + cap_rx, cap_cy),
        (cap_cx, cap_cy + cap_ry),
        (cap_cx, cap_cy),
    ]
    fdraw.polygon(diamond_right, fill=(99, 102, 241, 255)) # Indigo-500

    # Upper Top Light Reflection
    top_highlight = [
        (cap_cx, cap_cy - cap_ry),
        (cap_cx + int(cap_rx * 0.4), cap_cy - int(cap_ry * 0.5)),
        (cap_cx, cap_cy),
        (cap_cx - int(cap_rx * 0.4), cap_cy - int(cap_ry * 0.5)),
    ]
    fdraw.polygon(top_highlight, fill=(129, 140, 248, 140))

    # Glowing Rim Edge Stroke around cap
    diamond_border = [
        (cap_cx, cap_cy - cap_ry),
        (cap_cx + cap_rx, cap_cy),
        (cap_cx, cap_cy + cap_ry),
        (cap_cx - cap_rx, cap_cy),
    ]
    fdraw.polygon(diamond_border, outline=(199, 210, 254, 255), width=8)

    # Golden Tassel (Elegant drape to the left)
    tassel_btn_r = 18
    fdraw.ellipse([cap_cx - tassel_btn_r, cap_cy - tassel_btn_r,
                   cap_cx + tassel_btn_r, cap_cy + tassel_btn_r],
                  fill=(251, 191, 36, 255), outline=(245, 158, 11, 255), width=4)

    # Cord path
    cord_p1 = (cap_cx, cap_cy)
    cord_p2 = (cap_cx - int(cap_rx * 0.65), cap_cy + int(cap_ry * 0.55))
    cord_p3 = (cap_cx - int(cap_rx * 0.78), cap_cy + int(cap_ry * 1.6))
    fdraw.line([cord_p1, cord_p2, cord_p3], fill=(245, 158, 11, 255), width=10)

    # Tassel Golden Bob & Fringe
    fdraw.ellipse([cord_p3[0] - 14, cord_p3[1] - 4,
                   cord_p3[0] + 14, cord_p3[1] + 24],
                  fill=(252, 211, 77, 255))
    fdraw.polygon([
        (cord_p3[0] - 14, cord_p3[1] + 18),
        (cord_p3[0] + 14, cord_p3[1] + 18),
        (cord_p3[0] + 20, cord_p3[1] + 70),
        (cord_p3[0] - 20, cord_p3[1] + 70),
    ], fill=(245, 158, 11, 255))
    # Tassel shimmer
    fdraw.line([(cord_p3[0], cord_p3[1] + 20), (cord_p3[0], cord_p3[1] + 68)],
               fill=(254, 240, 138, 255), width=5)


    # --- C. Radiant Google Gemini 4-Point AI Sparkle Star ---
    # Function to draw astroid / 4-point star curve: (x/a)^0.5 + (y/a)^0.5 = 1 (superellipse)
    def draw_gemini_star(ctx, center_x, center_y, outer_r, fill_color):
        pts = []
        steps = 48
        for i in range(steps):
            theta = 2 * math.pi * i / steps
            cos_t = math.cos(theta)
            sin_t = math.sin(theta)
            # Astroid curve formula: x = R * cos^3(t), y = R * sin^3(t)
            # Rotated by 45 deg or standard 4-point
            x = center_x + outer_r * (math.copysign(abs(cos_t) ** 2.2, cos_t))
            y = center_y + outer_r * (math.copysign(abs(sin_t) ** 2.2, sin_t))
            pts.append((x, y))
        ctx.polygon(pts, fill=fill_color)

    # Primary Hero AI Star (Upper Right, radiating intelligence)
    star_x = cx + int(size * 0.22)
    star_y = cy - int(size * 0.23)
    s_radius = int(size * 0.13)

    # Multi-layered Star Bloom
    for r in range(int(s_radius * 1.8), int(s_radius * 0.7), -10):
        alpha = int(35 * (1 - (r - s_radius * 0.7) / (s_radius * 1.1)))
        draw_gemini_star(fdraw, star_x, star_y, r, (6, 182, 212, alpha))

    # Star outer cyan body
    draw_gemini_star(fdraw, star_x, star_y, s_radius, (6, 182, 212, 255)) # Cyan-500
    # Star inner teal-cyan highlight
    draw_gemini_star(fdraw, star_x, star_y, int(s_radius * 0.78), (34, 211, 238, 255)) # Cyan-400
    # Star core pure diamond white
    draw_gemini_star(fdraw, star_x, star_y, int(s_radius * 0.45), (255, 255, 255, 255)) # Pure white core

    # Accent Sparkle 1 (Upper Left, gold warm sparkle)
    s2_x = cx - int(size * 0.22)
    s2_y = cy - int(size * 0.21)
    s2_r = int(size * 0.055)
    for r in range(int(s2_r * 1.5), int(s2_r * 0.6), -6):
        alpha = int(30 * (1 - (r - s2_r * 0.6) / (s2_r * 0.9)))
        draw_gemini_star(fdraw, s2_x, s2_y, r, (251, 191, 36, alpha))
    draw_gemini_star(fdraw, s2_x, s2_y, s2_r, (251, 191, 36, 255))
    draw_gemini_star(fdraw, s2_x, s2_y, int(s2_r * 0.5), (255, 255, 255, 255))

    # Accent Sparkle 2 (Lower Right, small cyan sparkle near book)
    s3_x = cx + int(size * 0.28)
    s3_y = cy + int(size * 0.08)
    s3_r = int(size * 0.038)
    draw_gemini_star(fdraw, s3_x, s3_y, s3_r, (34, 211, 238, 240))
    draw_gemini_star(fdraw, s3_x, s3_y, int(s3_r * 0.45), (255, 255, 255, 255))


    # -------------------------------------------------------------
    # 3. Assemble Full Composite & Variants
    # -------------------------------------------------------------
    # Blur shadows softly
    shadow_blurred = shadow.filter(ImageFilter.GaussianBlur(16))

    # Full composition
    full = Image.alpha_composite(bg, shadow_blurred)
    full = Image.alpha_composite(full, fg)

    # Foreground only with shadow (for adaptive icon foreground)
    fg_only = Image.alpha_composite(shadow_blurred, fg)

    # Downsample with high-fidelity Lanczos filtering to 1024x1024
    icon_1024 = full.resize((1024, 1024), Image.Resampling.LANCZOS)
    fg_1024 = fg_only.resize((1024, 1024), Image.Resampling.LANCZOS)
    bg_1024 = bg.resize((1024, 1024), Image.Resampling.LANCZOS)

    return icon_1024, fg_1024, bg_1024

if __name__ == '__main__':
    out_dir = os.path.join('assets', 'icon')
    os.makedirs(out_dir, exist_ok=True)

    print("Generating studio-grade app icons...")
    icon_1024, fg_1024, bg_1024 = create_super_app_icon()

    # Save 1024 masters
    p_full = os.path.join(out_dir, 'icon-1024.png')
    p_fg = os.path.join(out_dir, 'icon-foreground.png')
    p_bg = os.path.join(out_dir, 'icon-background.png')

    icon_1024.save(p_full, 'PNG')
    fg_1024.save(p_fg, 'PNG')
    bg_1024.save(p_bg, 'PNG')
    print(f"Saved: {p_full}")
    print(f"Saved: {p_fg}")
    print(f"Saved: {p_bg}")

    # Generate standard resolution downsamples
    sizes = [512, 192, 144, 128, 96, 72, 48, 36]
    for s in sizes:
        sub = icon_1024.resize((s, s), Image.Resampling.LANCZOS)
        p = os.path.join(out_dir, f'icon-{s}.png')
        sub.save(p, 'PNG')

    # Also save splash icon (clean floating foreground emblem)
    p_splash = os.path.join(out_dir, 'splash-icon.png')
    fg_1024.resize((512, 512), Image.Resampling.LANCZOS).save(p_splash, 'PNG')
    print(f"Saved: {p_splash}")

    print("Successfully generated all icons!")
