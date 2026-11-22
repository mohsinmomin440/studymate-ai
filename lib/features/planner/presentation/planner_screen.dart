// Planner screen - Display study plans and create new ones

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/app_text_field.dart';

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

  Future<void> _generatePlan() async {
    if (_examDate == null || _selectedSubjects.isEmpty) {
      setState(() =>
          _errorMessage = 'Please select exam date and at least one subject');
      return;
    }

    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text(
              'Study plan generation coming soon! AI integration pending.')),
    );

    if (mounted) {
      setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Planner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
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
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader(title: 'Create Study Plan'),
          const Gap(16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Exam Date',
                  style: theme.textTheme.titleSmall,
                ),
                const Gap(8),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(_examDate?.toLocal().toString().split('.')[0] ??
                      'Select exam date'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _pickDate,
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
              return FilterChip(
                selected: isSelected,
                label: Text(subject),
                onSelected: (selected) => _toggleSubject(subject),
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
                  deleteIcon: const Icon(Icons.close),
                  onDeleted: () => _removeWeakTopic(topic),
                );
              }).toList(),
            ),
          TextButton.icon(
            onPressed: _addWeakTopic,
            icon: const Icon(Icons.add),
            label: const Text('Add Weak Topic'),
          ),
          const Gap(24),
          FilledButton(
            onPressed: _isGenerating ? null : _generatePlan,
            child: _isGenerating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Generate Study Plan'),
          ),
          if (_errorMessage != null) ...[
            const Gap(16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ],
          const Gap(32),
          const SectionHeader(title: 'My Plans'),
          const Gap(16),
        ],
      ),
    );
  }
}

// Plan detail screen
class PlanDetailScreen extends StatelessWidget {
  final String planId;

  const PlanDetailScreen({super.key, required this.planId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Plan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            child: Column(
              children: [
                Text(
                  'Day 1 - Jan 15, 2026',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(16),
                _buildTaskItem(
                  context: context,
                  title: 'Mathematics - Algebra Basics',
                  duration: 60,
                  subject: 'Mathematics',
                  type: 'study',
                  done: false,
                ),
                const Gap(12),
                _buildTaskItem(
                  context: context,
                  title: 'Review - Flashcards',
                  duration: 25,
                  subject: 'Mathematics',
                  type: 'review',
                  done: false,
                ),
                const Gap(12),
                _buildTaskItem(
                  context: context,
                  title: 'Break',
                  duration: 15,
                  subject: 'Break',
                  type: 'break',
                  done: false,
                ),
              ],
            ),
          ),
          const Gap(16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Day 2 - Jan 16, 2026',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(16),
                _buildTaskItem(
                  context: context,
                  title: 'Physics - Mechanics',
                  duration: 90,
                  subject: 'Physics',
                  type: 'study',
                  done: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem({
    required BuildContext context,
    required String title,
    required int duration,
    required String subject,
    required String type,
    required bool done,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Checkbox(
        value: done,
        onChanged: (value) {},
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          decoration: done ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Text('$subject • $type'),
      trailing: Chip(
        label: Text('$duration min'),
        visualDensity: VisualDensity.compact,
      ),
      onTap: () {},
    );
  }
}
