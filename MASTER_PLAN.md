# MASTER_PLAN.md — Finish ALL remaining code (Firebase setup comes last, by me)

Read CLAUDE.md, PROGRESS.md and this file fully. **Do not modify CLAUDE.md.**
Work autonomously from the first unfinished step to the end. Do NOT ask me whether to continue and do NOT stop between steps.
Firebase is NOT configured yet: write real code against the real APIs, guard every Firebase call so the app never crashes when Firebase is missing, and never fake or simulate data or AI responses.

---

## HOW THIS RUN WORKS (rules that matter most)

1. **A step is DONE only when its GATE passes.** Every step has a GATE: commands whose raw output must meet a stated condition. Run the commands, paste the raw output into `REPORT.md`, and only then mark the step done. If a gate fails, fix the code and rerun the gate. Never mark a step done on the basis of ARB files, intentions or summaries.
2. **No excuses for leftovers.** Do not label anything "pre-existing" or "unrelated" and skip it. If `git status` shows changes, run `git diff --stat`, explain them in REPORT.md, and commit them in a separate commit (or revert them if they are wrong).
3. **Never write a summary instead of raw output.** `REPORT.md` (project root) is how I verify the work. Append to it after every step: the step name, the gate commands, and their raw output.
4. **After every step:** `dart format .`, `flutter analyze` (0 errors), `flutter test` (total must never go down, and must go up when you add logic), update `PROGRESS.md` honestly (keep a "Blocked", a "Deferred" and a "Needs testing after Firebase config" list), then `git commit`. Never commit with analyzer errors.
5. If something is truly blocked, write it under "Blocked" in PROGRESS.md and continue with the next step. Do not stop.
6. Screens live in their own files. `app_router.dart` contains only routes and the shell. Pure logic goes in plain Dart with unit tests.
7. If your context gets large, commit and update PROGRESS.md and REPORT.md first, so I can `/clear` and resume.
8. Be careful with Windows commands (this is Windows): use `findstr`, not `grep`, in anything you tell me to run. Inside your own shell you may use whatever works.

---

## STEP 0 — Clean state

- `git status` and `git diff --stat`. Explain every uncommitted change (especially lib/features/progress) in REPORT.md and commit it separately if correct.
- Baseline into REPORT.md: `flutter test` total, `flutter analyze` summary, and this baseline of hardcoded strings per file:
  `findstr /S /N /C:"Text('" /C:"Text(\"" /C:"labelText: '" /C:"hintText: '" /C:"SnackBar(content: Text('" lib\features\*.dart lib\shared\*.dart`
  (exclude design_preview_screen.dart from all counts).

**GATE 0:** git status is clean; baseline is in REPORT.md.

---

## STEP 1 — Finish Phase 8B localization (UI must really use l10n, not just ARB files)

Localize every user-visible string in the screens, with `context.l10n`. ARB entries alone do NOT count. Do it in these batches and commit after each:

- 1a: splash, onboarding, auth (sign-in, email dialog, forgot password, link account), profile setup, edit profile, study hub, not-found, bottom navigation labels
- 1b: chat (list, detail, mode and subject chips, message actions), notes (list, editor, detail, AI action dialogs, result and error messages), scanner
- 1c: flashcards (decks, card editor, study mode, stats), quiz (create, take, result, history)
- 1d: planner, focus, progress, home (all empty and error states), settings leftovers, notification texts, error-mapper messages, shared widgets

Rules: do not translate AI answers or user content. Natural Gujarati and Hindi, the way a student speaks; keep Quiz, Flashcards, Streak, XP in English. Before saving a translation, check every word is real and common (earlier output contained nonsense words like "માત્રાપર્યાપ્ત"). Use ICU plurals for numbers. Keep the ARB keys test passing (same keys in en, gu, hi, no empty values). The language setting must change the whole UI immediately, and Noto Sans Gujarati and Devanagari fallbacks must render.

