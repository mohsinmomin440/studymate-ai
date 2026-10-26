# StudyMate AI — BCA Final-Year Project

> **Project type:** BCA final-year Android application  
> **Difficulty:** Medium–Hard / Advanced  
> **Frontend:** Flutter + Dart  
> **Backend:** Firebase  
> **Working title:** StudyMate AI  
> **Purpose:** An intelligent study planner that helps students organize study tasks, prepare for exams, generate study schedules, practice with quizzes, and track learning progress.

---

## 1. Project Overview

StudyMate AI is a Flutter-based Android application for student productivity and exam preparation. It combines a reliable rule-based study scheduler with optional AI-powered learning features.

### Core objectives

- Let students manage subjects, topics, tasks, and exam dates.
- Generate a realistic daily or weekly study schedule from deadlines, priorities, difficulty, and available time.
- Track planned versus actual study time and task completion.
- Generate summaries, flashcards, and practice quizzes from user-provided study material through a securely configured AI service.
- Display progress analytics and send study reminders.
- Keep each student's private data isolated using Firebase Authentication and Firestore Security Rules.

### Target users

College and university students who want to plan their study time and prepare for examinations.

### Platforms

- Primary: Android
- Framework: Flutter
- Language: Dart

---

## 2. Scope and Features

### MVP — required for the first complete version

1. Email/password signup and login
2. Password reset and logout
3. User profile and study preferences
4. Subject CRUD (create, read, update, delete)
5. Study task CRUD and completion status
6. Exam dates, priorities, estimated durations, and difficulty
7. Rule-based daily/weekly study-plan generation
8. Study-session timer or manual time logging
9. Dashboard with today's plan and upcoming deadlines
10. Progress charts and weekly summaries
11. Firestore persistence and user-specific security rules
12. Loading, empty, success, and error states

### Advanced features — implement after the MVP is stable

- AI-generated summaries from study material
- AI-generated multiple-choice quizzes and flashcards
- PDF/text material import
- Rescheduling of incomplete tasks
- Local study reminders and push notifications
- Quiz history and subject-wise performance
- Offline-friendly handling where supported by Firestore
- Accessibility and dark mode

### Out of scope for the initial release

- Social networking or public student profiles
- Paid subscriptions
- Guaranteed AI correctness
- A complex university administration portal
- Automatic reading of every possible file format

---

## 3. Technology Stack

| Area | Technology | Responsibility |
|---|---|---|
| Mobile UI | Flutter, Dart | Android app and responsive screens |
| App architecture | Feature-first Clean Architecture / MVVM | Separation of UI, business logic, and data |
| State management | Riverpod (`flutter_riverpod`) | State and dependency management |
| Navigation | GoRouter (`go_router`) | Named routes and auth redirects |
| Authentication | Firebase Authentication | User identity and sessions |
| Database | Cloud Firestore | Users, subjects, tasks, plans, sessions, quizzes |
| File storage | Firebase Storage | Optional study-material files |
| Notifications | `flutter_local_notifications`, Firebase Cloud Messaging | Reminders and push notifications |
| Charts | `fl_chart` | Study and quiz analytics |
| Dates | `intl` | Date/time formatting |
| IDs | `uuid` | IDs when client-generated IDs are appropriate |
| Testing | `flutter_test`, Firebase Emulator Suite | Unit, widget, and rules tests |
| Optional AI | Firebase AI Logic or a trusted server-side API | Summaries, quizzes, and study assistance |

**Security rule:** Never embed a private third-party AI API key in the Flutter application. Use a managed service with suitable security controls or a trusted server-side endpoint. Validate AI output before storing or displaying it.

---

## 4. Architecture

Use a **feature-first architecture**. Each feature should separate presentation, domain logic, and data access where useful.

### Layers

- **Presentation:** screens, reusable widgets, view models/notifiers, UI state.
- **Domain:** entities/models, scheduling rules, validation, and use cases.
- **Data:** repository contracts/implementations, DTO mapping, Firestore data sources.
- **Core:** shared errors, constants, helpers, theme, and common widgets.
- **Services:** Firebase initialization, notifications, and AI integration.

### Data flow

1. A screen collects user input.
2. A Riverpod view model validates input and calls a use case or repository.
3. Domain logic performs calculations independently of Flutter widgets.
4. A repository reads/writes Firestore or invokes a service.
5. Riverpod exposes loading, data, and error states to the UI.

The rule-based scheduler must remain usable when the AI service is unavailable.

---

## 5. Suggested Folder Structure

