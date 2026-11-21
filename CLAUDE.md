# CLAUDE.md — StudyMate AI (Flutter + Firebase + Gemini)

> Claude Code: read this whole file before writing any code. It is the source of truth for this project.
> Build the app phase by phase (see "Build Phases"). Finish and verify one phase before starting the next.

---

## 1. Project Summary

**StudyMate AI** is a premium-looking Android app (Flutter) that helps students study smarter with AI.
Backend = Firebase (free Spark plan). AI = Google Gemini (free tier). The whole stack must work at **zero cost**.

**Target user:** school / college students (India first; English + Gujarati + Hindi UI).
**Platform:** Android first. Keep code iOS-compatible but do not spend time on iOS.
**Owner:** solo developer using Claude Code. Explain important decisions briefly; do not over-explain.

### Core promise
Ask a doubt, snap a photo of a question, make notes, auto-generate flashcards and quizzes, get a study plan, track streaks and progress — all in one beautiful app.

---

## 2. Hard Constraints (never violate)

1. **Free only.** Use Firebase **Spark (no billing)**. Do NOT use anything that requires the Blaze plan:
   - No Cloud Functions.
   - No Firebase Storage (new projects need Blaze). Store text in Firestore, keep images/PDF local on device, and send only the needed text/image bytes to Gemini.
2. **No secrets in the repo.** Never hardcode a Gemini API key. Use **Firebase AI Logic** (`firebase_ai` package, Gemini Developer API) so the key stays on Firebase's side. Enable **Firebase App Check** (Play Integrity; debug provider for dev).
3. **Gemini free tier has rate limits.** Always handle errors (429 / quota / network) gracefully with friendly messages, retry with exponential backoff (max 3 tries), and never loop endlessly.
4. **Verify before using.** Package versions, Gemini model names and Firebase APIs change often. Before using any package or model, check the latest docs (pub.dev, firebase.google.com/docs/ai-logic, ai.google.dev) and use current names. Never guess an API from memory.
5. **Premium UI is mandatory** (see section 5). No default-looking Material screens.
6. **Android-first, offline-friendly.** Enable Firestore offline persistence. App must not crash with no internet.
7. **Privacy:** each user can only read/write their own data. Provide "Delete my account & data".

---

## 3. Tech Stack

| Area | Choice |
|---|---|
| Framework | Flutter (latest stable), Dart null-safety, Material 3 |
| State management | `flutter_riverpod` (use `riverpod_annotation` + generator if stable, else plain providers) |
| Navigation | `go_router` (with auth redirect guard) |
| Backend | Firebase: Auth, Cloud Firestore, Remote Config, Analytics, Crashlytics, App Check, FCM (optional) |
| AI | `firebase_ai` → Gemini Developer API (pick a current **flash** model for chat/quiz, **flash-lite** for cheap tasks) |
| Auth | Google Sign-In + Email/Password + Anonymous (guest, upgradeable to full account) |
| Models | `freezed` + `json_serializable` (or plain immutable classes if simpler) |
| UI libs | `google_fonts`, `flutter_animate`, `shimmer`, `lottie` (optional), `fl_chart`, `flutter_svg`, `gap` |
| Device | `image_picker`, `file_picker`, `flutter_local_notifications`, `permission_handler`, `share_plus`, `url_launcher` |
| PDF text | a free PDF text extraction package (e.g. `syncfusion_flutter_pdf` community license or `pdfx`) — check license first |
| Markdown | `flutter_markdown` (+ LaTeX/math rendering package if available) for AI answers |
| Quality | `flutter_lints`, `very_good_analysis` optional, `flutter_test`, `mocktail` |

---

## 4. Features (build ALL of these, A to Z)

### 4.1 Onboarding & Auth
- Animated splash + 3-screen onboarding (skip button, page indicator, gradient illustrations).
- Sign in: Google, Email/Password, Continue as Guest (anonymous). Guest can later link to Google/Email without losing data.
- Forgot password, email validation, friendly error messages.
- Profile setup: name, avatar (preset avatars/initials gradient), class/grade, subjects of interest, daily study goal (minutes), app language.

### 4.2 Home Dashboard
- Greeting by time of day, streak flame, XP/level bar, today's goal ring (progress).
- "Continue studying" card, today's planned tasks, quick actions (Ask AI, Scan Doubt, New Note, Quick Quiz).
- Due flashcards count, motivational quote (Remote Config or local list).

