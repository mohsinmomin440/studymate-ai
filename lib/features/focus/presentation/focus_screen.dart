// Focus Timer - Pomodoro timer with session tracking

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/notification_service.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/section_header.dart';

// Focus session state
class FocusSessionState {
  final int remainingSeconds;
  final int totalSeconds;
  final bool isRunning;
  final int sessionCount;
  final int totalFocusMinutes;
  final DateTime? lastSessionStart;

  FocusSessionState({
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.isRunning,
    required this.sessionCount,
    required this.totalFocusMinutes,
    this.lastSessionStart,
  });

  FocusSessionState copyWith({
    int? remainingSeconds,
    int? totalSeconds,
    bool? isRunning,
    int? sessionCount,
    int? totalFocusMinutes,
    DateTime? lastSessionStart,
  }) {
    return FocusSessionState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      isRunning: isRunning ?? this.isRunning,
      sessionCount: sessionCount ?? this.sessionCount,
      totalFocusMinutes: totalFocusMinutes ?? this.totalFocusMinutes,
      lastSessionStart: lastSessionStart ?? this.lastSessionStart,
    );
  }
}

// Focus session notifier
class FocusSessionNotifier extends StateNotifier<FocusSessionState> {
  Timer? _timer;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  FocusSessionNotifier()
      : super(FocusSessionState(
            remainingSeconds: AppConstants.defaultFocusMinutes * 60,
            totalSeconds: AppConstants.defaultFocusMinutes * 60,
            isRunning: false,
            sessionCount: 0,
            totalFocusMinutes: 0,
          ));

  String get _uid => _auth.currentUser?.uid ?? '';

  String _getTodayDate() {
    return DateTime.now().toIso8601String().split('T')[0];
  }