```text
lib/
├── main.dart
├── firebase_options.dart
├── app/
│   ├── app.dart
│   ├── router.dart
│   └── theme.dart
├── core/
│   ├── constants/
│   ├── errors/
│   ├── utils/
│   └── widgets/
├── services/
│   ├── notification_service.dart
│   └── ai_service.dart
└── features/
    ├── auth/
    │   ├── data/
    │   │   └── auth_repository_impl.dart
    │   ├── domain/
    │   │   └── app_user.dart
    │   └── presentation/
    │       ├── login_screen.dart
    │       ├── signup_screen.dart
    │       ├── reset_password_screen.dart
    │       └── auth_view_model.dart
    ├── dashboard/
    │   └── presentation/
    ├── subjects/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    ├── tasks/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    ├── planner/
    │   ├── data/
    │   ├── domain/
    │   │   ├── study_plan.dart
    │   │   └── generate_plan.dart
    │   └── presentation/
    ├── study_sessions/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    ├── study_materials/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    ├── ai_tutor/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    ├── quizzes/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    └── analytics/
        └── presentation/

test/
├── unit/
├── widget/
└── integration/
```

Keep the structure proportional to the implementation. Avoid empty folders and unnecessary abstractions; add files as each feature is built.

---

## 6. Firestore Database Schema

Use user-scoped subcollections to make ownership checks straightforward.

```text
users/{uid}
users/{uid}/subjects/{subjectId}
users/{uid}/tasks/{taskId}
users/{uid}/study_plans/{planId}
users/{uid}/study_sessions/{sessionId}
users/{uid}/quiz_sets/{quizId}
users/{uid}/quiz_attempts/{attemptId}
users/{uid}/study_materials/{materialId}
```

### `users/{uid}`

```json
{
  "displayName": "Student Name",
  "email": "student@example.com",
  "timezone": "Asia/Kolkata",
  "dailyStudyMinutes": 180,
  "createdAt": "Firestore Timestamp",
  "updatedAt": "Firestore Timestamp"
}
```

### `subjects/{subjectId}`

```json
{
  "name": "Data Structures",
  "description": "Core data structures and algorithms",
  "difficulty": 4,
  "targetMinutes": 1200,
  "examAt": "Firestore Timestamp or null",
  "colorHex": "#6750A4",
  "createdAt": "Firestore Timestamp",
  "updatedAt": "Firestore Timestamp"
}
```

### `tasks/{taskId}`

```json
{
  "title": "Revise linked lists",
  "description": "Review operations and complexity",
  "subjectId": "subject_id",
  "priority": "high",
  "difficulty": 4,
  "estimatedMinutes": 60,
  "dueAt": "Firestore Timestamp or null",
  "status": "pending",
  "createdAt": "Firestore Timestamp",
  "updatedAt": "Firestore Timestamp"
}
```

Allowed task statuses should be defined centrally, for example: `pending`, `inProgress`, `completed`, and `cancelled`.

### `study_plans/{planId}`

```json
{
  "startDate": "Firestore Timestamp",
  "endDate": "Firestore Timestamp",
  "generationMethod": "ruleBased",
  "status": "active",
  "sessionIds": ["session_id_1", "session_id_2"],
  "createdAt": "Firestore Timestamp"
}
```

For larger plans, store sessions in the `study_sessions` subcollection rather than duplicating full session objects in one plan document.

### `study_sessions/{sessionId}`

```json
{
  "planId": "plan_id",
  "taskId": "task_id",
  "subjectId": "subject_id",
  "scheduledStartAt": "Firestore Timestamp",
  "scheduledEndAt": "Firestore Timestamp",
  "actualMinutes": 0,
  "status": "scheduled",
  "completedAt": null,
  "createdAt": "Firestore Timestamp"
}
```

### `quiz_sets/{quizId}`

```json
{
  "title": "Data Structures Practice",
  "subjectId": "subject_id",
  "sourceType": "userNotes",
  "questionCount": 10,
  "createdAt": "Firestore Timestamp"
}
```

Consider storing questions in a nested `questions` subcollection if quiz sets may be large. Keep answer keys separate from any data exposed to untrusted clients when required by the quiz design.

### `quiz_attempts/{attemptId}`

```json
{
  "quizId": "quiz_id",
  "score": 8,
  "totalQuestions": 10,
  "answers": [],
  "completedAt": "Firestore Timestamp"
}
```

### `study_materials/{materialId}`

```json
{
  "title": "Chapter 1 Notes",
  "storagePath": "users/uid/materials/file.pdf",
  "mimeType": "application/pdf",
  "subjectId": "subject_id",
  "processingStatus": "pending",
  "createdAt": "Firestore Timestamp"
}
```

Store Firestore dates as `Timestamp` values in the real application, not as literal strings. Store files in Firebase Storage and save their storage paths and metadata in Firestore.

