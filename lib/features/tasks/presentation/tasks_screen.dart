import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../subjects/data/subject_repository.dart';
import '../data/task_repository.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  String _selectedFilter = 'All'; // All, Pending, Completed

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tasksAsync = ref.watch(tasksStreamProvider);
    final subjectsAsync = ref.watch(subjectsStreamProvider);

    final subjectsMap = {
      for (var s in subjectsAsync.value ?? []) s.id: s
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: isDark ? AppColors.neonPurple : AppColors.primaryPurple,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
        onPressed: () => context.push('/tasks/add'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          // Filter Segmented Pills (All, Pending, Completed)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: ['All', 'Pending', 'Completed'].map((filter) {
                final isSelected = _selectedFilter == filter;
                final activeBg = isDark ? AppColors.neonPurple : AppColors.primaryPurple;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? activeBg
                          : (isDark
                              ? AppColors.darkSurfaceVariant
                              : AppColors.lightSurfaceVariant),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
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
          ),
          const SizedBox(height: 16),

          // Task List
          Expanded(
            child: tasksAsync.when(
              data: (tasks) {
                final filteredTasks = tasks.where((t) {
                  if (_selectedFilter == 'Pending') {
                    return t.status == AppConstants.statusPending;
                  }
                  if (_selectedFilter == 'Completed') {
                    return t.status == AppConstants.statusCompleted;
                  }
                  return true;
                }).toList();

                if (filteredTasks.isEmpty) {
                  return EmptyState(
                    icon: Icons.checklist_rounded,
                    title: 'No Tasks Found',
                    message: _selectedFilter == 'All'
                        ? 'Get started by creating your first study task!'
                        : 'No tasks currently in this filter state.',
                    buttonText: _selectedFilter == 'All' ? 'Add Task' : null,
                    onButtonPressed: () => context.push('/tasks/add'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];
                    final subject = subjectsMap[task.subjectId];
                    final isCompleted = task.status == AppConstants.statusCompleted;

                    Color priorityColor;
                    switch (task.priority.toLowerCase()) {
                      case 'high':
                        priorityColor = AppColors.priorityHigh;
                        break;
                      case 'medium':
                        priorityColor = AppColors.priorityMedium;
                        break;
                      default:
                        priorityColor = AppColors.priorityLow;
                    }

                    final dueString = task.dueAt != null
                        ? DateFormat('d MMM, hh:mm a').format(task.dueAt!)
                        : 'No Due Date';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: AppCard(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        onTap: () {
                          ref.read(taskRepositoryProvider).toggleTaskStatus(task.id);
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Custom Rounded Checkbox
                            GestureDetector(
                              onTap: () {
                                ref.read(taskRepositoryProvider).toggleTaskStatus(task.id);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? (isDark ? AppColors.neonPurple : AppColors.primaryPurple)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isCompleted
                                        ? (isDark
                                            ? AppColors.neonPurple
                                            : AppColors.primaryPurple)
                                        : (isDark
                                            ? AppColors.darkBorder
                                            : AppColors.lightBorder),
                                    width: 1.5,
                                  ),
                                ),
                                child: isCompleted
                                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
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
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        subject?.name ?? 'General',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: isDark
                                              ? AppColors.darkTextSecondary
                                              : AppColors.lightTextSecondary,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 6),
                                        child: Text(
                                          '|',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark
                                                ? AppColors.darkTextDisabled
                                                : AppColors.lightTextDisabled,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        task.priority.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: priorityColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    dueString,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark
                                          ? AppColors.darkTextDisabled
                                          : AppColors.lightTextDisabled,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Action popup (delete)
                            PopupMenuButton<String>(
                              icon: Icon(
                                Icons.more_vert_rounded,
                                color: isDark
                                    ? AppColors.darkTextDisabled
                                    : AppColors.lightTextDisabled,
                              ),
                              onSelected: (val) {
                                if (val == 'delete') {
                                  ref.read(taskRepositoryProvider).deleteTask(task.id);
                                }
                              },
                              itemBuilder: (ctx) => [
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline,
                                          color: AppColors.crimsonRed, size: 18),
                                      SizedBox(width: 8),
                                      Text('Delete Task',
                                          style: TextStyle(color: AppColors.crimsonRed)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
