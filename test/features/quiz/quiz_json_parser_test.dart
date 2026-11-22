// Unit tests for Quiz JSON parsing
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

// Minimal test models to avoid dependency issues
class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      correctIndex: json['correctIndex'] as int,
      explanation: json['explanation'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'question': question,
        'options': options,
        'correctIndex': correctIndex,
        'explanation': explanation,
      };
}

class Quiz {
  final String id;
  final String title;
  final String subject;
  final String difficulty;
  final List<QuizQuestion> questions;
  final String createdAt;

  Quiz({
    required this.id,
    required this.title,
    required this.subject,
    required this.difficulty,
    required this.questions,
    required this.createdAt,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] as String,
      title: json['title'] as String,
      subject: json['subject'] as String,
      difficulty: json['difficulty'] as String,
      questions: (json['questions'] as List)
          .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subject': subject,
        'difficulty': difficulty,
        'questions': questions.map((q) => q.toJson()).toList(),
        'createdAt': createdAt,
      };
}

class AnsweredQuestion {
  final String question;
  final List<String> options;
  final int selectedIndex;
  final int correctIndex;
  final String explanation;

  AnsweredQuestion({
    required this.question,
    required this.options,
    required this.selectedIndex,
    required this.correctIndex,
    required this.explanation,
  });

