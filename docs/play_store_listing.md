# Play Store Listing

## App Name
**StudyMate AI**

## Short Description
AI-powered study companion that helps you learn smarter: chat with AI, solve doubts, make notes, create flashcards and quizzes, and track your progress.

## Full Description
StudyMate AI is your premium study companion designed to help students learn smarter, not harder. Powered by Google Gemini AI, StudyMate AI provides:

### 🧠 AI Tutor Chat
Ask questions, get step-by-step explanations, and study in your preferred style (Simple, Detailed, Exam-focused, Teach Me). Supports multiple subjects and languages.

### 📱 Doubt Scanner
Snap a photo of any math or science problem, and our AI will solve it step-by-step. Save doubts to review later or turn them into flashcards.

### 📝 Smart Notes
Create organized notes with rich text, tags, and subjects. Use AI to summarize, extract key points, simplify content, or translate between English, Hindi, and Gujarati.

### 🃏 Flashcards with SM-2 Algorithm
Create flashcards from your notes or AI-generated topics. Our spaced repetition system (SM-2 algorithm) shows you cards when you're about to forget them.

### ❓ Auto-Quiz Generator
Generate multiple-choice quizzes from any topic or note. Choose subject, difficulty, and question count. Get instant feedback with explanations.

### 📅 AI Study Planner
Enter your exam date, subjects, and available study hours. Our AI creates a personalized study plan with daily tasks and reminders.

### ⏰ Focus Timer (Pomodoro)
25/5 Pomodoro timer with ambient dark mode. Track your focus minutes and earn XP for productive study sessions.

### 📊 Progress & Gamification
Earn XP for studying, level up, build streaks, and unlock badges. Weekly progress charts show your improvement.

### 🌙 Premium UI/UX
Beautiful glassmorphism design with smooth animations, dark mode first, and smooth transitions between screens.

**No hidden costs, no ads, no internet required for most features!**

## Feature List

- AI tutor with streaming responses
- Image-based doubt solving
- Rich text notes with search and tags
- Flashcard decks with SM-2 spaced repetition
- Multiple-choice quiz generation (5/10/15 questions)
- AI-generated study plans
- Pomodoro focus timer with ambient screen
- XP, leveling, streaks, and badges
- Progress charts (study time, quiz scores)
- Dark and light mode
- Multi-language support (English, Hindi, Gujarati)
- Offline capable for notes and flashcards
- Sync across devices with Google Sign-In

## Screenshots Checklist

Prepare 2-8 screenshots for the Play Store listing:

1. **Home Dashboard** - Streak, XP, level, quick actions
   - Elements to capture: greeting, streak flame, XP ring, "Continue studying" card, quick actions (Ask AI, Scan, Notes, Quiz)
   
2. **AI Chat** - Tutor interface with streaming response
   - Elements to capture: subject selector, message bubbles, modes chips

3. **Flashcards** - Study mode with swipe animation
   - Elements to capture: card flip animation, rating buttons (Again/Hard/Good/Easy), progress indicator

4. **Quiz** - Take quiz screen with timer
   - Elements to capture: question, options, timer, explanation after answer

5. **Progress Charts** - Weekly study time and quiz scores
   - Elements to capture: line charts, streak badge, weekly summary

6. **Study Planner** - Exam plan with daily tasks
   - Elements to capture: exam date, subjects list, daily tasks checklist

7. **Focus Timer** - Pomodoro timer UI
   - Elements to capture: circular timer, dark ambient screen, session counter

## Data Safety Answers (Google Play Required)

### Data Type: Personal Info
| Question | Answer |
|----------|--------|
| Collect? | Yes - Name, email (for Google Sign-In) |
| Shared with third parties? | No |
| Security measures? | Firestore security rules ensure user-only access |
| Deleting data? | Yes - "Delete Account & Data" in Settings |

### Data Type: Photos & Videos
| Question | Answer |
|----------|--------|
| Collect? | Yes - for doubt scanner (sent to Gemini, not stored) |
| Shared with third parties? | No - only sent to Gemini AI for processing |
| Security measures? | Processed in memory only, not persisted |
| Deleting data? | Photos are not stored; only text results saved |

### Data Type: App Activity
| Question | Answer |
|----------|--------|
| Collect? | Yes - study time, XP, quizzes, flashcards |
| Shared with third parties? | No |
| Security measures? | Encrypted in Firestore with user auth |
| Deleting data? | Yes - included in "Delete Account & Data" |

### Data Type: Device or Other IDs
| Question | Answer |
|----------|--------|
| Collect? | Yes - Firebase Analytics, Crashlytics |
| Shared with third parties? | No - first-party Firebase usage |
| Security measures? | Anonymous tracking IDs only |
| Deleting data? | Analytics data retained per Firebase policy |

### Data Type: Location
| Question | Answer |
|----------|--------|
| Collect? | No |
| Shared with third parties? | N/A |
| Security measures? | N/A |
| Deleting data? | N/A |

### Data Type: Speech or Text
| Question | Answer |
|----------|--------|
| Collect? | Yes - your chat messages, notes, quiz answers |
| Shared with third parties? | Only to Google Gemini for AI processing |
| Security measures? | Encrypted in Firestore, user-only access |
| Deleting data? | Yes - "Delete Account & Data" removes all content |

## Permissions Required
| Permission | Purpose |
|------------|---------|
| Internet | For Firebase, Gemini AI, authentication |
| Camera | For doubt scanner to capture photos |
| Notifications | For study reminders and session completion |
| Storage | For accessing PDF/text files (Android File Access) |

## SCHEDULE_EXACT_ALARM Declaration

**For Android 14+ (API 34+):**

Add this to your `AndroidManifest.xml` inside the `<manifest>` tag:

```xml
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />

<uses-permission
    android:name="android.permission.POST_NOTIFICATIONS" />
```

And in `res/values/strings.xml` for Play Console declaration:

```xml
<string name="permission_schedule_exact_alarm">App uses exact alarms to remind users of study sessions and deliver scheduled notifications at specific times.</string>
```

## App Category
Education

## Tags
education, study, learn, AI, tutor, flashcards, quiz, notes, planner, pomodoro, timer, focus

## Contact Information
- Website: Through in-app feedback
- Email: Through Firebase App Check secure channel
- Privacy Policy: [link to privacy policy]

---

*This listing describes the actual features implemented in the app as of Phase 3 release preparation.*