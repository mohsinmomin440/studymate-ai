# Privacy Policy

**Effective Date:** November 2024

## 1. Introduction

StudyMate AI ("we", "us", or "our") respects your privacy and is committed to protecting your personal data. This Privacy Policy describes how we collect, use, and safeguard your information when you use our mobile application.

## 2. Information We Collect

### 2.1 User Account Information
- **Email address** (required for Google Sign-In or Email/Password authentication)
- **Display name**
- **Profile picture** (from Google or custom avatar)
- **App language preference** (English, Gujarati, Hindi)
- **Study preferences** (class/grade, subjects, daily goal)

### 2.2 Study Data (Stored in Firestore)
All personal data is stored in **Cloud Firestore** under `users/{uid}`:
- **Chat history** - Your conversations with the AI tutor
- **Doubts** - Questions saved from the doubt scanner feature
- **Notes** - Study notes you create
- **Flashcards** - Cards and decks you create
- **Quizzes** - Generated quizzes and your attempts/scores
- **Study plans** - AI-generated study schedules
- **Daily stats** - Study minutes, XP earned, activities completed
- **Badges** - Unlocked achievements

### 2.3 AI Processing (via Google Gemini)
When you use AI features, your content is sent to **Google Gemini API** for processing:
- Chat messages
- Scanned questions (image -> text via Gemini multimodal)
- Note summaries and transformations
- Quiz/flashcard generation

**Important:** Gemini processes your data to provide AI assistance. The content you send is used only to generate responses and is not stored by us beyond what you save.

## 3. How We Use Your Information

1. **Authentication** - Sign you in and manage your account
2. **Personalization** - Customize study plans and recommendations
3. **Data Persistence** - Save your progress across devices
4. **AI Assistance** - Provide accurate responses from Gemini
5. **Progress Tracking** - Calculate streaks, XP, and badges
6. **Notifications** - Send study reminders and reminders
7. **Analytics** - Understand app usage to improve features (via Firebase Analytics)
8. **Crash Reporting** - Fix bugs (via Firebase Crashlytics)

## 4. Data Sharing

- **No third-party advertising or analytics** beyond Firebase
- **No sale of personal data**
- **No sharing with other users** - data is private to your account

## 5. Your Data Rights

### 5.1 Access Your Data
You can view all your personal data through the app's Study Hub and Progress screens.

### 5.2 Delete Your Account & Data
**To delete your account and all associated data:**
1. Open the app
2. Go to Settings → Account
3. Tap "Delete Account & Data"
4. Confirm deletion

This permanently deletes:
- Your Firestore data (profile, chats, notes, flashcards, quizzes, plans, stats, badges)
- Your authentication account
- **Note:** Data may take up to 30 days to fully propagate from backup systems

### 5.3 Export Data
You can copy your notes, chat history, and quiz results manually through the app's share features.

## 6. Data Security

- **Authentication:** Secure Google Sign-In with OAuth 2.0
- **Encryption:** Data encrypted in transit (HTTPS/TLS) and at rest
- **Firestore Rules:** Strict user-based security rules ensure only you can access your data
- **App Check:** Firebase App Check prevents unauthorized access

## 7. International Data Transfer

Google's Gemini API may process your data outside your country. By using our app, you consent to this transfer.

## 8. Children's Privacy

Our app is designed for students aged 13 and above. We do not knowingly collect personal information from children under 13.

## 9. Changes to This Privacy Policy

We may update this policy. Changes will be posted in-app with an updated date.

## 10. Contact

For privacy questions:
- Email: Through Firebase App Check secure channel
- In-app: Settings → Feedback

---

*This privacy policy matches the actual data handling in the app: Firestore storage with user-only access rules, Google Sign-In authentication, Gemini AI processing, and account deletion capability.*