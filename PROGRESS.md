# StudyMate AI - Build Progress

## Phase 0 — Setup ✅ COMPLETE
- [x] Check Flutter/Dart versions
- [x] Add dependencies (check latest versions), set up lints
- [x] Create folder structure
- [x] Firebase: stub file created (run `flutterfire configure` for real config)
- [x] All analyzer issues resolved
- [x] Web platform configured
- [x] Commit: "chore: project setup"

**Notes Testing:**
- Need to run `flutterfire configure` after setting up Firebase project
- Android build has Kotlin desugaring issue with `flutter_local_notifications`

## Phase 1 — Design system & shell ✅ MOSTLY COMPLETE
- [x] Theme (light/dark), tokens, fonts
- [x] Reusable widgets (Gap, GlassCard, AppTextField, AppChip, SectionHeader, etc.)
- [x] go_router setup with auth guard
- [x] Bottom nav shell with placeholder screens
- [ ] Design preview screen (needs implementation)
- [ ] HomeScreen needs implementation
- [ ] ProfileSetupScreen needs implementation

## Phase 2 — Auth & onboarding ✅ IN PROGRESS
- [ ] Splash screen (basic FirebaseSetupScreen already implemented)
- [ ] Onboarding screens (placeholder exists)
- [X] Sign in/up with Google, email, guest (AuthScreen UI implemented)
- [ ] Auth redirect guard (implemented but needs screens)
- [ ] User doc creation
- [ ] Profile setup screen (placeholder exists)

## Phase 3 — AiService + Chat
- [ ] AiService with streaming/retry/error mapping
- [ ] Chat UI
- [ ] Modes, subjects
- [ ] Chat history
- [ ] Markdown rendering

## Phase 4 — Notes + Doubt Scanner
- [ ] Notes CRUD/search/tags
- [ ] Import (text/PDF)
- [ ] AI note actions
- [ ] Camera/gallery doubt solver

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
8. Fix Android build configuration for `flutter_local_notifications`