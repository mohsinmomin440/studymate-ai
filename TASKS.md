# StudyMate AI - Build Tasks

## Step 0 — Clean State
- [x] git status clean, commit changes, explain and commit leftovers

## Step 2 — Phase 8C (Remote Config, Crashlytics, Analytics, App Check, polish)
- [x] Remote Config for AI model names and feature flags with safe defaults
- [x] Crashlytics integration with events for main actions
- [x] Analytics with events for main actions
- [x] App Check code (Play Integrity release, debug provider)
- [x] Quiz XP daily cap (max 5 awards per day) with unit test
- [ ] Quiz optional timer (off by default), if it does not exist yet.
- [ ] PDF import retry with latest compatible package
- [ ] Polish pass on every list screen
- [x] Remove every "coming soon", stub, placeholder, demo, fake and mock from lib/

## Step 3 — Release Prep
- [ ] App icon "StudyMate AI" confirmed
- [ ] Adaptive app icon and splash (generate icon source image with script)
- [ ] Release signing config (read android/key.properties if exists, else debug)
- [ ] R8/ProGuard check with SCHEDULE_EXACT_ALARM declaration
- [ ] flutter build apk --release
- [ ] flutter build appbundle --release
- [ ] Write docs/privacy_policy.md
- [ ] Write docs/play_store_listing.md

## Step 1 — Phase 8B Localization (one item per file)
- [ ] lib/features/auth/presentation/splash_screen.dart (if exists)
- [ ] lib/features/auth/presentation/onboarding_screen.dart (if exists)
- [ ] lib/features/auth/presentation/auth_screen.dart / login_screen.dart
- [ ] lib/features/auth/presentation/profile_setup_screen.dart
- [ ] lib/features/auth/presentation/profile_edit_screen.dart (if exists)
- [ ] lib/features/home/presentation/home_screen.dart
- [ ] lib/features/home/presentation/design_preview_screen.dart (EXCLUDED)
- [ ] lib/features/chat/presentation/chat_list_screen.dart
- [ ] lib/features/chat/presentation/chat_detail_screen.dart
- [ ] lib/features/scanner/presentation/scanner_screen.dart
- [ ] lib/features/notes/presentation/notes_screen.dart
- [ ] lib/features/flashcards/presentation/flashcards_screen.dart
- [ ] lib/features/quiz/presentation/quiz_screen.dart
- [ ] lib/features/planner/presentation/planner_screen.dart
- [ ] lib/features/focus/presentation/focus_screen.dart
- [ ] lib/features/progress/presentation/home_screen.dart
- [ ] lib/features/progress/presentation/progress_screen.dart
- [ ] [] lib/features/settings/presentation/settings_screen.dart
- [ ] lib/features/auth/presentation/login_dialog.dart (if exists)
- [ ] lib/features/auth/presentation/forgot_password_dialog.dart (if exists)

## Step 4 — Final Verification
- [ ] Gate 1: Run findstr command and verify no hardcoded strings remain
- [ ] Gate 2: Run flutter analyze (0 errors), flutter test, verify no stubs
- [ ] Gate 3: Run release builds, verify app builds successfully
- [ ] Gate 4: Final verification table with DONE/DEFERRED/MISSING