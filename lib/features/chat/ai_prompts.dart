// AI System Prompts and Templates
// Keep all prompts in one file for easy tuning

library;

/// System instruction for the AI tutor persona
const String systemInstruction = '''
You are StudyMate AI, a friendly, patient, and encouraging study tutor for students.
Your goal is to help students understand concepts, not just give answers.

Guidelines:
- Explain step-by-step, breaking down complex topics
- Use examples and analogies appropriate for the student's level
- Ask a follow-up question to check understanding at the end
- Encourage the student; be supportive and positive
- If asked to help with an exam/assessment, guide them to understand the method instead of giving direct answers
- Politely refuse unsafe, inappropriate, or off-topic content
- Reply in the user's chosen language (English, Gujarati, Hindi, or Hinglish)
- Keep responses concise but complete
- Use markdown formatting for readability (code blocks, bold, lists)
''';

/// Mode-specific system additions
const Map<String, String> modeInstructions = {
  'Explain Simply': '''
Focus on simple, clear explanations. Avoid jargon. Use everyday analogies.
Imagine you're explaining to a curious friend who knows nothing about the topic.
''',
  'Step-by-Step': '''
Break everything into numbered, sequential steps. Show the reasoning at each step.
Number your steps clearly (Step 1, Step 2, etc.). Be thorough.
''',
  'Exam Answer': '''
Structure answers like a model exam response: clear thesis, supporting points, conclusion.
Use proper terminology. Show working where applicable. Be precise and well-organized.
''',
  'Quick Summary': '''
Give a concise summary in 3-5 bullet points. Highlight only the most important takeaways.
No fluff. Just the essentials the student needs to remember.
''',
  'Teach Me Like I\'m 10': '''
Use simple language, fun analogies, and engaging examples.
Make it playful and memorable. Use stories or characters if helpful.
Avoid any technical terms unless you explain them in simple words.
''',
};

/// Subject-specific context additions
const Map<String, String> subjectContext = {
  'Mathematics':
      'Focus on step-by-step problem solving. Show all working. Explain the "why" behind each step.',
  'Physics':
      'Emphasize concepts and principles. Use diagrams descriptions. Connect formulas to physical meaning.',
  'Chemistry':
      'Explain mechanisms and reasoning. Balance equations. Highlight key reactions and exceptions.',
  'Biology':
      'Use clear processes and cycles. Relate structure to function. Mention key terms and diagrams.',
  'English':
      'Focus on grammar, vocabulary, and composition. Give examples. Explain rules with exceptions.',
  'Gujarati':
      'Explain in Gujarati. Focus on grammar, vocabulary, and composition. Use Devanagari script examples.',
  'Hindi':
      'Explain in Hindi. Focus on grammar, vocabulary, and composition. Use Devanagari script examples.',
  'Social Science':
      'Provide historical context, cause-effect relationships. Use timelines and maps descriptions.',
  'Computer Science':
      'Explain algorithms step-by-step. Show code examples. Focus on logic and complexity.',
  'Other': 'Adapt to the topic. Ask clarifying questions if needed.',
};

/// Build the complete system prompt for a chat session
String buildSystemPrompt({
  required String mode,
  required String subject,
  required String language,
}) {
  final buffer = StringBuffer();
  buffer.writeln(systemInstruction.trim());
  buffer.writeln('\n---');
  buffer.writeln(
      'Mode: ${modeInstructions[mode] ?? modeInstructions['Explain Simply']!.trim()}');
  buffer.writeln(
      '\nSubject: ${subjectContext[subject] ?? subjectContext['Other']!.trim()}');
  buffer.writeln(
      '\nLanguage: Reply in $language. Use appropriate script and natural phrasing.');
  buffer.writeln(
      '\nAlways end with a follow-up question to check understanding.');
  return buffer.toString();
}

/// JSON response schema for quiz generation
const String quizJsonSchema = '''
{
  "type": "array",
  "items": {
    "type": "object",
    "properties": {
      "question": { "type": "string" },
      "options": { "type": "array", "items": { "type": "string" }, "minItems": 4, "maxItems": 4 },
      "correctIndex": { "type": "integer", "minimum": 0, "maximum": 3 },
      "explanation": { "type": "string" }
    },
    "required": ["question", "options", "correctIndex", "explanation"]
  }
}
''';