### 4.3 AI Tutor Chat
- Streaming responses (typewriter feel), markdown + code + math rendering.
- Modes (chips): Explain Simply, Step-by-Step, Exam Answer, Quick Summary, Teach Me Like I'm 10.
- Subject selector (Maths, Science, English, Gujarati, Hindi, Social Science, Computer, Other).
- Chat history saved in Firestore (list, rename, delete). Copy / share / regenerate / "save to notes" on each answer.
- Language-aware: reply in the user's chosen language (English / Gujarati / Hindi / Hinglish).
- System prompt: friendly study tutor, accurate, step-by-step, no cheating on exams, asks a follow-up question to check understanding, politely refuses unsafe/off-topic content.
- Input length limits and a client-side daily usage counter to protect the free quota.

### 4.4 Doubt Scanner (Camera/Gallery → Gemini multimodal)
- Take photo or pick image, crop, send to Gemini, show solution step-by-step.
- Save the question + answer to a "Doubts" list. Option to turn into flashcards.

### 4.5 Notes
- Create/edit/delete notes (rich-ish text or markdown), tags, subject, pin, search.
- Import: paste text, pick PDF/text file (extract text on device), image OCR via Gemini.
- AI actions on a note: Summarize, Key points, Simplify, Translate (EN/GU/HI), Generate Flashcards, Generate Quiz.
- Autosave, offline editing.

### 4.6 Flashcards + Spaced Repetition
- Decks and cards; AI generates a deck from a note/topic (user can edit before saving).
- Study mode with swipe/flip animation; rating buttons (Again / Hard / Good / Easy) using the **SM-2** algorithm.
- "Due today" queue, deck stats (mastered / learning / new).

### 4.7 Quiz Generator
- Generate MCQ quiz from a topic or a note: choose count (5/10/15), difficulty, subject.
- Ask Gemini for **strict JSON** output; validate/parse safely; retry once if invalid.
- Timer optional, instant feedback, explanation per question, final score screen with confetti.
- Attempt history; "Retry wrong questions only".

### 4.8 AI Study Planner
- User enters exam date, subjects, hours/day, weak topics → Gemini returns a day-by-day plan (strict JSON).
- Checklist UI, mark tasks done, reschedule missed tasks, local reminder notifications.

### 4.9 Focus Timer (Pomodoro)
- 25/5 default, customizable, animated circular timer, ambient dark focus screen.
- Log focus minutes to daily stats; works with screen off (foreground notification or local notification at end).

### 4.10 Progress & Gamification
- XP for: chat, notes, quiz, flashcards, focus minutes. Levels, daily streak (with freeze logic optional), badges (e.g. First Quiz, 7-Day Streak, 100 Cards).
- Charts (fl_chart): weekly study minutes, quiz score trend, subject-wise strength.
- Weekly summary card.

### 4.11 Settings
- Theme (System / Light / Dark), app language (English / ગુજરાતી / हिंदी), notifications, daily goal, AI response language & style.
- Account: edit profile, link account, sign out, **delete account & data**.
- About, privacy policy, rate app, feedback, share app.

### 4.12 Quality features
- Skeleton loaders (shimmer), empty states with illustrations, error states with retry, pull-to-refresh.
- Haptic feedback on key actions, smooth hero/page transitions.
- Remote Config for AI model name and feature flags so models can be changed without an app update.
- Crashlytics + Analytics events for main actions.
- Localization with `flutter_localizations` + ARB files (en, gu, hi).

---

## 5. Premium UI / UX Spec

**Feel:** modern, calm, high-end. Think Duolingo polish + Notion cleanliness + a touch of glassmorphism. **Dark mode first**, light mode equally polished.

### Design tokens (put in `lib/core/theme/`)
- **Colors (dark):** background `#0B0D17`, surface `#141828`, surface-elevated `#1C2138`, border `#2A3050`.
  Primary gradient `#6C5CE7 → #8E7BFF`, accent `#00D4C8` (teal), success `#2ED573`, warning `#FFB020`, error `#FF5C7A`.
  Text: primary `#F4F6FF`, secondary `#A3A9C7`.
- **Colors (light):** background `#F6F7FB`, surface `#FFFFFF`, same primary/accent, text `#14172B`.
- **Typography:** headings `Plus Jakarta Sans` (or `Outfit`), body `Inter`. Gujarati/Hindi fallback `Noto Sans Gujarati` / `Noto Sans Devanagari`. Define a full TextTheme.
- **Spacing:** 4/8/12/16/24/32. **Radius:** cards 20, buttons 16, chips 999, bottom sheets 28.
- **Elevation:** soft shadows in light mode, subtle borders + glow in dark mode.
- Material 3 `ColorScheme.fromSeed` as base, then override with tokens. Build one `AppTheme` with light + dark.

