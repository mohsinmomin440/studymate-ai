import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../subjects/data/subject_repository.dart';
import '../data/task_repository.dart';
import '../domain/task.dart';

class AddTaskScreen extends ConsumerStatefulWidget {
  const AddTaskScreen({super.key});

  @override
  ConsumerState<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends ConsumerState<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  String? _selectedSubjectId;
  String _selectedPriority = AppConstants.priorityHigh;
  int _estimatedMinutes = 60;
  DateTime? _dueDate;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 11, minute: 0),
      );
      setState(() {
        if (pickedTime != null) {
          _dueDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        } else {
          _dueDate = pickedDate;
        }
      });
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSubjectId == null || _selectedSubjectId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a subject for this task')),
      );
      return;
    }

    final task = TaskItem(
      id: '',
      title: _titleController.text.trim(),
      subjectId: _selectedSubjectId!,
      priority: _selectedPriority,
      difficulty: _selectedPriority == 'high' ? 4 : (_selectedPriority == 'medium' ? 3 : 2),
      estimatedMinutes: _estimatedMinutes,
      dueAt: _dueDate,
      status: AppConstants.statusPending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await ref.read(taskRepositoryProvider).addTask(task);
    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subjectsAsync = ref.watch(subjectsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Task Title
                CustomTextField(
                  controller: _titleController,
                  labelText: 'Task Title',
                  hintText: 'e.g. Revise Linked Lists',
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter task title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Subject Dropdown
                Text(
                  'Subject',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                subjectsAsync.when(
                  data: (subjects) {
                    if (subjects.isNotEmpty && _selectedSubjectId == null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        setState(() {
                          _selectedSubjectId = subjects.first.id;
                        });
                      });
                    }
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedSubjectId,
                          isExpanded: true,
                          dropdownColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                          hint: Text(
                            'Select Subject',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.darkTextDisabled
                                  : AppColors.lightTextDisabled,
                            ),
                          ),
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
                          onChanged: (val) {
                            setState(() {
                              _selectedSubjectId = val;
                            });
                          },
                        ),
                      ),
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (_, _) => const Text('Error loading subjects'),
                ),
                const SizedBox(height: 24),

                // Priority Pills (Low, Medium, High)
                Text(
                  'Priority',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    AppConstants.priorityLow,
                    AppConstants.priorityMedium,
                    AppConstants.priorityHigh,
                  ].map((priority) {
                    final isSelected = _selectedPriority == priority;
                    final activeColor = isDark ? AppColors.neonPurple : AppColors.primaryPurple;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPriority = priority;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? activeColor
                                : (isDark
                                    ? AppColors.darkSurfaceVariant
                                    : AppColors.lightSurfaceVariant),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? activeColor
                                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              priority.toUpperCase(),
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
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Estimated Time
                Text(
                  'Estimated Time',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline_rounded),
                        onPressed: () {
                          if (_estimatedMinutes > 15) {
                            setState(() {
                              _estimatedMinutes -= 15;
                            });
                          }
                        },
                      ),
                      Text(
                        '$_estimatedMinutes minutes',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        onPressed: () {
                          setState(() {
                            _estimatedMinutes += 15;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Due Date
                Text(
                  'Due Date',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: _pickDueDate,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 20,
                          color: isDark ? AppColors.neonPurple : AppColors.primaryPurple,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _dueDate != null
                              ? DateFormat('d MMM yyyy, hh:mm a').format(_dueDate!)
                              : 'Select Due Date',
                          style: TextStyle(
                            fontSize: 15,
                            color: _dueDate != null
                                ? (isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary)
                                : (isDark
                                    ? AppColors.darkTextDisabled
                                    : AppColors.lightTextDisabled),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_drop_down_rounded,
                          color: isDark ? AppColors.darkTextDisabled : AppColors.lightTextDisabled,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                // Save Button
                CustomButton(
                  text: 'Save',
                  onPressed: _saveTask,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