**GATE 1 (run after 1d and paste the raw output):**
```
findstr /S /N /C:"Text('" /C:"Text(\"" /C:"labelText: '" /C:"hintText: '" /C:"SnackBar(content: Text('" lib\features\*.dart lib\shared\*.dart
```
Pass condition: at most 3 remaining matches in total, each one justified in REPORT.md (for example a brand name or an AI/user content string). Also list per feature folder how many `context.l10n` usages exist. Also list any Gujarati/Hindi translations you are unsure about so I can review them.

---

## STEP 2 — Phase 8C

- **Remote Config** for AI model names and feature flags, with safe defaults in code; the app works if Remote Config is unreachable. Verify the model names in AppConstants against the CURRENT Firebase AI Logic docs and record the doc page you used in REPORT.md.
- **Crashlytics and Analytics** with events for main actions, all guarded.
- **App Check** code (Play Integrity in release, debug provider in debug), guarded the same way.
- **Quiz XP daily cap** (max 5 awards per day), with a unit test.
- **PDF import:** retry with the latest compatible package and a license check; if it still fails on Android 36, leave it under "Deferred" with the exact error.
- **Quiz optional timer** (off by default), if it does not exist yet.
- **Polish pass on every list screen:** shimmer loading, empty state, error state with Retry, pull-to-refresh, haptics on key actions, smooth transitions, semantic labels, 48dp touch targets.
- Remove every "coming soon", stub, placeholder, demo, fake and mock from lib/, except the firebase_options.dart stub, which stays until `flutterfire configure`.

**GATE 2:** raw output of
```
findstr /S /I /C:"coming soon" /C:"stub" /C:"placeholder" /C:"demo" /C:"fake" /C:"mock" /C:"simulat" lib\*.dart
```
(only justified matches may remain, explained in REPORT.md), plus flutter analyze (0 errors) and flutter test total.

---

## STEP 3 — Phase 9, code-side release preparation

- App name "StudyMate AI"; keep the existing applicationId.
- Adaptive app icon and splash matching the brand gradient (#6C5CE7 to #8E7BFF): generate the icon source image with a script, then use flutter_launcher_icons and flutter_native_splash.
- Release signing: read `android/key.properties` if it exists and fall back to debug signing otherwise. Add `key.properties`, `*.jks` and `*.keystore` to .gitignore. Do NOT create a keystore and do NOT commit secrets. Put the exact `keytool` command and the key.properties template in REPORT.md for me.
- R8/ProGuard check, and a note that Google Play needs a declaration for SCHEDULE_EXACT_ALARM.
- `flutter build apk --release` and `flutter build appbundle --release`; a debug-signed build is fine if no keystore exists.
- Write `docs/privacy_policy.md` and `docs/play_store_listing.md` (short and full description, feature list, screenshot checklist, data safety answers). The privacy policy must match what the app really stores.

**GATE 3:** raw output of both release builds, the list of created files, and `git status`.

---

## STEP 4 — Final verification

- Review the whole app against CLAUDE.md sections 4 and 5. In REPORT.md, make a table with DONE, DEFERRED or MISSING for every feature, and the file that implements it. Be honest: anything untested or not working is not DONE.
- Final raw output at the end of REPORT.md: `dart format .`, `flutter analyze`, `flutter test` (total and per file), `flutter build apk --debug`, `git status`, `git log -20 --oneline`.
- Write "Manual steps for me" in REPORT.md: `flutterfire configure`, SHA-1 and SHA-256 keys, Auth providers, Firestore rules, Firebase AI Logic, App Check, keystore creation, and a phone test checklist (guest login, chat with real Gemini, note, doubt scanner, flashcards, quiz, planner reminder, focus timer, language switch, delete account).

**GATE 4:** REPORT.md contains the table, the raw final output and the manual steps. Then stop.

---

## RESUME (if the session was cleared)

Read CLAUDE.md, PROGRESS.md, REPORT.md and MASTER_PLAN.md. Continue from the first step whose GATE has not passed in REPORT.md. Same rules.
