import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_card.dart';
import '../../auth/presentation/auth_view_model.dart';
import '../../subjects/data/subject_repository.dart';
import '../../tasks/data/task_repository.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authProvider);
    final subjectsAsync = ref.watch(subjectsStreamProvider);
    final tasksAsync = ref.watch(tasksStreamProvider);

    final userName = authState.user?.displayName.isNotEmpty == true
        ? authState.user!.displayName
        : 'Rahul';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good Morning,',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          userName,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Notification Bell with badge
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurfaceVariant
                              : AppColors.lightSurfaceVariant,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.notifications_none_rounded),
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Reminder: Review Linked Lists at 11:00 AM!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.neonPurple : AppColors.crimsonRed,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? AppColors.darkSurface : Colors.white,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  // User Avatar
                  GestureDetector(
                    onTap: () => context.push('/profile'),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.neonPurple.withOpacity(0.2)
                            : AppColors.primaryPurple.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppColors.neonPurple : AppColors.primaryPurple,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : 'R',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.neonPurple : AppColors.primaryPurple,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Today's Study Progress Card
              tasksAsync.when(
                data: (tasks) {
                  final completedCount =
                      tasks.where((t) => t.status == AppConstants.statusCompleted).length;
                  final totalCount = tasks.isNotEmpty ? tasks.length : 1;
                  final progressPercent = (completedCount / totalCount).clamp(0.0, 1.0);
                  final displayPercentage = (progressPercent * 100).toInt();

                  return AppCard(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        // Circular Progress Indicator
                        SizedBox(
                          width: 84,
                          height: 84,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CircularProgressIndicator(
                                value: progressPercent == 0 ? 0.05 : progressPercent,
                                strokeWidth: 8,
                                backgroundColor: isDark
                                    ? AppColors.darkSurfaceVariant
                                    : AppColors.lightSurfaceVariant,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isDark ? AppColors.neonPurple : AppColors.primaryPurple,
                                ),
                              ),
                              Center(
                                child: Text(
                                  '$displayPercentage%',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Today's Study Progress",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.task_alt_rounded,
                                    size: 16,
                                    color: isDark
                                        ? AppColors.neonPurple
                                        : AppColors.primaryPurple,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$completedCount/$totalCount tasks completed',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 16,
                                    color: isDark
                                        ? AppColors.emeraldGreen
                                        : AppColors.emeraldGreen,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '3h 15m studied today',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 28),

              // Upcoming Exams Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Upcoming Exams',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/subjects'),
                    child: Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.neonPurple : AppColors.primaryPurple,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Upcoming Exams List
              subjectsAsync.when(
                data: (subjects) {
                  final examSubjects = subjects.where((s) => s.examAt != null).toList()
                    ..sort((a, b) => a.examAt!.compareTo(b.examAt!));

                  if (examSubjects.isEmpty) {
                    return AppCard(
                      child: Center(
                        child: Text(
                          'No upcoming exams scheduled',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: examSubjects.take(3).map((sub) {
                      final daysLeft = sub.daysUntilExam ?? 0;
                      final isUrgent = daysLeft <= 14;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: AppCard(
                          padding: const EdgeInsets.all(14),
                          onTap: () => context.go('/subjects'),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Color(int.parse(sub.colorHex.replaceFirst('#', '0xFF')))
                                      .withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.menu_book_rounded,
                                  color: Color(int.parse(sub.colorHex.replaceFirst('#', '0xFF'))),
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sub.name,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? AppColors.darkTextPrimary
                                            : AppColors.lightTextPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      sub.examAt != null
                                          ? '${sub.examAt!.day} ${_monthName(sub.examAt!.month)} ${sub.examAt!.year}'
                                          : 'No date',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.lightTextSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Countdown Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: isUrgent
                                      ? (isDark
                                          ? AppColors.darkDangerBackground
                                          : AppColors.lightDangerBackground)
                                      : (isDark
                                          ? AppColors.darkSuccessBackground
                                          : AppColors.lightSuccessBackground),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$daysLeft days left',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isUrgent
                                        ? (isDark
                                            ? AppColors.darkDangerText
                                            : AppColors.lightDangerText)
                                        : (isDark
                                            ? AppColors.darkSuccessText
                                            : AppColors.lightSuccessText),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 28),

              // Today's Tasks Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Today's Tasks",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/tasks'),
                    child: Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.neonPurple : AppColors.primaryPurple,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Today's Tasks List
              tasksAsync.when(
                data: (tasks) {
                  if (tasks.isEmpty) {
                    return AppCard(
                      child: Center(
                        child: Text(
                          'No tasks scheduled for today',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: tasks.take(3).map((task) {
                      final isCompleted = task.status == AppConstants.statusCompleted;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: AppCard(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          onTap: () {
                            ref
                                .read(taskRepositoryProvider)
                                .toggleTaskStatus(task.id);
                          },
                          child: Row(
                            children: [
                              Checkbox(
                                value: isCompleted,
                                onChanged: (_) {
                                  ref
                                      .read(taskRepositoryProvider)
                                      .toggleTaskStatus(task.id);
                                },
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task.title,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        decoration: isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                        color: isCompleted
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
                                      '${task.estimatedMinutes} mins • Priority: ${task.priority.toUpperCase()}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.lightTextSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: isDark
                                    ? AppColors.darkTextDisabled
                                    : AppColors.lightTextDisabled,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  static String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}