  factory AnsweredQuestion.fromJson(Map<String, dynamic> json) {
    return AnsweredQuestion(
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      selectedIndex: json['selectedIndex'] as int,
      correctIndex: json['correctIndex'] as int,
      explanation: json['explanation'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'question': question,
        'options': options,
        'selectedIndex': selectedIndex,
        'correctIndex': correctIndex,
        'explanation': explanation,
      };
}

void main() {
  group('Quiz JSON Parser', () {
    group('Valid JSON', () {
      test('QuizQuestion.fromJson parses valid JSON correctly', () {
        final json = {
          'question': 'What is 2 + 2?',
          'options': ['3', '4', '5', '6'],
          'correctIndex': 1,
          'explanation': '2 + 2 equals 4',
        };

        final question = QuizQuestion.fromJson(json);

        expect(question.question, 'What is 2 + 2?');
        expect(question.options, ['3', '4', '5', '6']);
        expect(question.correctIndex, 1);
        expect(question.explanation, '2 + 2 equals 4');
      });

      test('Quiz.fromJson parses valid JSON with questions', () {
        final json = {
          'id': 'quiz123',
          'title': 'Math Quiz',
          'subject': 'Mathematics',
          'difficulty': 'Easy',
          'questions': [
            {
              'question': 'What is 2 + 2?',
              'options': ['3', '4', '5', '6'],
              'correctIndex': 1,
              'explanation': '2 + 2 equals 4',
            },
            {
              'question': 'What is 3 + 3?',
              'options': ['5', '6', '7', '8'],
              'correctIndex': 2,
              'explanation': '3 + 3 equals 6',
            },
          ],
          'createdAt': '2024-01-15T10:00:00',
        };

        final quiz = Quiz.fromJson(json);

        expect(quiz.id, 'quiz123');
        expect(quiz.title, 'Math Quiz');
        expect(quiz.subject, 'Mathematics');
        expect(quiz.difficulty, 'Easy');
        expect(quiz.questions.length, 2);
      });

      test('AnsweredQuestion.fromJson parses valid JSON correctly', () {
        final json = {
          'question': 'What is the capital of France?',
          'options': ['London', 'Paris', 'Berlin', 'Madrid'],
          'selectedIndex': 1,
          'correctIndex': 1,
          'explanation': 'Paris is the capital of France',
        };

        final answer = AnsweredQuestion.fromJson(json);

        expect(answer.question, 'What is the capital of France?');
        expect(answer.options, ['London', 'Paris', 'Berlin', 'Madrid']);
        expect(answer.selectedIndex, 1);
        expect(answer.correctIndex, 1);
        expect(answer.explanation, 'Paris is the capital of France');
      });
    });

    group('Malformed JSON', () {
      test('QuizQuestion.fromJson throws on missing fields', () {
        final json = {
          'question': 'What is 2 + 2?',
          'options': ['3', '4'],
          // missing correctIndex and explanation
        };

        expect(
          () => QuizQuestion.fromJson(json),
          throwsA(isA<TypeError>()),
        );
      });

      test('QuizQuestion.fromJson throws on wrong field types', () {
        final json = {
          'question': 123, // should be String
          'options': ['3', '4'],
          'correctIndex': 1,
          'explanation': 'Correct',
        };

        expect(
          () => QuizQuestion.fromJson(json),
          throwsA(isA<TypeError>()),
        );
      });

      test('Quiz.fromJson handles questions list correctly', () {
        final json = {
          'id': 'quiz123',
          'title': 'Test Quiz',
          'subject': 'Science',
          'difficulty': 'Medium',
          'questions': [
            {
              'question': 'Q1',
              'options': ['A', 'B'],
              'correctIndex': 0,
              'explanation': 'E1',
            },
          ],
          'createdAt': '2024-01-15T10:00:00',
        };

        final quiz = Quiz.fromJson(json);
        expect(quiz.questions.length, 1);
        expect(quiz.questions.first.question, 'Q1');
      });
    });

    group('Extra text handling', () {
      test('JSON response with code fences is handled by cleanJson helper', () {
        const responseWithCodeFences = '''
```json
{
  "questions": [
    {
      "question": "What is 2 + 2?",
      "options": ["3", "4", "5", "6"],
      "correctIndex": 1,
      "explanation": "2 + 2 equals 4"
    }
  ]
}
```
''';

        final cleanJson = _cleanJson(responseWithCodeFences);
        final questions = _parseQuestionsFromCleanJson(cleanJson);

        expect(questions.length, 1);
        expect(questions.first.question, 'What is 2 + 2?');
        expect(questions.first.correctIndex, 1);
      });

      test('JSON with extra text before and after', () {
        const responseWithExtraText = '''
Here is your quiz:

```json
{
  "questions": [
    {
      "question": "Capital of France?",
      "options": ["London", "Paris", "Berlin"],
      "correctIndex": 1,
      "explanation": "Paris is correct"
    }
  ]
}
```

Good luck!
''';

        final cleanJson = _cleanJson(responseWithExtraText);
        final questions = _parseQuestionsFromCleanJson(cleanJson);

        expect(questions.length, 1);
        expect(questions.first.question, 'Capital of France?');
      });
    });

    group('ToJson round-trip', () {
      test('QuizQuestion toJson and fromJson are consistent', () {
        final original = QuizQuestion(
          question: 'Test question?',
          options: ['A', 'B', 'C'],
          correctIndex: 0,
          explanation: 'Test explanation',
        );

        final json = original.toJson();
        final parsed = QuizQuestion.fromJson(json);

        expect(parsed.question, original.question);
        expect(parsed.options, original.options);
        expect(parsed.correctIndex, original.correctIndex);
        expect(parsed.explanation, original.explanation);
      });
    });
  });
}

/// Helper to clean JSON response with potential code fences and extra text
String _cleanJson(String text) {
  String cleanText = text.trim();

  // Remove code fence start
  if (cleanText.contains('```json')) {
    cleanText = cleanText.substring(cleanText.indexOf('```json') + 7);
  } else if (cleanText.contains('```')) {
    cleanText = cleanText.substring(cleanText.indexOf('```') + 3);
  }

  // Remove code fence end
  if (cleanText.contains('```')) {
    cleanText = cleanText.substring(0, cleanText.indexOf('```'));
  }

  // Find JSON object boundaries
  final start = cleanText.indexOf('{');
  final end = cleanText.lastIndexOf('}') + 1;

  if (start == -1 || end == 0) {
    return cleanText.trim();
  }

  return cleanText.substring(start, end);
}

/// Helper to parse questions from cleaned JSON
List<QuizQuestion> _parseQuestionsFromCleanJson(String jsonStr) {
  final Map<String, dynamic> json = jsonDecode(jsonStr) as Map<String, dynamic>;
  final questionList = json['questions'] as List;
  return questionList
      .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
      .toList();
}
