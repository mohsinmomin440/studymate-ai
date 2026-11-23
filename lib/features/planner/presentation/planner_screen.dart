// Planner screen - Display study plans and create new ones

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/notification_utils.dart';
import '../../../core/services/analytics_service.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/shimmer_box.dart';
import '../../chat/data/ai_service.dart' as ai_service;
import '../data/planner_repository.dart';
import '../domain/planner_models.dart';

Future<tz.TZDateTime> _parseReminderTime({
  required DateTime dayDate,
  int defaultHour = 8,
  int defaultMinute = 0,
}) async {
  final firestore = FirebaseFirestore.instance;
  final uid = FirebaseAuth.instance.currentUser?.uid;

  tz.TZDateTime result;
  if (uid == null) {
    result = tz.TZDateTime(tz.local, dayDate.year, dayDate.month, dayDate.day,
        defaultHour, defaultMinute);
  } else {
    result = tz.TZDateTime(tz.local, dayDate.year, dayDate.month, dayDate.day,
        defaultHour, defaultMinute);

    try {
      final doc = await firestore
          .collection(AppConstants.firestoreUsersCollection)
          .doc(uid)
          .get();

      final data = doc.data() ?? {};
      final settings = data['settings'] as Map<String, dynamic>? ?? {};
      final reminderTimeStr = settings['reminderTime'] as String?;

      if (reminderTimeStr != null) {
        final parts = reminderTimeStr.split(':');
        if (parts.length == 2) {
          final hour = int.parse(parts[0]).clamp(0, 23);
          final minute = int.parse(parts[1]).clamp(0, 59);
          result = tz.TZDateTime(
              tz.local, dayDate.year, dayDate.month, dayDate.day, hour, minute);
        }
      }
    } catch (e) {
      // Fall through to default
    }
  }

  return result;
}

