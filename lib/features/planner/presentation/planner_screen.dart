import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../subjects/data/subject_repository.dart';
import '../../tasks/data/task_repository.dart';
import '../domain/planner_algorithm.dart';

class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({super.key});

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen> with SingleTickerProviderStateMixin {
  late DateTime _weekStart;
  int _selectedDayIndex = 0;
  List<ScheduledSession> _sessions = [];
  bool _isGenerated = false;
  late AnimationController _regenController;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    // Monday of current week
    _weekStart = now.subtract(Duration(days: now.weekday - 1));
    _regenController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
  }

  @override
  void dispose() {
    _regenController.dispose();
    super.dispose();
  }

  void _refreshScheduleIfNeeded() {
    final tasks = ref.read(tasksStreamProvider).value ?? [];
    final subjects = ref.read(subjectsStreamProvider).value ?? [];

    if (!_isGenerated && (tasks.isNotEmpty || subjects.isNotEmpty)) {
      _sessions = StudyPlannerAlgorithm.generateSchedule(
        tasks: tasks,
        subjects: subjects,
        weekStartDate: _weekStart,
        dailyStudyMinutes: 240,
      );
      _isGenerated = true;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshScheduleIfNeeded();
  }

  void _regenerate() {
    final tasks = ref.read(tasksStreamProvider).value ?? [];
    final subjects = ref.read(subjectsStreamProvider).value ?? [];
    setState(() {
      _sessions = StudyPlannerAlgorithm.generateSchedule(
        tasks: tasks,
        subjects: subjects,
        weekStartDate: _weekStart,
        dailyStudyMinutes: 240,
      );
      _isGenerated = true;
    });
    _regenController.forward(from: 0);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Study schedule generated and optimized!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final weekEnd = _weekStart.add(const Duration(days: 6));
    final weekRangeText =
        '${DateFormat('MMM d').format(_weekStart)} - ${DateFormat('MMM d, yyyy').format(weekEnd)}';

    final selectedDay = _weekStart.add(Duration(days: _selectedDayIndex));
    final dailySessions = _sessions.where((s) {
      return s.startTime.year == selectedDay.year &&
          s.startTime.month == selectedDay.month &&
          s.startTime.day == selectedDay.day;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Study Planner'),
            Text(
              'Your personalized study schedule',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Optimize & Regenerate Schedule',
            icon: const Icon(Icons.auto_awesome_rounded),
            color: isDark ? AppColors.neonPurple : AppColors.primaryPurple,
            onPressed: _regenerate,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          // Week Navigator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: () {
                    setState(() {
                      _weekStart = _weekStart.subtract(const Duration(days: 7));
                      _isGenerated = false;
                    });
                  },
                ),
                Text(
                  weekRangeText,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  onPressed: () {
                    setState(() {
                      _weekStart = _weekStart.add(const Duration(days: 7));
                      _isGenerated = false;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Horizontal Day Pills
          SizedBox(
            height: 72,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 7,
              itemBuilder: (context, index) {
                final day = _weekStart.add(Duration(days: index));
                final isSelected = index == _selectedDayIndex;
                final dayName = DateFormat('E').format(day);
                final dayNum = day.day;

                final primaryColor = isDark ? AppColors.neonPurple : AppColors.primaryPurple;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDayIndex = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primaryColor
                          : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurface),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? primaryColor
                            : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        width: 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          dayName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$dayNum',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Sessions List for selected day
          Expanded(
            child: dailySessions.isEmpty
                ? Center(
                    child: Text(
                      'No study sessions scheduled for this day.\nTap the magic wand icon above to auto-generate!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        height: 1.5,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: dailySessions.length,
                    itemBuilder: (context, index) {
                      final session = dailySessions[index];
                      final timeRange =
                          '${DateFormat('HH:mm').format(session.startTime)} - ${DateFormat('HH:mm').format(session.endTime)}';

                      final subjectColor = Color(
                        int.parse(session.colorHex.replaceFirst('#', '0xFF')),
                      );

                      Color priorityBadgeColor;
                      switch (session.priority.toLowerCase()) {
                        case 'high':
                          priorityBadgeColor = AppColors.priorityHigh;
                          break;
                        case 'medium':
                          priorityBadgeColor = AppColors.priorityMedium;
                          break;
                        default:
                          priorityBadgeColor = AppColors.priorityLow;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: AppCard(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          onTap: () {
                            setState(() {
                              final idx = _sessions.indexOf(session);
                              if (idx != -1) {
                                _sessions[idx] =
                                    session.copyWith(isCompleted: !session.isCompleted);
                              }
                            });
                          },
                          child: Row(
                            children: [
                              // Left colored stripe
                              Container(
                                width: 4,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: subjectColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 14),
                              // Time block
                              SizedBox(
                                width: 95,
                                child: Text(
                                  timeRange,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Subject and priority
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      session.subjectName,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        decoration: session.isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                        color: session.isCompleted
                                            ? (isDark
                                                ? AppColors.darkTextDisabled
                                                : AppColors.lightTextDisabled)
                                            : (isDark
                                                ? AppColors.darkTextPrimary
                                                : AppColors.lightTextPrimary),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${session.taskTitle} (${session.priority.toUpperCase()})',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: priorityBadgeColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Completion Checkmark
                              Icon(
                                session.isCompleted
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                color: session.isCompleted
                                    ? AppColors.emeraldGreen
                                    : (isDark
                                        ? AppColors.darkTextDisabled
                                        : AppColors.lightTextDisabled),
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