---

## 7. Security Requirements

- Require Firebase Authentication for all private application data.
- Enforce that the authenticated UID matches the user path in Firestore rules.
- Apply equivalent owner checks in Firebase Storage rules.
- Validate fields, allowed values, and data types in security rules where feasible.
- Never use open production rules such as `allow read, write: if true`.
- Do not trust a client-supplied user ID, quiz score, or ownership field without validation.
- Keep private AI credentials on a server or use a managed AI integration designed for client applications.
- Set reasonable limits on AI input length, request frequency, and cost.
- Test Firestore and Storage rules with the Firebase Emulator Suite.
- Do not store passwords directly in Firestore; Firebase Authentication manages credentials.

A basic owner check can start with:

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null
                         && request.auth.uid == userId;

      match /{document=**} {
        allow read, write: if request.auth != null
                           && request.auth.uid == userId;
      }
    }
  }
}
```

This is only a starting point. Add field validation, restrict sensitive profile changes, and create separate policies for any server-managed data before production.

---

## 8. Study-Plan Generation Algorithm

Build a deterministic scheduler first; use AI to enhance the learning experience rather than relying on AI for basic scheduling.

### Inputs

- Student's available study time by day
- Subjects and exam dates
- Pending tasks and due dates
- Task priority and difficulty
- Estimated task duration
- Existing scheduled sessions

### Initial algorithm

1. Remove completed or cancelled tasks.
2. Calculate urgency based on due date or exam date.
3. Calculate a priority score from urgency, importance, and difficulty.
4. Sort tasks by priority, using a stable tie-breaker.
5. Allocate tasks into available study slots while respecting daily limits.
6. Split long tasks into manageable sessions where appropriate.
7. Avoid overlapping sessions and preserve breaks.
8. Mark tasks that cannot fit as unscheduled rather than silently dropping them.
9. Save the generated plan and sessions to Firestore.
10. Allow regeneration without duplicating sessions or overwriting completed work.

Example scoring formula for the first iteration:

```text
score =
    urgencyWeight * urgency
  + priorityWeight * priority
  + difficultyWeight * difficulty
