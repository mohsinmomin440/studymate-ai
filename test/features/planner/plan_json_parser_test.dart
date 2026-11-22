// Unit tests for Study Plan JSON parsing
import 'package:flutter_test/flutter_test.dart';

// Minimal test models to avoid dependency issues
class StudyPlanData {
  final List<StudyDay> days;

  StudyPlanData({required this.days});

  factory StudyPlanData.fromJson(Map<String, dynamic> json) => StudyPlanData(
        days: (json['days'] as List)
            .map((e) => StudyDay.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'days': days.map((e) => e.toJson()).toList(),
      };
}

class StudyDay {
  final DateTime date;
  final List<StudyTask> tasks;

  StudyDay({required this.date, required this.tasks});

  factory StudyDay.fromJson(Map<String, dynamic> json) => StudyDay(
        date: DateTime.parse(json['date'] as String),
        tasks: (json['tasks'] as List)
            .map((e) => StudyTask.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String().split('T')[0],
        'tasks': tasks.map((t) => t.toJson()).toList(),
      };
}

class StudyTask {
  final String title;
  final String subject;
  final int estimatedMinutes;
  final String type;

  StudyTask({
    required this.title,
    required this.subject,
    required this.estimatedMinutes,
    required this.type,
  });

  factory StudyTask.fromJson(Map<String, dynamic> json) => StudyTask(
        title: json['title'] as String,
        subject: json['subject'] as String,
        estimatedMinutes: json['estimatedMinutes'] as int,
        type: json['type'] as String,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'subject': subject,
        'estimatedMinutes': estimatedMinutes,
        'type': type,
      };
}

void main() {
  group('Study Plan JSON Parser', () {
    group('Valid JSON', () {
      test('StudyDay.fromJson parses valid JSON correctly', () {
        final json = {
          'date': '2026-12-15',
          'tasks': [
            {
              'title': 'Mathematics - Algebra Basics',
              'subject': 'Mathematics',
              'estimatedMinutes': 60,
              'type': 'study',
            },
            {
              'title': 'Review - Flashcards',
              'subject': 'Mathematics',
              'estimatedMinutes': 25,
              'type': 'review',
            },
          ],
        };

        final day = StudyDay.fromJson(json);

        expect(day.date, DateTime(2026, 12, 15));
        expect(day.tasks.length, 2);
        expect(day.tasks[0].title, 'Mathematics - Algebra Basics');
        expect(day.tasks[0].type, 'study');
        expect(day.tasks[0].estimatedMinutes, 60);
        expect(day.tasks[1].type, 'review');
      });

      test('StudyTask.fromJson parses valid JSON correctly', () {
        final json = {
          'title': 'Physics - Mechanics',
          'subject': 'Physics',
          'estimatedMinutes': 90,
          'type': 'study',
        };

        final task = StudyTask.fromJson(json);

        expect(task.title, 'Physics - Mechanics');
        expect(task.subject, 'Physics');
        expect(task.estimatedMinutes, 90);
        expect(task.type, 'study');
      });

      test('StudyPlanData.fromJson parses valid JSON with multiple days', () {
        final json = {
          'days': [
            {
              'date': '2026-12-15',
              'tasks': [
                {
                  'title': 'Mathematics - Algebra',
                  'subject': 'Mathematics',
                  'estimatedMinutes': 60,
                  'type': 'study',
                },
              ],
            },
            {
              'date': '2026-12-16',
              'tasks': [
                {
                  'title': 'Physics - Mechanics',
                  'subject': 'Physics',
                  'estimatedMinutes': 90,
                  'type': 'study',
                },
                {
                  'title': 'Break',
                  'subject': 'Break',
                  'estimatedMinutes': 15,
                  'type': 'break',
                },
              ],
            },
          ],
        };

        final plan = StudyPlanData.fromJson(json);

        expect(plan.days.length, 2);
        expect(plan.days[0].date, DateTime(2026, 12, 15));
        expect(plan.days[0].tasks.length, 1);
        expect(plan.days[1].tasks.length, 2);
        expect(plan.days[1].tasks[1].type, 'break');
      });

      test('All task types are parsed correctly', () {
        final json = {
          'date': '2026-12-15',
          'tasks': [
            {
              'title': 'Study Module',
              'subject': 'Mathematics',
              'estimatedMinutes': 45,
              'type': 'study',
            },
            {
              'title': 'Flashcard Review',
              'subject': 'Mathematics',
              'estimatedMinutes': 25,
              'type': 'review',
            },
            {
              'title': 'Practice Problems',
              'subject': 'Mathematics',
              'estimatedMinutes': 30,
              'type': 'practice',
            },
            {
              'title': 'Lunch Break',
              'subject': 'Break',
              'estimatedMinutes': 30,
              'type': 'break',
            },
          ],
        };

        final day = StudyDay.fromJson(json);

        expect(day.tasks[0].type, 'study');
        expect(day.tasks[1].type, 'review');
        expect(day.tasks[2].type, 'practice');
        expect(day.tasks[3].type, 'break');
      });
    });

    group('Malformed JSON', () {
      test('StudyDay.fromJson throws on missing fields', () {
        final json = {
          'date': '2026-12-15',
          // missing tasks
        };

        expect(
          () => StudyDay.fromJson(json),
          throwsA(isA<TypeError>()),
        );
      });

      test('StudyTask.fromJson throws on wrong field types', () {
        final json = {
          'title': 'Test',
          'subject': 'Math',
          'estimatedMinutes': '60', // should be int
          'type': 'study',
        };

        expect(
          () => StudyTask.fromJson(json),
          throwsA(isA<TypeError>()),
        );
      });

      test('StudyPlanData handles empty days list', () {
        final json = {'days': []};

        final plan = StudyPlanData.fromJson(json);
        expect(plan.days.length, 0);
      });
    });

    group('ToJson round-trip', () {
      test('StudyDay toJson and fromJson are consistent', () {
        final original = StudyDay(
          date: DateTime(2026, 12, 15),
          tasks: [
            StudyTask(
              title: 'Test Task',
              subject: 'Mathematics',
              estimatedMinutes: 60,
              type: 'study',
            ),
          ],
        );

        final json = original.toJson();
        final parsed = StudyDay.fromJson(json);

        expect(parsed.date, original.date);
        expect(parsed.tasks.length, original.tasks.length);
        expect(parsed.tasks[0].title, original.tasks[0].title);
      });

      test('StudyPlanData toJson and fromJson are consistent', () {
        final original = StudyPlanData(days: [
          StudyDay(
            date: DateTime(2026, 12, 15),
            tasks: [
              StudyTask(
                title: 'Task 1',
                subject: 'Math',
                estimatedMinutes: 30,
                type: 'study',
              ),
            ],
          ),
          StudyDay(
            date: DateTime(2026, 12, 16),
            tasks: [
              StudyTask(
                title: 'Task 2',
                subject: 'Physics',
                estimatedMinutes: 45,
                type: 'review',
              ),
            ],
          ),
        ]);

        final json = original.toJson();
        final parsed = StudyPlanData.fromJson(json);

        expect(parsed.days.length, original.days.length);
        expect(parsed.days[0].date, original.days[0].date);
        expect(parsed.days[1].tasks.length, original.days[1].tasks.length);
      });
    });
  });
}