### Components (build reusable widgets in `lib/shared/widgets/`)
`GradientButton`, `GlassCard`, `AppTextField`, `AppChip`, `SectionHeader`, `StatTile`, `ProgressRing`, `StreakBadge`, `ShimmerBox`, `EmptyState`, `ErrorState`, `AppBottomSheet`, `AiMessageBubble`, `TypingIndicator`.

### Interaction rules
- Custom floating bottom navigation bar (5 tabs: Home, Study, AI Chat (center highlight), Planner, Profile) with animated icons.
- Use `flutter_animate` for entrance animations (fade + slide, 250–400 ms, staggered lists). No janky or over-the-top animation.
- Every screen: loading state, empty state, error state. Respect safe areas, support text scaling and small phones.
- Touch targets ≥ 48dp. Contrast WCAG AA. Add semantic labels.
- App icon + adaptive icon + splash matching the brand gradient.

---

## 6. Architecture

Feature-first, layered, simple. Do not over-engineer.

```
lib/
  main.dart
  app.dart                      # MaterialApp.router, theme, localization
  firebase_options.dart         # generated by flutterfire
  core/
    theme/                      # colors, typography, app_theme.dart
    router/                     # go_router config + auth guard
    constants/
    utils/                      # extensions, validators, debouncer, sm2.dart
    services/                   # notification_service, haptics, remote_config_service
    errors/                     # failures, error mapper (friendly messages)
  shared/
    widgets/                    # reusable UI components
    models/
  features/
    auth/        (data / domain / presentation)
    onboarding/
    home/
    chat/        # ai tutor
    scanner/     # doubt scanner
    notes/
    flashcards/
    quiz/
    planner/
    focus/
    progress/    # xp, streak, badges, charts
    settings/
  l10n/                         # app_en.arb, app_gu.arb, app_hi.arb
test/
```

Rules:
- UI widgets never talk to Firebase directly. Use repositories behind Riverpod providers.
- One `AiService` (in `core/services` or `features/ai`) wraps `firebase_ai`: handles model selection from Remote Config, system prompts, streaming, retry/backoff, JSON-mode parsing, error mapping. All features call this service.
- Keep prompts in one file (`ai_prompts.dart`) so they are easy to tune.
- Files < ~300 lines. Meaningful names. Small widgets.

---

## 7. Firestore Data Model

All user data lives under `users/{uid}`.

```
users/{uid}                       profile: name, photoUrl?, grade, language, dailyGoalMin, xp, level,
                                  streak, lastStudyDate, createdAt, settings{}
users/{uid}/chats/{chatId}        title, subject, mode, updatedAt
users/{uid}/chats/{chatId}/messages/{msgId}   role(user|model), text, createdAt
users/{uid}/doubts/{id}           question, answer, subject, createdAt
users/{uid}/notes/{noteId}        title, body, subject, tags[], pinned, createdAt, updatedAt
users/{uid}/decks/{deckId}        title, subject, cardCount, createdAt
users/{uid}/decks/{deckId}/cards/{cardId}     front, back, ease, interval, repetitions, dueAt
users/{uid}/quizzes/{quizId}      title, subject, difficulty, questions[], createdAt
users/{uid}/quizAttempts/{id}     quizId, score, total, answers[], durationSec, createdAt
users/{uid}/plans/{planId}        examDate, subjects[], days[ {date, tasks[ {title, done} ]} ]
users/{uid}/dailyStats/{yyyy-MM-dd}   studyMinutes, xpEarned, cardsReviewed, quizzesTaken
users/{uid}/badges/{badgeId}      unlockedAt
```

Keep documents small, avoid unbounded arrays, paginate lists, and design queries to minimise reads (free tier: ~50k reads / 20k writes per day).