  /// Log focus minutes to Firestore daily stats
  Future<void> _logFocusMinutes(int minutes) async {
    if (_uid.isEmpty) return;

    final today = _getTodayDate();
    final docRef = _firestore
        .collection(AppConstants.firestoreUsersCollection)
        .doc(_uid)
        .collection(AppConstants.firestoreDailyStatsCollection)
        .doc(today);

    try {
      await docRef.set({
        'studyMinutes': FieldValue.increment(minutes),
        'xpEarned':
            FieldValue.increment(minutes * AppConstants.xpPerFocusMinute),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // Silently fail - offline persistence will handle it
    }
  }

  void startTimer() {
    if (state.remainingSeconds <= 0) {
      final completedMinutes = state.totalSeconds ~/ 60;

      state = state.copyWith(
        remainingSeconds: state.totalSeconds,
        isRunning: false,
        sessionCount: state.sessionCount + 1,
        totalFocusMinutes: state.totalFocusMinutes + completedMinutes,
        lastSessionStart: DateTime.now(),
      );

      _logFocusMinutes(completedMinutes);
      return;
    }

    state = state.copyWith(isRunning: true);

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Use read to get current state inside the timer callback
      final remaining = state.remainingSeconds;
      if (remaining > 0) {
        state = state.copyWith(remainingSeconds: remaining - 1);
      } else {
        timer.cancel();
        final completedMinutes = state.totalSeconds ~/ 60;

        state = state.copyWith(
            isRunning: false,
            remainingSeconds: state.totalSeconds,
            sessionCount: state.sessionCount + 1,
            totalFocusMinutes: state.totalFocusMinutes + completedMinutes,
            lastSessionStart: DateTime.now());

        _showCompletionNotification();
        _logFocusMinutes(completedMinutes);
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void resetTimer() {
    _timer?.cancel();
    state = state.copyWith(
      remainingSeconds: state.totalSeconds,
      isRunning: false,
    );
  }

  void setDuration(int minutes) {
    _timer?.cancel();
    state = state.copyWith(
      totalSeconds: minutes * 60,
      remainingSeconds: minutes * 60,
      isRunning: false,
    );
  }

  void _showCompletionNotification() async {
    final notificationService = NotificationService();
    await notificationService.showFocusComplete(state.totalSeconds ~/ 60);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final focusSessionProvider =
    StateNotifierProvider<FocusSessionNotifier, FocusSessionState>((ref) {
  return FocusSessionNotifier();
});

class FocusScreen extends ConsumerStatefulWidget {
  const FocusScreen({super.key});

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen> {
  Future<bool>? _permissionStatusFuture;

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    final notificationService = NotificationService();
    await notificationService.initialize();
    setState(() {
      _permissionStatusFuture = _isNotificationPermissionGranted();
    });
  }

  Future<bool> _isNotificationPermissionGranted() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(focusSessionProvider);
    final notifier = ref.read(focusSessionProvider.notifier);
    final theme = Theme.of(context);

    final progress = state.totalSeconds > 0
        ? 1.0 - (state.remainingSeconds / state.totalSeconds)
        : 0.0;
    final minutes = state.remainingSeconds ~/ 60;
    final seconds = state.remainingSeconds % 60;
    final durationText = '$minutes:${seconds.toString().padLeft(2, '0')}';

    // Use Material 3 surface container
    final backgroundColor = theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);

    // Dark mode gradient styling
    final gradientColors = [
      theme.colorScheme.primary.withValues(alpha: 0.15),
      theme.colorScheme.secondary.withValues(alpha: 0.1),
    ];

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Focus Timer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => _DurationSelector(
                  currentMinutes: state.totalSeconds ~/ 60,
                  onSelected: (minutes) {
                    Navigator.pop(context);
                    notifier.setDuration(minutes);
                  },
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => _showNotificationSettings(),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GlassCard(
              child: Column(
                children: [
                  Text(
                    'Focus Session',
                    style: theme.textTheme.titleMedium,
                  ),
                  const Gap(24),
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Dark focus screen styling
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: state.isRunning
                                ? LinearGradient(
                                    colors: gradientColors,
                                  )
                                : null,
                            border: Border.all(
                              color: backgroundColor,
                              width: 2,
                            ),
                          ),
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 8,
                            backgroundColor: backgroundColor,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(theme.primaryColor),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              durationText,
                              style: theme.textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              state.isRunning ? 'Running' : 'Ready',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Gap(24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        iconSize: 48,
                        icon: CircleAvatar(
                          radius: 28,
                          backgroundColor: state.isRunning
                              ? theme.colorScheme.secondary.withValues(alpha: 0.2)
                              : theme.colorScheme.primary.withValues(alpha: 0.2),
                          child: Icon(
                            state.isRunning ? Icons.pause : Icons.play_arrow,
                            color: state.isRunning
                                ? theme.colorScheme.secondary
                                : theme.colorScheme.primary,
                          ),
                        ),
                        onPressed: state.isRunning
                            ? notifier.pauseTimer
                            : notifier.startTimer,
                      ),
                      const Gap(16),
                      ElevatedButton(
                        onPressed: notifier.resetTimer,
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(16),
                        ),
                        child: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  const Gap(16),
                  Text(
                    'Sessions: ${state.sessionCount}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const Gap(24),
            const SectionHeader(title: 'Session History'),
            const Gap(16),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today: ${state.totalFocusMinutes} minutes',
                    style: theme.textTheme.titleMedium,
                  ),
                  const Gap(8),
                  Text(
                    'Target: ${AppConstants.defaultFocusMinutes} minutes',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FutureBuilder<bool>(
              future: _permissionStatusFuture ??= _isNotificationPermissionGranted(),
              builder: (context, snapshot) {
                final isGranted = snapshot.data ?? false;
                return ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Allow Notifications'),
                  trailing: Switch(
                    value: isGranted,
                    onChanged: (val) async {
                      if (val) {
                        await Permission.notification.request();
                      }
                      if (!mounted) return;
                      Navigator.pop(context);
                      _showNotificationSettings();
                    },
                  ),
                );
              },
            ),
            const ListTile(
              leading: Icon(Icons.alarm),
              title: Text('Focus timer completion'),
              subtitle: Text('Gets notified when session ends'),
              trailing: Icon(Icons.check_circle, color: Colors.green),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _DurationSelector extends StatelessWidget {
  final int currentMinutes;
  final void Function(int minutes) onSelected;

  const _DurationSelector({
    required this.currentMinutes,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final durations = [15, 25, 30, 45, 60];

    return AlertDialog(
      title: const Text('Select Duration'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: durations.map((minutes) {
          return ListTile(
            leading: const Icon(Icons.timer),
            title: Text('$minutes minutes'),
            trailing: currentMinutes == minutes
                ? const Icon(Icons.check, color: Colors.green)
                : null,
            onTap: () {
              Navigator.pop(context);
              onSelected(minutes);
            },
          );
        }).toList(),
      ),
    );
  }
}