```

Normalize inputs to a common scale and document the weights. Test the scheduler with edge cases such as no available time, past deadlines, overlapping constraints, and more work than available time.

---

## 9. AI Features

### AI summaries

- Accept pasted text or extracted text from supported study documents.
- Set input-size limits and handle unsupported content.
- Request a structured summary with headings and key terms.
- Show that generated content may contain mistakes.

### AI quiz generation

- Generate multiple-choice questions with options, correct answers, and explanations.
- Validate the response format before showing a quiz.
- Handle malformed output, timeouts, and service errors.
- Store quiz attempts and performance metrics.

### AI study assistant

- Answer questions using supplied study material when possible.
- Clearly distinguish source-based answers from general model knowledge.
- Avoid sending unnecessary personal information to an AI provider.

AI requests should pass through `AiService`, not be embedded directly in widgets. Choose and configure the AI provider after reviewing its current pricing, regional availability, data handling, and authentication requirements.

---

## 10. UI Screens

1. Splash / startup
2. Onboarding and study preferences
3. Login
4. Signup
5. Password reset
6. Home dashboard
7. Subject list and subject details
8. Create/edit task
9. Calendar and weekly planner
10. Generate-plan configuration
11. Study session / focus timer
12. Study materials
13. AI summary
14. Quiz setup and quiz session
15. Quiz results
16. Progress analytics
17. Profile and settings

Use a consistent design system: spacing tokens, typography, semantic colors, reusable buttons, cards, form fields, loading indicators, and error states. Prioritize accessibility, readable contrast, and Android screen-size support.

---

## 11. Development Setup

### Verify Flutter

```bash
flutter doctor
flutter --version
dart --version
```

Resolve missing Android SDK, emulator, and license requirements reported by `flutter doctor`.

### Create the project

```bash
flutter create --org com.studymate studymate_ai
cd studymate_ai
flutter run
```

### Install core dependencies

```bash
flutter pub add firebase_core
flutter pub add firebase_auth
flutter pub add cloud_firestore
flutter pub add firebase_storage
flutter pub add flutter_riverpod
flutter pub add go_router
flutter pub add fl_chart
flutter pub add intl
flutter pub add uuid
```

Add notification and AI packages only when implementing those modules.

### Configure Firebase

1. Create a project in Firebase Console.
2. Enable Email/Password authentication.
3. Create a Cloud Firestore database.
4. Install and authenticate the Firebase CLI.
5. Activate FlutterFire CLI.
6. Run `flutterfire configure` and select Android.
7. Initialize Firebase before `runApp`.
8. Deploy and test appropriate Firestore and Storage security rules.

Commands after installing the Firebase CLI:

```bash
firebase login
dart pub global activate flutterfire_cli
flutterfire configure
```

---

## 12. Recommended Implementation Phases

### Phase 1 — Foundation

- Create Flutter project and theme.
- Configure Firebase.
- Add Riverpod and GoRouter.
- Implement signup, login, logout, and password reset.
- Add auth-state handling and protected routes.

**Acceptance criteria:** A user can sign up, log in, remain signed in after restart, and log out. Unauthenticated users cannot access private screens.

### Phase 2 — Subjects and Tasks

- Implement subject and task models.
- Add repositories and Firestore CRUD.
- Add form validation and error handling.
- Filter all data to the current user.

**Acceptance criteria:** Subject and task changes persist after app restart and are isolated by user.

### Phase 3 — Scheduler

- Implement scheduling entities and a pure Dart algorithm.
- Add availability and preference forms.
- Generate daily and weekly schedules.
- Add rescheduling and collision handling.

**Acceptance criteria:** Scheduling logic passes unit tests and does not duplicate completed sessions.

### Phase 4 — Dashboard and Analytics

- Display today's tasks and upcoming exams.
- Track actual study time.
- Add charts and weekly summaries.

**Acceptance criteria:** Analytics are derived from stored data and display correct empty states.

### Phase 5 — AI Tutor and Quizzes

- Configure a secure AI integration.
- Add material input and summary generation.
- Generate and validate quizzes.
- Store attempts and results.

**Acceptance criteria:** The feature handles invalid responses, network failures, and usage limits gracefully.

### Phase 6 — Notifications and Polish

- Add local study reminders.
- Add push notifications if required.
- Improve loading, offline, and error states.
- Test navigation, accessibility, and small screens.

**Acceptance criteria:** Reminders respect user preferences and the app handles denied notification permissions.

### Phase 7 — Testing and Submission

- Unit tests for scheduling and scoring.
- Widget tests for forms and navigation.
- Integration tests for major user flows.
- Firebase rules tests.
- Release build and final demonstration.
- Prepare documentation, diagrams, screenshots, and viva notes.

---

## 13. Testing Strategy

### Unit tests

- Scheduler prioritization
- Available-time constraints
- Deadline handling
- Quiz score calculation
- Task status transitions
- Date/time-zone behavior

### Widget tests

- Login and signup validation
- Subject/task forms
- Dashboard empty and loading states
- Quiz answer selection and result display

### Integration tests

- Signup → create subject → create task → generate plan
- Complete a study session → verify analytics
- Generate quiz → submit answers → view results
- Sign out → verify protected screens are inaccessible

### Security tests

- User A cannot read or write User B's data.
- Unauthenticated access is denied.
- Invalid field values are rejected.
- Storage access is restricted to the file owner.

---

## 14. BCA Submission Deliverables

Prepare the following alongside the application:

- Project abstract and problem statement
- Objectives and scope
- Software and hardware requirements
- Feasibility study
- System architecture diagram
- Use-case diagram
- DFD or activity diagrams
- Firestore schema/data dictionary
- UI screenshots
- Testing plan and test results
- Limitations and future scope
- Conclusion and references
- Demo script and viva preparation notes

---

## 15. Definition of Done

The project is ready for demonstration when:

- [ ] Signup, login, logout, and password reset work.
- [ ] Subjects and tasks support CRUD operations.
- [ ] Study plans are generated and saved.
- [ ] Completed sessions update progress analytics.
- [ ] At least one AI feature works through a secure integration.
- [ ] Firestore and Storage access rules are tested.
- [ ] Important flows have automated tests.
- [ ] Loading, empty, and error states are implemented.
- [ ] Android release build succeeds.
- [ ] Report, diagrams, screenshots, and viva notes are prepared.

---

## 16. First Implementation Task

Start with the foundation rather than building every screen at once:

1. Run `flutter doctor` and verify Android development works.
2. Create the `studymate_ai` Flutter project.
3. Create the Firebase project and enable Email/Password Authentication.
4. Configure Firebase using FlutterFire CLI.
5. Add the core dependencies.
6. Initialize Firebase in `main.dart`.
7. Build login, signup, and password-reset screens.
8. Implement the auth repository and Riverpod view model.
9. Add GoRouter redirects based on authentication state.
10. Test signup, login, restart persistence, logout, and protected navigation.

**Important:** Complete and test each phase before moving on. Do not treat the proposed schema, sample rules, or architecture as production-ready without implementing and testing the corresponding code.

