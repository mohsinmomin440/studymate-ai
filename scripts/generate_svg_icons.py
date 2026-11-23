import os

svg_dir = os.path.join("assets", "svg")
os.makedirs(svg_dir, exist_ok=True)

icons = {
    # 1. Streak Flame (Fire)
    "streak_flame.svg": """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="48" height="48">
  <defs>
    <linearGradient id="flameOuter" x1="0%" y1="100%" x2="0%" y2="0%">
      <stop offset="0%" stop-color="#FF3D00"/>
      <stop offset="50%" stop-color="#FF9100"/>
      <stop offset="100%" stop-color="#FFD600"/>
    </linearGradient>
    <linearGradient id="flameInner" x1="0%" y1="100%" x2="0%" y2="0%">
      <stop offset="0%" stop-color="#FF6D00"/>
      <stop offset="60%" stop-color="#FFD600"/>
      <stop offset="100%" stop-color="#FFF9C4"/>
    </linearGradient>
    <filter id="glow" x="-20%" y="-20%" width="140%" height="140%">
      <feGaussianBlur stdDeviation="2" result="blur" />
      <feComposite in="SourceGraphic" in2="blur" operator="over" />
    </filter>
  </defs>
  <path d="M24 4C24 4 28 11 28 17C28 19.5 27 21.8 25.5 23.5C28.5 22 31.5 19 32 15C36 19.5 38 25 38 30C38 38 31.7 44 24 44C16.3 44 10 38 10 30C10 22.8 14.5 16.5 19 12C20 16 22 18.5 24 18.5C24 16 23.5 10 24 4Z" fill="url(#flameOuter)" filter="url(#glow)"/>
  <path d="M24 22C24 22 27 26 27 29.5C27 31 26.2 32.3 25 33.2C26.8 32.2 28.5 30 29 27C31 29.8 31.5 33 30.5 35.5C29 39 26 41 24 41C20.5 41 17.5 38 17.5 34C17.5 29.5 20.5 26 24 22Z" fill="url(#flameInner)"/>
</svg>""",

    # 2. XP Energy Bolt (Lightning)
    "xp_bolt.svg": """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="48" height="48">
  <defs>
    <linearGradient id="boltGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#00E5FF"/>
      <stop offset="50%" stop-color="#00B0FF"/>
      <stop offset="100%" stop-color="#7C4DFF"/>
    </linearGradient>
    <linearGradient id="boltCore" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#E0F7FA"/>
      <stop offset="100%" stop-color="#80D8FF"/>
    </linearGradient>
  </defs>
  <path d="M27 4L9 26H23L19 44L39 20H24L27 4Z" fill="url(#boltGrad)"/>
  <path d="M25 8L13 24H23L20 38L34 22H24L25 8Z" fill="url(#boltCore)" opacity="0.6"/>
</svg>""",

    # 3. Gold Trophy
    "trophy.svg": """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="48" height="48">
  <defs>
    <linearGradient id="goldCup" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#FFE082"/>
      <stop offset="40%" stop-color="#FFD54F"/>
      <stop offset="80%" stop-color="#FFA000"/>
      <stop offset="100%" stop-color="#FF8F00"/>
    </linearGradient>
    <linearGradient id="baseGrad" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#546E7A"/>
      <stop offset="100%" stop-color="#263238"/>
    </linearGradient>
  </defs>
  <path d="M14 6H34V18C34 24.6 29.5 30 24 30C18.5 30 14 24.6 14 18V6Z" fill="url(#goldCup)"/>
  <path d="M14 10H8C6.9 10 6 10.9 6 12C6 17 9.5 21 14 21.8V18C11 17.5 9 15 9 12.5H14V10Z" fill="url(#goldCup)"/>
  <path d="M34 10H40C41.1 10 42 10.9 42 12C42 17 38.5 21 34 21.8V18C37 17.5 39 15 39 12.5H34V10Z" fill="url(#goldCup)"/>
  <path d="M21 30H27V36H21V30Z" fill="url(#goldCup)"/>
  <path d="M15 36H33C34.1 36 35 36.9 35 38V42C35 43.1 34.1 44 33 44H15C13.9 44 13 43.1 13 42V38C13 36.9 13.9 36 15 36Z" fill="url(#baseGrad)"/>
  <circle cx="24" cy="17" r="4" fill="#FFF8E1" opacity="0.6"/>
</svg>""",

    # 4. Celebration (Party Popper / Starburst)
    "celebration.svg": """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="48" height="48">
  <defs>
    <linearGradient id="coneGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#FF4081"/>
      <stop offset="50%" stop-color="#7C4DFF"/>
      <stop offset="100%" stop-color="#00E5FF"/>
    </linearGradient>
  </defs>
  <path d="M8 40L14 24L30 36L8 40Z" fill="url(#coneGrad)"/>
  <circle cx="28" cy="18" r="3" fill="#FFD600"/>
  <circle cx="38" cy="14" r="2.5" fill="#FF1744"/>
  <circle cx="36" cy="28" r="2" fill="#00E676"/>
  <circle cx="22" cy="10" r="2" fill="#00B0FF"/>
  <path d="M30 6L32 10L36 10L33 13L34 17L30 14L26 17L27 13L24 10L28 10Z" fill="#FFEA00"/>
  <path d="M18 20C18 16 22 14 25 12" stroke="#FF4081" stroke-width="2" stroke-linecap="round" fill="none"/>
  <path d="M26 26C28 24 33 24 35 21" stroke="#00E5FF" stroke-width="2" stroke-linecap="round" fill="none"/>
</svg>""",

    # 5. Open Study Book
    "study_book.svg": """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="48" height="48">
  <defs>
    <linearGradient id="bookLeft" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#6C5CE7"/>
      <stop offset="100%" stop-color="#8E7BFF"/>
    </linearGradient>
    <linearGradient id="bookRight" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#8E7BFF"/>
      <stop offset="100%" stop-color="#A29BFE"/>
    </linearGradient>
    <linearGradient id="pageGlow" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#FFFFFF"/>
      <stop offset="100%" stop-color="#E2E8F0"/>
    </linearGradient>
  </defs>
  <path d="M6 36C12 33 18 33 24 36V12C18 9 12 9 6 12V36Z" fill="url(#pageGlow)"/>
  <path d="M42 36C36 33 30 33 24 36V12C30 9 36 9 42 12V36Z" fill="url(#pageGlow)"/>
  <path d="M6 36C12 33 18 33 24 36C30 33 36 33 42 36C43 36.5 44 35.8 44 34.5V10C44 9.2 43.3 8.5 42.5 8.2C36.8 5.8 30.8 5.8 24 8.5C17.2 5.8 11.2 5.8 5.5 8.2C4.7 8.5 4 9.2 4 10V34.5C4 35.8 5 36.5 6 36Z" fill="none" stroke="url(#bookLeft)" stroke-width="2.5" stroke-linejoin="round"/>
  <line x1="24" y1="9" x2="24" y2="36" stroke="url(#bookLeft)" stroke-width="2"/>
  <path d="M10 17H20M10 23H18M10 29H16" stroke="#94A3B8" stroke-width="2" stroke-linecap="round"/>
  <path d="M28 17H38M30 23H38M32 29H38" stroke="#94A3B8" stroke-width="2" stroke-linecap="round"/>
</svg>""",

    # 6. AI Robot / Tutor Head
    "robot_ai.svg": """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="48" height="48">
  <defs>
    <linearGradient id="botHead" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#6C5CE7"/>
      <stop offset="100%" stop-color="#00D4C8"/>
    </linearGradient>
    <linearGradient id="botFace" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#141828"/>
      <stop offset="100%" stop-color="#0B0D17"/>
    </linearGradient>
  </defs>
  <rect x="8" y="12" width="32" height="26" rx="8" fill="url(#botHead)"/>
  <rect x="11" y="15" width="26" height="20" rx="5" fill="url(#botFace)"/>
  <line x1="24" y1="6" x2="24" y2="12" stroke="#00D4C8" stroke-width="3" stroke-linecap="round"/>
  <circle cx="24" cy="5" r="3" fill="#00D4C8"/>
  <circle cx="18" cy="24" r="3.5" fill="#00E5FF"/>
  <circle cx="30" cy="24" r="3.5" fill="#00E5FF"/>
  <path d="M20 30C22 32 26 32 28 30" stroke="#00D4C8" stroke-width="2" stroke-linecap="round" fill="none"/>
  <rect x="4" y="21" width="4" height="8" rx="2" fill="#6C5CE7"/>
  <rect x="40" y="21" width="4" height="8" rx="2" fill="#00D4C8"/>
</svg>""",

    # 7. Doubt Scanner / Camera
    "camera_scan.svg": """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="48" height="48">
  <defs>
    <linearGradient id="camGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#FF5C7A"/>
      <stop offset="100%" stop-color="#6C5CE7"/>
    </linearGradient>
  </defs>
  <rect x="6" y="12" width="36" height="28" rx="6" fill="url(#camGrad)"/>
  <path d="M16 12L19 7H29L32 12H16Z" fill="#6C5CE7"/>
  <circle cx="24" cy="26" r="9" fill="#141828"/>
  <circle cx="24" cy="26" r="7" fill="url(#camGrad)"/>
  <circle cx="26" cy="24" r="2.5" fill="#FFFFFF"/>
  <path d="M10 8H6V12M38 8H42V12M10 40H6V36M38 40H42V36" stroke="#00E5FF" stroke-width="2.5" stroke-linecap="round"/>
</svg>""",

    # 8. Flashcards Stack
    "cards_stack.svg": """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="48" height="48">
  <defs>
    <linearGradient id="card1" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#00D4C8"/>
      <stop offset="100%" stop-color="#6C5CE7"/>
    </linearGradient>
    <linearGradient id="card2" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#FFB020"/>
      <stop offset="100%" stop-color="#FF5C7A"/>
    </linearGradient>
  </defs>
  <rect x="14" y="6" width="26" height="32" rx="4" transform="rotate(12 27 22)" fill="url(#card2)" opacity="0.8"/>
  <rect x="8" y="10" width="28" height="32" rx="4" fill="url(#card1)"/>
  <path d="M14 20H26M14 26H22" stroke="#FFFFFF" stroke-width="2.5" stroke-linecap="round"/>
  <circle cx="30" cy="36" r="3" fill="#FFFFFF"/>
</svg>""",

    # 9. Focus Timer / Pomodoro Clock
    "timer_clock.svg": """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="48" height="48">
  <defs>
    <linearGradient id="clockRing" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#2ED573"/>
      <stop offset="100%" stop-color="#00D4C8"/>
    </linearGradient>
  </defs>
  <circle cx="24" cy="26" r="16" fill="#141828" stroke="url(#clockRing)" stroke-width="3"/>
  <path d="M24 16V26L30 30" stroke="#2ED573" stroke-width="2.5" stroke-linecap="round"/>
  <path d="M21 6H27V9H21V6ZM12 11L15 14M36 11L33 14" stroke="#00D4C8" stroke-width="2.5" stroke-linecap="round"/>
</svg>""",

    # 10. Target / Bullseye (Goal Achieved)
    "target_bullseye.svg": """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="48" height="48">
  <defs>
    <linearGradient id="targetRed" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#FF5C7A"/>
      <stop offset="100%" stop-color="#FF3838"/>
    </linearGradient>
  </defs>
  <circle cx="24" cy="24" r="19" fill="#F4F6FF"/>
  <circle cx="24" cy="24" r="15" fill="url(#targetRed)"/>
  <circle cx="24" cy="24" r="10" fill="#F4F6FF"/>
  <circle cx="24" cy="24" r="5" fill="url(#targetRed)"/>
  <path d="M38 10L42 6M38 10L34 10M38 10L38 14" stroke="#FF5C7A" stroke-width="2.5" stroke-linecap="round"/>
</svg>""",

    # 11. Badge: First Quiz
    "badge_first_quiz.svg": """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="48" height="48">
  <defs>
    <linearGradient id="fqGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#00D4C8"/>
      <stop offset="100%" stop-color="#6C5CE7"/>
    </linearGradient>
  </defs>
  <polygon points="24,4 42,14 42,34 24,44 6,34 6,14" fill="url(#fqGrad)"/>
  <circle cx="24" cy="24" r="14" fill="#141828"/>
  <text x="24" y="29" font-family="sans-serif" font-size="14" font-weight="bold" fill="#00E5FF" text-anchor="middle">1Q</text>
</svg>""",

    # 12. Badge: Quiz Master
    "badge_quiz_master.svg": """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="48" height="48">
  <defs>
    <linearGradient id="qmGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#FFD700"/>
      <stop offset="100%" stop-color="#FF8C00"/>
    </linearGradient>
  </defs>
  <polygon points="24,4 42,14 42,34 24,44 6,34 6,14" fill="url(#qmGrad)"/>
  <circle cx="24" cy="24" r="14" fill="#141828"/>
  <path d="M18 19L24 15L30 19L28 28H20L18 19Z" fill="url(#qmGrad)"/>
  <circle cx="24" cy="23" r="2" fill="#FFF"/>
</svg>""",

    # 13. Badge: Note Taker
    "badge_note_taker.svg": """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="48" height="48">
  <defs>
    <linearGradient id="ntGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#2ED573"/>
      <stop offset="100%" stop-color="#10AC84"/>
    </linearGradient>
  </defs>
  <polygon points="24,4 42,14 42,34 24,44 6,34 6,14" fill="url(#ntGrad)"/>
  <circle cx="24" cy="24" r="14" fill="#141828"/>
  <path d="M19 16H27L31 20V32H19V16Z" fill="url(#ntGrad)"/>
  <line x1="22" y1="23" x2="28" y2="23" stroke="#FFF" stroke-width="1.5" stroke-linecap="round"/>
  <line x1="22" y1="27" x2="26" y2="27" stroke="#FFF" stroke-width="1.5" stroke-linecap="round"/>
</svg>""",

    # 14. Badge: Curious Mind (Chat)
    "badge_curious_mind.svg": """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="48" height="48">
  <defs>
    <linearGradient id="cmGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#9C27B0"/>
      <stop offset="100%" stop-color="#673AB7"/>
    </linearGradient>
  </defs>
  <polygon points="24,4 42,14 42,34 24,44 6,34 6,14" fill="url(#cmGrad)"/>
  <circle cx="24" cy="24" r="14" fill="#141828"/>
  <circle cx="24" cy="22" r="6" fill="url(#cmGrad)"/>
  <text x="24" y="25" font-family="sans-serif" font-size="9" font-weight="bold" fill="#FFF" text-anchor="middle">AI</text>
  <path d="M21 31C21 29 27 29 27 31" stroke="url(#cmGrad)" stroke-width="2" stroke-linecap="round"/>
</svg>""",

    # 15. Badge: Week Warrior (7 Days)
    "badge_streak_7.svg": """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="48" height="48">
  <defs>
    <linearGradient id="s7Grad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#FF9800"/>
      <stop offset="100%" stop-color="#F44336"/>
    </linearGradient>
  </defs>
  <polygon points="24,4 42,14 42,34 24,44 6,34 6,14" fill="url(#s7Grad)"/>
  <circle cx="24" cy="24" r="14" fill="#141828"/>
  <text x="24" y="29" font-family="sans-serif" font-size="14" font-weight="bold" fill="#FFB74D" text-anchor="middle">7D</text>
</svg>""",

    # 16. Badge: Month Master (30 Days)
    "badge_streak_30.svg": """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="48" height="48">
  <defs>
    <linearGradient id="s30Grad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#E91E63"/>
      <stop offset="100%" stop-color="#9C27B0"/>
    </linearGradient>
  </defs>
  <polygon points="24,4 42,14 42,34 24,44 6,34 6,14" fill="url(#s30Grad)"/>
  <circle cx="24" cy="24" r="14" fill="#141828"/>
  <text x="24" y="29" font-family="sans-serif" font-size="13" font-weight="bold" fill="#F48FB1" text-anchor="middle">30D</text>
</svg>""",

    # 17. Badge: Flashcard Pro (100 Cards)
    "badge_cards_100.svg": """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="48" height="48">
  <defs>
    <linearGradient id="c100Grad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#00BCD4"/>
      <stop offset="100%" stop-color="#3F51B5"/>
    </linearGradient>
  </defs>
  <polygon points="24,4 42,14 42,34 24,44 6,34 6,14" fill="url(#c100Grad)"/>
  <circle cx="24" cy="24" r="14" fill="#141828"/>
  <text x="24" y="28" font-family="sans-serif" font-size="11" font-weight="bold" fill="#80DEEA" text-anchor="middle">100</text>
</svg>""",

    # 18. Badge: Focus Champion (5 Hours)
    "badge_focus_5.svg": """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="48" height="48">
  <defs>
    <linearGradient id="f5Grad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#4CAF50"/>
      <stop offset="100%" stop-color="#009688"/>
    </linearGradient>
  </defs>
  <polygon points="24,4 42,14 42,34 24,44 6,34 6,14" fill="url(#f5Grad)"/>
  <circle cx="24" cy="24" r="14" fill="#141828"/>
  <text x="24" y="29" font-family="sans-serif" font-size="13" font-weight="bold" fill="#A5D6A7" text-anchor="middle">5h</text>
</svg>"""
}

for name, content in icons.items():
    filepath = os.path.join(svg_dir, name)
    with open(filepath, "w", encoding="utf-8") as f:
        f.write(content.strip() + "\n")
    print(f"Generated: {filepath}")

print(f"\nSuccessfully generated {len(icons)} SVG icons in {svg_dir}/!")
