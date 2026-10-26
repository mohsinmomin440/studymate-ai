# StudyMate AI

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)
![Dart](https://img.shields.io/badge/Dart-3.x-orange)
![Firebase](https://img.shields.io/badge/Firebase-Enabled-green)
![Platform](https://img.shields.io/badge/Platform-Android-orange)

An intelligent study planner and exam preparation app built with Flutter and Firebase.

---

## 📱 Features

### Core MVP
- ✅ Email/Password Authentication (Signup, Login, Logout, Password Reset)
- ✅ Subject Management (CRUD operations)
- ✅ Task Management with priority & due dates
- ✅ Rule-Based Study Schedule Generator
- ✅ Dashboard with today's tasks & upcoming exams
- ✅ Progress tracking with analytics charts
- ✅ Light & Dark mode with system preference sync

### Advanced Features
- 🤖 AI-powered summaries & quizzes (mock implementation)
- 📊 Weekly study hour analytics
- 🔔 Study reminders UI (notifications pending Firebase config)
- ⏱️ Study session timer (planned)

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|------------|
| **UI Framework** | Flutter + Dart |
| **State Management** | Riverpod (`flutter_riverpod`) |
| **Navigation** | GoRouter (`go_router`) |
| **Authentication** | Firebase Authentication |
| **Database** | Cloud Firestore |
| **Storage** | Firebase Storage |
| **Notifications** | `flutter_local_notifications` (pending) |
| **Charts** | `fl_chart` |
| **Dates** | `intl` |
| **IDs** | `uuid` |

---

## 📁 Project Structure

```
lib/
├── main.dart                  # App entry point
├── firebase_options.dart      # Firebase configuration (auto-generated)
├── app/
│   ├── app.dart               # Material app setup
│   ├── router.dart            # GoRouter navigation
│   └── main_shell_screen.dart # Bottom nav shell
├── core/
│   ├── constants/             # App colors, constants
│   ├── theme/                 # Light/Dark theme
│   └── widgets/               # Reusable UI components
├── services/
│   ├── firebase_service.dart  # Firebase initialization
│   └── ai_service.dart        # AI tutor service (mock)
└── features/
    ├── auth/                  # Login, Signup, Profile
    ├── subjects/              # Subject CRUD
    ├── tasks/                 # Task management
    ├── planner/               # Schedule generation
    ├── dashboard/             # Home screen
    ├── analytics/             # Charts & progress
    ├── quizzes/               # Quiz UI (pending Firestore)
    └── ai_tutor/              # AI tutor interface
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (≥3.13.5)
- Android Studio / VS Code
- Firebase project configured
- Git installed

### Installation

```bash
# Clone repository
git clone https://github.com/USERNAME/studymate-ai.git
cd studymate-ai

# Install dependencies
flutter pub get

# Configure Firebase
firebase login
dart pub global activate flutterfire_cli
flutterfire configure

# Run on device/emulator
flutter run
```

---

## 🔐 Firebase Setup

### Quick Setup Commands

```bash
# 1. Login to Firebase CLI
firebase login

# 2. Activate FlutterFire CLI
dart pub global activate flutterfire_cli

# 3. Configure Firebase for Android
flutterfire configure

# 4. Get dependencies
flutter pub get
```

The `flutterfire configure` command will:
1. Fetch your Firebase projects
2. Generate `lib/firebase_options.dart`
3. Download `google-services.json` to `android/app/`
4. Configure all Firebase dependencies

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run unit tests only
flutter test test/unit/

# Run widget tests
flutter test test/widget_test.dart
```

---

## 📊 Security Rules

### Firestore Rules (`firestore.rules`)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      match /{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

### Storage Rules (`storage.rules`)
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

Deploy rules:
```bash
firebase deploy --only firestore:rules,storage:rules
```

---

## 📱 Screenshots

### Light Mode
![Light Mode Screenshot](./StudyMate%20AI%20App%20Showcase%20Board%20-%20Light%20Mode.png)

### Dark Mode
![Dark Mode Screenshot](./StudyMate%20AI%20UI%20Showcase%20-%20Dark%20Mode.png)

---

## 🎓 BCA Final Year Project

**Course:** BCA Semester 6  
**Project Type:** Advanced Mobile Application  
**Difficulty:** Medium–Hard  

### Academic Deliverables
- [x] Source code (this repository)
- [ ] Firebase Console project
- [ ] Firestore database schema
- [ ] UI/UX design document
- [ ] Video demonstration
- [ ] Viva preparation notes

---

## 📝 License

This project is for educational purposes as part of BCA final year submission.

---

## 🙏 Acknowledgments

- Built with [Flutter](https://flutter.dev)
- Backend powered by [Firebase](https://firebase.google.com)
- State management using [Riverpod](https://riverpod.dev)
- AI assistance by [Claude Code](https://claude.com/code) (Anthropic)

---

## 👥 Contributors

- **Mohsin Momin** — Project Owner & Developer
---

**Made with ❤️ by BCA Final Year Student**

*Last updated: 2026-10-26 12:54:21 by Mohsin Momin*