class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({super.key});

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen> {
  DateTime? _examDate;
  final List<String> _selectedSubjects = [];
  final TextEditingController _hoursPerDayController =
      TextEditingController(text: '2');
  final List<String> _weakTopics = [];
  bool _isGenerating = false;
  String? _errorMessage;

  final List<String> _allSubjects = AppConstants.subjects;
  final DateTime _now = DateTime.now();

  @override
  void dispose() {
    _hoursPerDayController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _examDate ?? _now.add(const Duration(days: 30)),
      firstDate: _now,
      lastDate: _now.add(const Duration(days: 365)),
      helpText: 'Select exam date',
    );
    if (picked != null && mounted) {
      setState(() => _examDate = picked);
    }
  }

  void _toggleSubject(String subject) {
    setState(() {
      if (_selectedSubjects.contains(subject)) {
        _selectedSubjects.remove(subject);
      } else {
        _selectedSubjects.add(subject);
      }
    });
  }

  void _addWeakTopic() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Weak Topic'),
        content: TextField(
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'e.g., Algebra, Periodic Table',
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              setState(() => _weakTopics.add(value.trim()));
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
        ],
      ),
    );
  }

  void _removeWeakTopic(String topic) {
    setState(() => _weakTopics.remove(topic));
  }

  List<StudyDay> _convertAIdaysToStudyDays(List<ai_service.StudyDay> aiDays) {
    return aiDays.map((day) {
      return StudyDay(
        date: day.date,
        tasks: day.tasks.map((task) {
          return StudyTask(
            title: task.title,
            subject: task.subject,
            estimatedMinutes: task.estimatedMinutes,
            type: task.type,
            done: false,
          );
        }).toList(),
      );
    }).toList();
  }

  Future<void> _generatePlan() async {
    final planDate = _examDate;
    final selectedSubjectList = [..._selectedSubjects];
    final weakTopicList = [..._weakTopics];
    final hoursPerDay = int.parse(_hoursPerDayController.text);

    if (planDate == null || selectedSubjectList.isEmpty) {
      if (!mounted) return;
      setState(() =>
          _errorMessage = 'Please select exam date and at least one subject');
      return;
    }

    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });

    try {
      final aiService = ref.read(ai_service.aiServiceProvider);
      final canUse = await aiService.checkAndIncrementUsage();
      if (!canUse) {
        if (!mounted) return;
        setState(() {
          _isGenerating = false;
          _errorMessage = 'Daily AI limit reached. Try again tomorrow.';
        });
        return;
      }

      final planData = await aiService.generateStudyPlan(
        examDate: planDate,
        subjects: selectedSubjectList,
        hoursPerDay: hoursPerDay,
        weakTopics: weakTopicList,
        language: AppConstants.defaultLocale,
      );

      if (!mounted) return;

      final convertedDays = _convertAIdaysToStudyDays(planData.days);

      final repository = ref.read(plannerRepositoryProvider);
      final planTitle = 'Exam: ${planDate.toLocal().toString().split('.')[0]}';
      final planId = await repository.createPlan(
        title: planTitle,
        examDate: planDate,
        subjects: selectedSubjectList,
        hoursPerDay: hoursPerDay,
        weakTopics: weakTopicList,
        days: convertedDays,
      );

      if (!mounted) return;

      // Log analytics event for study plan generation
      ref.read(analyticsServiceProvider).logStudyPlanGenerated(
            examDate: planDate.toIso8601String().split('.')[0],
            subjectsCount: selectedSubjectList.length,
            daysCount: planData.days.length,
          );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Study plan generated successfully!')),
      );

      context.go('${AppRoutes.planDetail}/$planId');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isGenerating = false;
        _errorMessage = 'Failed to generate plan: ${e.toString()}';
      });
    }
    if (mounted) {
      setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Planner'),
        actions: [
          Semantics(
            label: 'Study Planner Help',
            child: IconButton(
              icon: const Icon(Icons.info_outline_rounded),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const AlertDialog(
                    title: Text('Study Planner Help'),
                    content: Text(
                      '1. Enter your exam date\n'
                      '2. Select subjects you need to study\n'
                      '3. Set daily study hours\n'
                      '4. Add weak topics to prioritize them\n'
                      '5. AI generates a day-by-day plan with spaced repetition\n'
                      '6. Mark tasks as done and reschedule missed ones',
                    ),
                  ),
                );
              },
              tooltip: 'Help',
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          HapticFeedback.lightImpact();
          ref.invalidate(plansStreamProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SectionHeader(title: 'Create Study Plan'),
            const Gap(16),
            _buildPlanForm(),
            const Gap(32),
            const SectionHeader(title: 'My Plans'),
            const Gap(16),
            _buildPlansList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanForm() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Exam Date',
                style: theme.textTheme.titleSmall,
              ),
              const Gap(8),
              Semantics(
                label: 'Exam date',
                child: ListTile(
                  leading: const Icon(Icons.calendar_today_rounded, size: 20),
                  title: Text(
                    _examDate?.toLocal().toString().split('.')[0] ??
                        'Select exam date',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight:
                          _examDate == null ? FontWeight.w400 : FontWeight.w500,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                  onTap: _pickDate,
                ),
              ),
            ],
          ),
        ),
        const Gap(16),
        Text(
          'Subjects to Study',
          style: theme.textTheme.titleSmall,
        ),
        const Gap(8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _allSubjects.map((subject) {
            final isSelected = _selectedSubjects.contains(subject);
            return Semantics(
              label: '$subject, ${isSelected ? "selected" : "not selected"}',
              checked: isSelected,
              child: FilterChip(
                selected: isSelected,
                label: Text(subject),
                onSelected: (selected) {
                  HapticFeedback.lightImpact();
                  _toggleSubject(subject);
                },
              ),
            );
          }).toList(),
        ),
        const Gap(24),
        AppTextField(
          label: 'Hours per Day',
          hint: 'e.g., 2',
          controller: _hoursPerDayController,
          keyboardType: TextInputType.number,
        ),
        const Gap(16),
        Text(
          'Weak Topics (Optional)',
          style: theme.textTheme.titleSmall,
        ),
        const Gap(8),
        if (_weakTopics.isEmpty)
          Text(
            'Add topics you struggle with',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _weakTopics.map((topic) {
              return Chip(
                label: Text(topic),
                deleteIcon: const Icon(Icons.close_rounded, size: 16),
                onDeleted: () {
                  HapticFeedback.lightImpact();
                  _removeWeakTopic(topic);
                },
              );
            }).toList(),
          ),
        Semantics(
          label: 'Add weak topic',
          child: TextButton.icon(
            onPressed: _addWeakTopic,
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Add Weak Topic'),
          ),
        ),
        const Gap(24),
        Semantics(
          label: _isGenerating ? 'Generating plan' : 'Generate study plan',
          child: FilledButton(
            onPressed: _isGenerating ? null : _generatePlan,
            child: _isGenerating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Generate Study Plan'),
          ),
        ),
        if (_errorMessage != null) ...[
          const Gap(16),
          Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red),
          ),
        ],
      ],
    );
  }

  Widget _buildPlansList() {
    return Consumer(builder: (context, ref, _) {
      final plansAsync = ref.watch(plansStreamProvider);

      return plansAsync.when(
        data: (plans) {
          if (plans.isEmpty) {
            return EmptyState(
              icon: Icons.route_rounded,
              title: 'No plans yet',
              message: 'Generate your first study plan above!',
              actionLabel: 'Create Plan',
              onAction: () {},
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];
              return Semantics(
                label:
                    'Plan: ${plan.title}, Exam: ${plan.examDate.toLocal().toString().split('.')[0]}',
                child: GlassCard(
                  onTap: () {
                    context.go('${AppRoutes.planDetail}/${plan.id}');
                  },
                  child: ListTile(
                    title: Text(plan.title),
                    subtitle: Text(
                      'Exam: ${plan.examDate.toLocal().toString().split('.')[0]}',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                  ),
                ),
              );
            },
          );
        },
        loading: () => ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: 3,
          itemBuilder: (context, index) => ShimmerCard(
            height: 100,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        error: (error, stack) => ErrorState(
          title: 'Error Loading Plans',
          message: error.toString(),
          onRetry: () => ref.invalidate(plansStreamProvider),
        ),
      );
    });
  }
}