### Firestore security rules (`firestore.rules`)
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
      match /{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == uid;
      }
    }
  }
}
```
Add basic field validation (string length limits) once features are stable.

---

## 8. AI Prompting Rules (Gemini)

- Use a **system instruction** for the tutor persona. Keep it short and clear.
- For quiz / planner / flashcards: request **JSON only** (use the SDK's JSON response mode with a response schema if available). Always parse defensively, validate fields, retry once on failure.
- Send only the needed context (last ~10 messages, trimmed note text) to save tokens and quota.
- Set sensible `maxOutputTokens` and `temperature` (0.3–0.5 for factual/JSON, 0.7 for chat).
- Safety: keep default safety settings; show a friendly message if a response is blocked.
- Cache repeated results locally (e.g. a generated quiz is saved, never regenerated needlessly).
- Show a clear "AI is thinking…" state and allow cancel.

---

## 9. Build Phases (do in order, verify each)

**Phase 0 — Setup**
- [ ] Check Flutter/Dart versions (`flutter doctor`). Create the project in this folder (`flutter create` with org name I give you, Android only is fine).
- [ ] Add dependencies (check latest versions), set up lints, folder structure.
- [ ] Firebase: guide me through the manual steps (create project, add Android app, add SHA-1 + SHA-256 for Google Sign-In, enable Auth providers, create Firestore, enable **Firebase AI Logic → Gemini Developer API**, enable App Check). Then run `flutterfire configure`.
- [ ] Commit: "chore: project setup".

**Phase 1 — Design system & shell**
- [ ] Theme (light/dark), tokens, fonts, reusable widgets, go_router, bottom nav shell, placeholder screens, a `/design-preview` debug screen showing all components.

**Phase 2 — Auth & onboarding**
- [ ] Splash, onboarding, sign in/up, Google, guest, link account, profile setup, auth redirect guard, user doc creation.

**Phase 3 — AiService + Chat**
- [ ] `AiService` with streaming/retry/error mapping, chat UI, modes, subjects, history, markdown rendering, quota counter.

**Phase 4 — Notes + Doubt Scanner**
- [ ] Notes CRUD/search/tags, import (text/PDF), AI note actions, camera/gallery doubt solver.

**Phase 5 — Flashcards + Quiz**
- [ ] SM-2 logic (with unit tests), deck/card CRUD, AI generation, study mode, quiz generation/take/results/history.

**Phase 6 — Planner + Focus timer**
- [ ] AI study plan, task checklist, local notifications, Pomodoro with stats logging.

**Phase 7 — Progress & gamification**
- [ ] XP/level/streak engine, badges, charts, weekly summary, dashboard wiring.

**Phase 8 — Settings, localization, polish**
- [ ] Settings screens, delete account, en/gu/hi localization, Remote Config, Crashlytics/Analytics, animations pass, empty/error states everywhere, accessibility pass.

**Phase 9 — Release prep**
- [ ] App icon, splash, app name, package id, release keystore (guide me; never commit it), ProGuard/R8 check, `flutter build appbundle --release`, Play Store listing checklist, privacy policy text.

---

## 10. Working Rules for Claude Code

1. **Start each session** by reading this file and checking which phase is done (keep a `PROGRESS.md` with checkboxes; update it after each phase).
2. **Before coding a phase**, give a 5–10 line plan and wait for my "ok" only if the phase has a risky/major decision; otherwise proceed.
3. **Manual steps** (Firebase console clicks, SHA keys, keystore, Play Console) — give me a numbered checklist with exact menu names. Do not pretend you did them.
4. After every meaningful change run: `dart format .`, `flutter analyze` (must be clean) and relevant `flutter test`. Fix issues before moving on.
5. Run the app (`flutter run`) when possible and report errors honestly. If you cannot run it, say so and tell me exactly what to run.
6. Make **small, focused git commits** with clear messages (conventional commits). Never commit `google-services.json` secrets issues: it is OK for it to be in the repo only if I say so; otherwise add it to `.gitignore`. Never commit keystores, `key.properties`, or `.env`.
7. Don't add packages without a reason; prefer fewer, well-maintained dependencies. Tell me when you add one.
8. No placeholder "Lorem ipsum" or fake data in finished screens (seed/demo data only behind a debug flag).
9. If something in this file conflicts with what the latest docs say, follow the docs, tell me, and suggest an update to this file.
10. Reply to me in simple language (I may write in Gujarati/Hinglish; answer in the same style, keep code and comments in English).
11. Keep code production-quality: null safety, no unused code, no `print` (use a logger), handle all async errors, dispose controllers/streams.

---

## 11. Definition of Done (whole app)

- [ ] All features in section 4 work end-to-end on a real Android device.
- [ ] Works on Firebase Spark plan with no billing account attached.
- [ ] No hardcoded API keys; App Check enabled; Firestore rules deployed.
- [ ] `flutter analyze` clean, core logic tested (SM-2, JSON parsing, XP/streak).
- [ ] UI matches section 5 in both dark and light mode, 3 languages show correctly (Gujarati/Hindi fonts render).
- [ ] Graceful handling of: no internet, Gemini quota exceeded, blocked responses, expired auth.
- [ ] Release App Bundle builds successfully.
