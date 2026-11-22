// Badge domain model

import 'package:cloud_firestore/cloud_firestore.dart';

/// A badge unlocked by a user
class UserBadge {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final DateTime unlockedAt;

  UserBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.unlockedAt,
  });

  factory UserBadge.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserBadge(
      id: doc.id,
      name: data['name'] as String,
      description: data['description'] as String,
      iconName: data['iconName'] as String,
      unlockedAt: (data['unlockedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'iconName': iconName,
        'unlockedAt': unlockedAt,
      };
}

/// Badge definition (constant)
class BadgeDef {
  final String id;
  final String name;
  final String description;
  final String iconName;

  const BadgeDef({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
  });
}

/// All available badges
const List<BadgeDef> allBadges = [
  BadgeDef(
    id: 'first_quiz',
    name: 'First Quiz',
    description: 'Completed your first quiz',
    iconName: 'quiz',
  ),
  BadgeDef(
    id: 'streak_7',
    name: '7-Day Streak',
    description: 'Studied for 7 days in a row',
    iconName: 'local_fire_department',
  ),
  BadgeDef(
    id: 'streak_30',
    name: '30-Day Streak',
    description: 'Studied for 30 days in a row',
    iconName: 'local_fire_department',
  ),
  BadgeDef(
    id: 'cards_100',
    name: '100 Cards',
    description: 'Created 100 flashcards',
    iconName: 'shuffle',
  ),
  BadgeDef(
    id: 'notes_50',
    name: '50 Notes',
    description: 'Created 50 notes',
    iconName: 'note',
  ),
  BadgeDef(
    id: 'level_10',
    name: 'Level 10',
    description: 'Reached level 10',
    iconName: 'star',
  ),
  BadgeDef(
    id: 'focus_1000',
    name: 'Focus Master',
    description: 'Completed 1000 minutes of focus sessions',
    iconName: 'timer',
  ),
  BadgeDef(
    id: 'quiz_10',
    name: 'Quiz Master',
    description: 'Completed 10 quizzes',
    iconName: 'quiz',
  ),
  BadgeDef(
    id: 'perfect_score',
    name: 'Perfect Score',
    description: 'Got 100% on a quiz',
    iconName: 'score',
  ),
];