final plansStreamProvider = StreamProvider.autoDispose<List<StudyPlan>>((ref) {
  final repository = ref.watch(plannerRepositoryProvider);
  return repository.getPlans();
});

// Plan detail screen
class PlanDetailScreen extends ConsumerStatefulWidget {
  final String planId;

  const PlanDetailScreen({super.key, required this.planId});

  @override
  ConsumerState<PlanDetailScreen> createState() => _PlanDetailScreenState();
}

class _PlanDetailScreenState extends ConsumerState<PlanDetailScreen> {
  late StudyPlan? _plan;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  Future<void> _loadPlan() async {
    final repository = ref.read(plannerRepositoryProvider);
    _plan = await repository.getPlan(widget.planId);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_plan == null) {
      return const Scaffold(
        body: Center(child: Text('Plan not found')),
      );
    }

    final plan = _plan!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Plan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            onPressed: () => _markAllDone(plan),
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => _scheduleDailyReminders(plan),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDeletePlan(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            plan.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Gap(8),
          Text(
            'Exam: ${plan.examDate.toLocal().toString().split('.')[0]}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const Gap(16),
          Text(
            'Subjects: ${plan.subjects.join(', ')}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Gap(24),
          ..._buildDaysList(plan),
        ],
      ),
    );
  }

  Future<void> _scheduleDailyReminders(StudyPlan plan) async {
    final notificationService = NotificationService();
    final now = DateTime.now();

    for (final day in plan.days) {
      // Include today OR future days
      if (!day.date.isBefore(now)) {
        // Get reminder time from user settings with fallback to 08:00
        final scheduledDate = await _parseReminderTime(
          dayDate: day.date,
          defaultHour: 8,
          defaultMinute: 0,
        );

        // Use deterministic ID generation (fits in 32-bit)
        final notificationId =
            generateNotificationId(plan.id, day.date, scheduledDate.hour);

        await notificationService.scheduleNotification(
          id: notificationId,
          title: 'Study Session Today',
          body:
              '${day.tasks.where((t) => !t.done).length} tasks waiting. Let\'s get started!',
          scheduledDate: scheduledDate,
        );
      }
    }
  }

  void _confirmDeletePlan() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Plan'),
        content: const Text(
            'Are you sure you want to delete this plan? This will also cancel all scheduled reminders.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePlan();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePlan() async {
    final repository = ref.read(plannerRepositoryProvider);
    await repository.deletePlan(widget.planId);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Plan deleted')),
    );

    context.go(AppRoutes.home);
  }

  List<Widget> _buildDaysList(StudyPlan plan) {
    final days = plan.days;
    if (days.isEmpty) {
      return [
        const Gap(16),
        const Text('No tasks scheduled. Add tasks to your plan.'),
      ];
    }

    return List.generate(days.length, (index) {
      final day = days[index];
      return GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${day.date.toLocal().toString().split('.')[0]} (Day ${index + 1})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const Gap(12),
            ...day.tasks.map((task) => _buildTaskItem(task, day, index)),
          ],
        ),
      );
    });
  }

  Widget _buildTaskItem(StudyTask task, StudyDay day, int dayIndex) {
    final theme = Theme.of(context);
    final repository = ref.read(plannerRepositoryProvider);

    void toggleTask() {
      repository.toggleTask(
        planId: widget.planId,
        dayIndex: dayIndex,
        taskIndex: day.tasks.indexOf(task),
      );
    }

    return Semantics(
      label: task.done
          ? 'Task "${task.title}" completed'
          : 'Task "${task.title}", not completed',
      checked: task.done,
      child: ListTile(
        leading: Checkbox(
          value: task.done,
          onChanged: (_) => toggleTask(),
        ),
        title: Text(
          task.title,
          style: theme.textTheme.bodyLarge?.copyWith(
            decoration: task.done ? TextDecoration.lineThrough : null,
            color: task.done
                ? theme.colorScheme.onSurfaceVariant
                : theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text('${task.subject} • ${task.estimatedMinutes} min'),
        trailing: Chip(
          label: Text(task.type.toUpperCase()),
          visualDensity: VisualDensity.compact,
          backgroundColor: task.type == 'break'
              ? Colors.orange.withValues(alpha: 0.2)
              : theme.colorScheme.primaryContainer,
        ),
        onTap: toggleTask,
      ),
    );
  }

  void _markAllDone(StudyPlan plan) async {
    final repository = ref.read(plannerRepositoryProvider);

    HapticFeedback.mediumImpact();

    for (int dayIndex = 0; dayIndex < plan.days.length; dayIndex++) {
      for (int taskIndex = 0;
          taskIndex < plan.days[dayIndex].tasks.length;
          taskIndex++) {
        await repository.updateTask(
          planId: widget.planId,
          dayIndex: dayIndex,
          taskIndex: taskIndex,
          updatedTask: plan.days[dayIndex].tasks[taskIndex].copyWith(
            done: true,
          ),
        );
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('All tasks marked as done!'),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );
    }
  }
}
