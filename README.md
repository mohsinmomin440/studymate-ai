# StudyMate AI 📚

An AI-powered Android study app built with Flutter, Riverpod, Firebase (Firestore + Gemini API), and Material 3. Features flashcards, quizzes, notes, AI tutor chat, focus timer, and progress tracking — all free with Firebase Spark plan.

[![MIT License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-blue.svg)](https://dart.dev)

## ⚖️ License & Warranty

This project is licensed under the **MIT License** - Copyright (c) 2024 Mohsin Momin.

### ✅ You Are Free To:
- Use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the software
- Use commercially or privately
- Modify for personal or team use
- Use in any type of application (open source or proprietary)

### ❌ Warranty Disclaimer:
- **NO WARRANTY PROVIDED** - The software is provided "AS IS", without warranty of any kind
- **AUTHOR NOT LIABLE** - In no event shall the authors or copyright holders be liable for any claim, damages, or other liability arising from, out of, or in connection with the software

See [LICENSE](LICENSE) for full details.

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🤖 AI Tutor Chat | Ask doubts, get step-by-step solutions via Gemini |
| 📸 Doubt Scanner | Snap a photo → instant solution |
| 📝 Notes | Rich-text notes with AI summary, key points, translation |
| 🃏 Flashcards | SM-2 spaced repetition algorithm |
| 📋 Quiz Generator | MCQ from any topic/note, timed option |
| 📅 Study Planner | Day-by-day exam prep schedule |
| ⏱️ Focus Timer | Pomodoro with session logging |
| 📊 Progress | XP, streaks, badges, charts |
| 🌐 Multi-language | English, ગુજરાતી, हिंदी |

## 🛠️ Tech Stack

- **Framework:** Flutter 3.x (Material 3)
- **State Management:** Riverpod
- **Backend:** Firebase (Auth, Firestore, Analytics, Crashlytics, App Check, AI Logic/Gemini)
- **Navigation:** go_router
- **Architecture:** Clean feature-first layered architecture

## 🚀 Getting Started

### Prerequisites
- Flutter SDK >= 3.5.0
- Dart >= 3.5.0
- Firebase project (Spark/free plan)

### Setup
```bash
git clone https://github.com/mohsinmomin440/studymate-ai.git
cd studymate-ai
flutter pub get
flutterfire configure   # Generate lib/firebase_options.dart
flutter run --release
```

## 📁 Project Structure

```
lib/
  main.dart                   # Entry point
  app.dart                    # MaterialApp router, theme, localization
  core/                       # Theme, router, constants, services, utils
  shared/                     # Reusable widgets, models
  features/                   # Feature modules (auth, chat, notes, etc.)
l10n/                         # Localization (en, gu, hi ARB files)
test/                         # Unit & widget tests (255+ tests)
android/                      # Android native config
docs/                         # Privacy policy, play store listing
```

## 🧪 Testing

```bash
flutter test                    # Run all tests (255 pass)
flutter analyze                 # Static analysis (0 errors)
flutter build apk --release     # Build APK
flutter build appbundle --release  # Build AAB (67MB)
```

## 🔒 Security

- Firestore security rules: `users/{uid}` — only owner can read/write
- App Check enabled (Play Integrity / Debug provider)
- No hardcoded secrets/API keys
- Local notifications require explicit permission

## 📄 Docs

- [Privacy Policy](docs/privacy_policy.md)
- [Play Store Listing](docs/play_store_listing.md)
- [CLAUDE.md](CLAUDE.md) — Full development guide

## 👤 Author

**Mohsin Momin** — github.com/mohsinmomin440

## 📬 Contact

For issues, feedback, or questions — open a GitHub issue or contact via the app's in-app feedback feature.

---

*Made with ❤️ using Flutter + Firebase + Gemini AI*
