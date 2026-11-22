# StudyMate AI - Build Progress

## Phase 0 — Setup ✅ COMPLETE
- [x] Check Flutter/Dart versions
- [x] Add dependencies (check latest versions), set up lints
- [x] Create folder structure
- [x] Firebase: stub file created (run `flutterfire configure` for real config)
- [x] All analyzer issues resolved
- [x] Web platform configured
- [x] Android core library desugaring enabled
- [x] Commit: "chore: project setup"

## Phase 1 — Design system & shell ✅ COMPLETE
- [x] Theme (light/dark), tokens, fonts
- [x] Reusable widgets (Gap, GlassCard, AppTextField, AppChip, SectionHeader)
- [x] StatTile, ProgressRing, ShimmerBox, EmptyState, ErrorState
- [x] StreakBadge, AppBottomSheet, AiMessageBubble, GradientButton
- [x] TypingIndicator (exists in ai_message_bubble.dart)
- [x] go_router setup with auth guard
- [x] Bottom nav shell with placeholder screens
- [x] Design preview screen (DesignPreviewScreen)
- [x] HomeScreen implemented (placeholder)
- [x] ProfileSetupScreen implemented

## Phase 2 — Auth & onboarding ✅ COMPLETE
- [x] Splash screen (animated with logo transition)
- [x] 3-screen onboarding (animated page view)
- [x] Auth screen UI (Google, Email, Guest sign-in)
- [x] "Get Started" and "Skip" buttons with navigation
- [x] Forgot password flow
- [x] Profile setup screen
- [x] Guest account linking (Google + Email)
- [x] Firestore user doc creation (in auth_service.dart)
- [x] Email sign-in dialog with sign up toggle
- [x] AuthRepository with proper Firestore integration

## Phase 3 — AiService + Chat ✅ COMPLETE
- [x] AiService with Firebase AI Logic integration
- [x] Streaming responses with retry/backoff
- [x] Error mapping (AIFailure, ServerFailure, etc.)
- [x] Chat UI (ChatListScreen, ChatDetailScreen)
- [x] Modes (Explain Simply, Step-by-Step, Exam Answer, Quick Summary, Teach Me Like I'm 10)
- [x] Subjects dropdown
- [x] Chat history with Firestore streaming
- [x] Markdown rendering (via ai_message_bubble.dart)

## Phase 4 — Notes + Doubt Scanner ✅ COMPLETE
- [x] Notes CRUD/search/tags
- [x] Import (text) - PDF import deferred to Phase 5
- [x] AI note actions wired to AiService (Summarize, Key points, Translate, Generate Flashcards/Quiz)
- [x] Camera/gallery doubt solver with AI integration
- [x] Build succeeds (compileSdk 36)
- [x] QR code scanning infrastructure in place

### Firebase testing needed:
- Notes saving/retrieval in Firestore (offline persistence enabled)
- Scanner results saving to Firestore
- AiService Firebase AI Logic integration
- Daily AI usage counter

## Phase 5 — Flashcards + Quiz
- [ ] SM-2 logic
- [ ] Deck/card CRUD
- [ ] AI generation
- [ ] Study mode
- [ ] Quiz generation/take/results

## Phase 6 — Planner + Focus timer
- [ ] AI study plan
- [ ] Task checklist
- [ ] Local notifications
- [ ] Pomodoro

## Phase 7 — Progress & gamification
- [ ] XP/level/streak engine
- [ ] Badges
- [ ] Charts
- [ ] Dashboard

## Phase 8 — Settings, localization, polish
- [ ] Settings screens
- [ ] Delete account
- [ ] en/gu/hi localization
- [ ] Remote Config
- [ ] Animations

## Phase 9 — Release prep
- [ ] App icon
- [ ] Package id
- [ ] Release keystore
- [ ] Build app bundle

---

### Manual Steps Needed After Firebase Config:
1. Run `flutterfire configure` to generate real `firebase_options.dart`
2. Enable Auth providers (Google, Email/Password)
3. Enable Cloud Firestore
4. Enable Firebase AI Logic (Gemini Developer API)
5. Enable App Check (Play Integrity)
6. Add SHA-1 + SHA-256 hashes for Google Sign-In
7. Add Flutter assets fonts for Gujarati/Hindi (Noto Sans)
8. Test `flutter build apk --debug` for Android