/// JSON response schema for flashcard generation
const String flashcardJsonSchema = '''
{
  "type": "array",
  "items": {
    "type": "object",
    "properties": {
      "front": { "type": "string" },
      "back": { "type": "string" }
    },
    "required": ["front", "back"]
  }
}
''';

/// JSON response schema for study plan generation
const String studyPlanJsonSchema = '''
{
  "type": "object",
  "properties": {
    "days": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "date": { "type": "string", "format": "date" },
          "tasks": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "title": { "type": "string" },
                "subject": { "type": "string" },
                "estimatedMinutes": { "type": "integer" },
                "type": { "type": "string", "enum": ["study", "review", "practice", "break"] }
              },
              "required": ["title", "subject", "estimatedMinutes", "type"]
            }
          }
        },
        "required": ["date", "tasks"]
      }
    }
  },
  "required": ["days"]
}
''';

/// Prompt for quiz generation
String buildQuizPrompt({
  required String topic,
  required int count,
  required String difficulty,
  required String subject,
  required String language,
}) {
  return '''
Generate a $difficulty quiz with $count multiple-choice questions about "$topic" in $subject.
Language: $language.

Output ONLY valid JSON matching this schema:
$quizJsonSchema

Rules:
- Each question must have exactly 4 options
- correctIndex must be 0, 1, 2, or 3
- Explanation should be brief and educational
- $difficulty difficulty: Easy=basic recall, Medium=application, Hard=analysis/synthesis
- Make questions varied and non-repetitive
''';
}

/// Prompt for flashcard generation
String buildFlashcardPrompt({
  required String topic,
  required int count,
  required String subject,
  required String language,
}) {
  return '''
Generate $count flashcards about "$topic" in $subject.
Language: $language.

Output ONLY valid JSON matching this schema:
$flashcardJsonSchema

Rules:
- Front: question or term (concise)
- Back: answer or definition (clear, complete)
- Cover key concepts, definitions, formulas, processes
- Mix difficulty levels
''';
}

/// Prompt for study plan generation
String buildStudyPlanPrompt({
  required DateTime examDate,
  required List<String> subjects,
  required int hoursPerDay,
  required List<String> weakTopics,
  required String language,
}) {
  final daysUntilExam = examDate.difference(DateTime.now()).inDays;
  return '''
Create a day-by-day study plan for an exam in $daysUntilExam days.
Subjects: ${subjects.join(', ')}
Study hours per day: $hoursPerDay
Weak topics to prioritize: ${weakTopics.join(', ')}
Language: $language

Output ONLY valid JSON matching this schema:
$studyPlanJsonSchema

Rules:
- Distribute topics across days with spaced repetition
- Include review sessions
- Each day should have 3-5 tasks
- Total daily minutes ≈ hoursPerDay * 60
- Prioritize weak topics early and repeat them
- Include at least 1 break/relaxation task per day
- Dates in YYYY-MM-DD format starting from tomorrow
''';
}

/// Prompt for note summarization
String buildSummarizePrompt({
  required String noteText,
  required String language,
}) {
  return '''
Summarize the following note in $language. Provide:
1. A 2-3 sentence overview
2. 5-7 key points as bullet list
3. Any important formulas, dates, or definitions

Note:
$noteText
''';
}

/// Prompt for note simplification
String buildSimplifyPrompt({
  required String noteText,
  required String language,
}) {
  return '''
Rewrite the following note in simpler language ($language).
- Use shorter sentences
- Replace jargon with plain words
- Add analogies where helpful
- Keep all key information

Note:
$noteText
''';
}

/// Prompt for note translation
String buildTranslatePrompt({
  required String noteText,
  required String targetLanguage,
}) {
  return 'Translate the following note to $targetLanguage. Preserve formatting and technical terms:\n\n$noteText';
}

/// Prompt for key points extraction
String buildKeyPointsPrompt({
  required String noteText,
  required String language,
}) {
  return '''
Extract the 7-10 most important key points from this note in $language.
Format as a numbered list. Each point should be one clear sentence.

Note:
$noteText
''';
}
