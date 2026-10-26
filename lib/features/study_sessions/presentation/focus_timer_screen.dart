import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../subjects/data/subject_repository.dart';
import '../../tasks/data/task_repository.dart';

class FocusTimerScreen extends ConsumerStatefulWidget {
  const FocusTimerScreen({super.key});

  @override
  ConsumerState<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends ConsumerState<FocusTimerScreen> {
  int _targetMinutes = 25; // 25, 45, 60
  int _secondsRemaining = 25 * 60;
  Timer? _timer;
  bool _isRunning = false;
  String? _selectedSubjectId;
  String? _selectedTaskId;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _setDuration(int minutes) {
    if (_isRunning) return;
    setState(() {
      _targetMinutes = minutes;
      _secondsRemaining = minutes * 60;
    });
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() {
        _isRunning = false;
      });
    } else {
      setState(() {
        _isRunning = true;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_secondsRemaining > 0) {
          setState(() {
            _secondsRemaining--;
          });
        } else {
          timer.cancel();
          setState(() {
            _isRunning = false;
          });
          _completeSession();
        }
      });
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _secondsRemaining = _targetMinutes * 60;
    });
  }

  Future<void> _completeSession() async {
    final studiedMinutes = (_targetMinutes * 60 - _secondsRemaining) ~/ 60;
    final minutesToAdd = studiedMinutes > 0 ? studiedMinutes : _targetMinutes;

    if (_selectedSubjectId != null) {
      final subjectRepo = ref.read(subjectRepositoryProvider);
      final subject = await subjectRepo.getSubjectById(_selectedSubjectId!);
      if (subject != null) {
        final updated = subject.copyWith(
          studiedMinutes: subject.studiedMinutes + minutesToAdd,
        );
        await subjectRepo.updateSubject(updated);
      }
    }

    if (_selectedTaskId != null) {
      final taskRepo = ref.read(taskRepositoryProvider);
      await taskRepo.toggleTaskStatus(_selectedTaskId!);
    }

    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('🎉 Study Session Completed!'),
          content: Text(
            'Awesome focus! You logged $minutesToAdd minutes of productive study time.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _resetTimer();
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.neonPurple : AppColors.primaryPurple;
    final subjectsAsync = ref.watch(subjectsStreamProvider);
    final tasksAsync = ref.watch(tasksStreamProvider);

    final totalSeconds = _targetMinutes * 60;
    final progress = totalSeconds > 0
        ? (_secondsRemaining / totalSeconds).clamp(0.0, 1.0)
        : 0.0;

    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;
    final timeString =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Timer'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Subject Selection
              subjectsAsync.when(
                data: (subjects) {
                  if (subjects.isNotEmpty && _selectedSubjectId == null) {
                    _selectedSubjectId = subjects.first.id;
                  }
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        value: _selectedSubjectId,
                        isExpanded: true,
                        dropdownColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        hint: const Text('Select Study Subject'),
                        items: subjects.map((sub) {
                          return DropdownMenuItem<String>(
                            value: sub.id,
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Color(
                                      int.parse(sub.colorHex.replaceFirst('#', '0xFF')),
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(sub.name),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: _isRunning
                            ? null
                            : (val) {
                                setState(() {
                                  _selectedSubjectId = val;
                                });
                              },
                      ),
                    ),
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_, _) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 12),

              // Task Selection
              tasksAsync.when(
                data: (tasks) {
                  final pendingTasks = tasks.where((t) => !t.isCompleted).toList();
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        value: _selectedTaskId,
                        isExpanded: true,
                        dropdownColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        hint: const Text('Link Study Task (Optional)'),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('General Focus / Unlinked'),
                          ),
                          ...pendingTasks.map((t) {
                            return DropdownMenuItem<String>(
                              value: t.id,
                              child: Text(t.title),
                            );
                          }),
                        ],
                        onChanged: _isRunning
                            ? null
                            : (val) {
                                setState(() {
                                  _selectedTaskId = val;
                                });
                              },
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 28),

              // Duration Preset Chips
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [25, 45, 60].map((mins) {
                  final isSelected = _targetMinutes == mins;
                  return GestureDetector(
                    onTap: () => _setDuration(mins),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? primaryColor
                            : (isDark
                                ? AppColors.darkSurfaceVariant
                                : AppColors.lightSurfaceVariant),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? primaryColor
                              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        ),
                      ),
                      child: Text(
                        '$mins mins',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 36),

              // Circular Countdown Ring
              SizedBox(
                width: 230,
                height: 230,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 14,
                      backgroundColor: isDark
                          ? AppColors.darkSurfaceVariant
                          : AppColors.lightSurfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            timeString,
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isRunning ? 'Focus Time' : 'Paused',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _isRunning
                                  ? (isDark ? AppColors.emeraldGreen : AppColors.emeraldGreen)
                                  : (isDark ? AppColors.darkTextDisabled : AppColors.lightTextDisabled),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Controls: Start/Pause, Reset, Complete
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Reset Button
                  IconButton.filledTonal(
                    iconSize: 28,
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: _resetTimer,
                  ),
                  const SizedBox(width: 20),

                  // Play / Pause Primary Button
                  GestureDetector(
                    onTap: _toggleTimer,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Stop & Save Button
                  IconButton.filledTonal(
                    iconSize: 28,
                    icon: const Icon(Icons.check_rounded),
                    onPressed: _completeSession,
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // Study Session Tip Card
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.bolt_rounded, color: primaryColor, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Pomodoro Technique: 25 minutes of deep focus followed by 5 minutes of rest increases long-term retention by 40%.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
