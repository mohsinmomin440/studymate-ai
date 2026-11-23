// Quiz screens - List, Create, Take, Results

import 'dart:async';
import 'dart:developer' as developer;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/shimmer_box.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/analytics_service.dart';
import '../../chat/data/ai_service.dart';
import '../data/quiz_repository.dart';
import '../domain/quiz_models.dart' as quiz_models;
import '../../../core/router/app_router.dart';
import '../../../core/utils/quiz_timer.dart';
import '../../../features/progress/data/progress_repository.dart'
    hide QuizAnswerData, QuizAttempt;

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quizzes'),
        actions: [
          Semantics(
            label: 'Create quiz',
            child: IconButton(
              icon: const Icon(Icons.add_rounded),
              onPressed: () => context.go(AppRoutes.quizCreate),
              tooltip: 'Create quiz',
            ),
          ),
          Semantics(
            label: 'Generate quiz with AI',
            child: IconButton(
              icon: const Icon(Icons.auto_awesome_rounded),
              onPressed: () => _showAiGenerateSheet(),
              tooltip: 'Generate quiz with AI',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppTextField(
              controller: _searchController,
              hint: 'Search quizzes...',
              prefixIcon: Icons.search_rounded,
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(quizRepositoryProvider);
                HapticFeedback.lightImpact();
              },
              child: StreamBuilder<List<quiz_models.Quiz>>(
                stream: ref.watch(quizRepositoryProvider).getQuizzes(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingList();
                  }

                  if (snapshot.hasError) {
                    return _buildErrorState(snapshot.error.toString());
                  }

                  final quizzes = snapshot.data ?? [];

                  if (quizzes.isEmpty) {
                    return _buildEmptyState();
                  }

                  final filteredQuizzes = _searchQuery.isEmpty
                      ? quizzes
                      : quizzes
                          .where((q) => q.title
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()))
                          .toList();

                  if (filteredQuizzes.isEmpty) {
                    return _buildNoResultsState();
                  }

                  return ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredQuizzes.length,
                    itemBuilder: (context, index) {
                      final quiz = filteredQuizzes[index];
                      return _buildQuizCard(quiz);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 6,
      itemBuilder: (context, index) => ShimmerBox(
        height: 100,
        margin: const EdgeInsets.only(bottom: 12),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyState(
      icon: Icons.quiz_rounded,
      title: 'No quizzes yet',
      message: 'Create your first quiz or generate one from AI',
      actionLabel: 'Create Quiz',
      onAction: () => context.go(AppRoutes.quizCreate),
    );
  }

  Widget _buildNoResultsState() {
    return EmptyState(
      icon: Icons.search,
      title: 'No quizzes found',
      message: 'Try a different search term',
    );
  }

  Widget _buildErrorState(String error) {
    return EmptyState(
      icon: Icons.error_outline_rounded,
      title: 'Error Loading Quizzes',
      message: error,
      actionLabel: 'Try Again',
      onAction: () => setState(() => _searchQuery = _searchQuery),
    );
  }

  Widget _buildQuizCard(quiz_models.Quiz quiz) {
    final theme = Theme.of(context);

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => context.go('${AppRoutes.quizDetail}/${quiz.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  quiz.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Gap(8),
          Text(
            '${quiz.subject} • ${quiz.difficulty}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const Gap(4),
          Text(
            '${quiz.questions.length} questions',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  void _showAiGenerateSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AiGenerateQuizSheet(),
    );
  }
}

class AiGenerateQuizSheet extends ConsumerStatefulWidget {
  const AiGenerateQuizSheet({super.key});

  @override
  ConsumerState<AiGenerateQuizSheet> createState() =>
      _AiGenerateQuizSheetState();
}

class _AiGenerateQuizSheetState extends ConsumerState<AiGenerateQuizSheet> {
  final _topicController = TextEditingController();
  String _selectedSubject = 'Mathematics';
  String _selectedDifficulty = 'Medium';
  int _questionCount = 10;
  bool _enableTimer = false;
  int _timerMinutes = 15;

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _generateQuiz() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a topic')),
        );
      }
      return;
    }

    final aiService = ref.read(aiServiceProvider);
    final canUse = await aiService.checkAndIncrementUsage();

    if (!canUse) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Daily AI limit reached. Try again tomorrow or use fewer AI requests.'),
        ),
      );
      return;
    }

    if (mounted) {
      Navigator.of(context).pop();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AiProcessingDialog(
          action: 'Generating quiz',
        ),
      );
    }

    try {
      final questions = await aiService.generateQuiz(
        topic: topic,
        count: _questionCount,
        difficulty: _selectedDifficulty,
        subject: _selectedSubject,
        language: AppConstants.defaultLocale,
      );

      if (!mounted) return;
      Navigator.pop(context);

      final quizId = await ref.read(quizRepositoryProvider).createQuiz(
            title: topic,
            subject: _selectedSubject,
            difficulty: _selectedDifficulty,
            questions: questions,
            durationMinutes: _enableTimer ? _timerMinutes : null,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quiz created successfully!')),
      );

      context.go('${AppRoutes.quizTake}/$quizId');
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(title: 'Generate Quiz'),
          const Gap(16),
          AppTextField(
            controller: _topicController,
            label: 'Topic',
            hint: 'e.g., Algebra, Photosynthesis, World War II',
            textCapitalization: TextCapitalization.words,
          ),
          const Gap(16),
          DropdownButtonFormField<String>(
            initialValue: _selectedSubject,
            decoration: const InputDecoration(
              labelText: 'Subject',
              border: OutlineInputBorder(),
            ),
            items: AppConstants.subjects.map((s) {
              return DropdownMenuItem(value: s, child: Text(s));
            }).toList(),
            onChanged: (v) =>
                setState(() => _selectedSubject = v ?? 'Mathematics'),
          ),
          const Gap(16),
          DropdownButtonFormField<String>(
            initialValue: _selectedDifficulty,
            decoration: const InputDecoration(
              labelText: 'Difficulty',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'Easy', child: Text('Easy')),
              DropdownMenuItem(value: 'Medium', child: Text('Medium')),
              DropdownMenuItem(value: 'Hard', child: Text('Hard')),
            ],
            onChanged: (v) =>
                setState(() => _selectedDifficulty = v ?? 'Medium'),
          ),
          const Gap(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question Count',
                style: theme.textTheme.titleMedium,
              ),
              DropdownButton<int>(
                value: _questionCount,
                items: AppConstants.quizQuestionCounts
                    .map((c) =>
                        DropdownMenuItem(value: c, child: Text('$c questions')))
                    .toList(),
                onChanged: (v) => setState(() => _questionCount = v ?? 10),
              ),
            ],
          ),
          const Gap(16),
          SwitchListTile(
            title: const Text('Enable Timer'),
            subtitle: _enableTimer
                ? Text('$_timerMinutes minutes')
                : const Text('No time limit'),
            value: _enableTimer,
            onChanged: (v) => setState(() => _enableTimer = v),
            contentPadding: EdgeInsets.zero,
          ),
          if (_enableTimer) ...[
            const Gap(8),
            Row(
              children: [
                const Icon(Icons.timer, size: 20),
                const Gap(8),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _timerMinutes,
                    decoration: const InputDecoration(
                      labelText: 'Time Limit',
                      border: OutlineInputBorder(),
                    ),
                    items: [5, 10, 15, 20, 30, 45, 60]
                        .map((m) => DropdownMenuItem(
                              value: m,
                              child: Text('$m minutes'),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _timerMinutes = v ?? 15),
                  ),
                ),
              ],
            ),
          ],
          const Gap(24),
          FilledButton(
            onPressed: _generateQuiz,
            child: const Text('Generate Quiz'),
          ),
          const Gap(16),
        ],
      ),
    );
  }
}

class AiProcessingDialog extends StatelessWidget {
  final String action;

  const AiProcessingDialog({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('$action...'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          CircularProgressIndicator(),
          Gap(16),
          Text('StudyMate AI is working on it...'),
        ],
      ),
    );
  }
}

class QuizCreateScreen extends ConsumerStatefulWidget {
  const QuizCreateScreen({super.key});

  @override
  ConsumerState<QuizCreateScreen> createState() => _QuizCreateScreenState();
}

class _QuizCreateScreenState extends ConsumerState<QuizCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String _selectedSubject = 'Mathematics';
  String _selectedDifficulty = 'Medium';
  int _questionCount = 10;
  bool _enableTimer = false;
  int _timerMinutes = 15;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _createQuiz() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();

    // Generate quiz using AI
    final aiService = ref.read(aiServiceProvider);
    final canUse = await aiService.checkAndIncrementUsage();

    if (!canUse && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Daily AI limit reached. Try again tomorrow or use fewer AI requests.'),
        ),
      );
      return;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AiProcessingDialog(
        action: 'Generating quiz',
      ),
    );

    try {
      final questions = await aiService.generateQuiz(
        topic: title,
        count: _questionCount,
        difficulty: _selectedDifficulty,
        subject: _selectedSubject,
        language: AppConstants.defaultLocale,
      );

      if (!mounted) return;
      Navigator.pop(context);

      final quizId = await ref.read(quizRepositoryProvider).createQuiz(
            title: title,
            subject: _selectedSubject,
            difficulty: _selectedDifficulty,
            questions: questions,
            durationMinutes: _enableTimer ? _timerMinutes : null,
          );

      if (!mounted) return;

      context.go('${AppRoutes.quizTake}/$quizId');
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Quiz')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create a Quiz',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(8),
              Text(
                'AI will generate questions based on your topic',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Gap(24),
              AppTextField(
                controller: _titleController,
                label: 'Quiz Title / Topic',
                hint: 'What topic should the quiz cover?',
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Title required';
                  return null;
                },
              ),
              const Gap(16),
              DropdownButtonFormField<String>(
                initialValue: _selectedSubject,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                ),
                items: AppConstants.subjects.map((s) {
                  return DropdownMenuItem(value: s, child: Text(s));
                }).toList(),
                onChanged: (v) =>
                    setState(() => _selectedSubject = v ?? 'Mathematics'),
              ),
              const Gap(16),
              DropdownButtonFormField<String>(
                initialValue: _selectedDifficulty,
                decoration: const InputDecoration(
                  labelText: 'Difficulty',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Easy', child: Text('Easy')),
                  DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'Hard', child: Text('Hard')),
                ],
                onChanged: (v) =>
                    setState(() => _selectedDifficulty = v ?? 'Medium'),
              ),
              const Gap(16),
              SizedBox(
                height: 200,
                child: ListView(
                  children: [
                    Text(
                      'Question Count',
                      style: theme.textTheme.titleSmall,
                    ),
                    const Gap(8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AppConstants.quizQuestionCounts.map((c) {
                        return FilterChip(
                          selected: _questionCount == c,
                          label: Text('$c'),
                          onSelected: (selected) {
                            setState(() => _questionCount = c);
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const Gap(16),
              SwitchListTile(
                title: const Text('Enable Timer'),
                subtitle: _enableTimer
                    ? Text('$_timerMinutes minutes')
                    : const Text('No time limit'),
                value: _enableTimer,
                onChanged: (v) => setState(() => _enableTimer = v),
                contentPadding: EdgeInsets.zero,
              ),
              if (_enableTimer) ...[
                const Gap(8),
                Row(
                  children: [
                    const Icon(Icons.timer, size: 20),
                    const Gap(8),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _timerMinutes,
                        decoration: const InputDecoration(
                          labelText: 'Time Limit',
                          border: OutlineInputBorder(),
                        ),
                        items: [5, 10, 15, 20, 30, 45, 60]
                            .map((m) => DropdownMenuItem(
                                  value: m,
                                  child: Text('$m minutes'),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _timerMinutes = v ?? 15),
                      ),
                    ),
                  ],
                ),
              ],
              const Gap(32),
              FilledButton(
                onPressed: _createQuiz,
                child: const Text('Generate Quiz'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuizDetailScreen extends ConsumerWidget {
  final String quizId;

  const QuizDetailScreen({super.key, required this.quizId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
        actions: [
          Semantics(
            label: 'Take quiz',
            child: IconButton(
              icon: const Icon(Icons.play_circle_rounded),
              onPressed: () => context.go('${AppRoutes.quizTake}/$quizId'),
              tooltip: 'Take quiz',
            ),
          ),
        ],
      ),
      body: FutureBuilder<quiz_models.Quiz?>(
        future: ref.watch(quizRepositoryProvider).getQuiz(quizId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final quiz = snapshot.data;
          if (quiz == null) {
            return const Center(child: Text('Quiz not found'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                quiz.title,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Gap(8),
              Text(
                '${quiz.subject} • ${quiz.difficulty}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const Gap(16),
              Text(
                '${quiz.questions.length} questions',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Gap(16),
              StreamBuilder<List<quiz_models.QuizAttempt>>(
                stream: ref.watch(quizRepositoryProvider).getAttempts(quizId),
                builder: (context, snapshot) {
                  final attempts = snapshot.data ?? [];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Attempts: ${attempts.length}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Gap(8),
                      if (attempts.isNotEmpty) ...[
                        const SectionHeader(title: 'Recent Attempts'),
                        const Gap(8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: attempts.length,
                          itemBuilder: (context, index) {
                            final attempt = attempts[index];
                            return ListTile(
                              leading: const Icon(Icons.check_circle),
                              title: Text(
                                  'Score: ${attempt.score}/${attempt.total}'),
                              subtitle: Text(
                                '${(attempt.durationSec ~/ 60)}m ${attempt.durationSec % 60}s',
                              ),
                              onTap: () => context.go(
                                  '${AppRoutes.quizResult}/$quizId?attemptId=${attempt.id}'),
                            );
                          },
                        ),
                      ] else ...[
                        const Gap(16),
                        Center(
                          child: FilledButton.icon(
                            onPressed: () =>
                                context.go('${AppRoutes.quizTake}/$quizId'),
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Take Quiz'),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class QuizTakeScreen extends ConsumerStatefulWidget {
  final String quizId;
  final bool isRetry;

  const QuizTakeScreen({
    super.key,
    required this.quizId,
    this.isRetry = false,
  });

  @override
  ConsumerState<QuizTakeScreen> createState() => _QuizTakeScreenState();
}

class _QuizTakeScreenState extends ConsumerState<QuizTakeScreen> {
  quiz_models.Quiz? _quiz;
  int _currentIndex = 0;
  int _selectedAnswer = -1;
  List<int> _answers = [];
  Timer? _uiUpdateTimer;
  late QuizTimer _timer;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    final quiz = await ref.read(quizRepositoryProvider).getQuiz(widget.quizId);
    setState(() {
      _quiz = quiz;
      if (quiz != null) {
        _answers = List.filled(quiz.questions.length, -1);
        _timer = QuizTimer(
          totalSeconds:
              quiz.durationMinutes != null ? quiz.durationMinutes! * 60 : 0,
          // No deadline needed - remainingSeconds will return totalSeconds when no deadline
        );
        _startTimerIfNeeded(quiz);
      }
    });
  }

  void _startTimerIfNeeded(quiz_models.Quiz quiz) {
    if (quiz.durationMinutes == null) return;

    // Create timer with deadline for correct background/foreground behavior
    final totalSeconds = quiz.durationMinutes! * 60;
    final deadline = DateTime.now().add(Duration(seconds: totalSeconds));

    _timer = QuizTimer(
      totalSeconds: totalSeconds,
      deadline: deadline,
    );

    // Periodic UI updates to show countdown
    _uiUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _submitted) {
        _uiUpdateTimer?.cancel();
        return;
      }

      setState(() {
        // Timer automatically calculates remaining through remainingSeconds getter
      });

      if (_timer.isTimeUp()) {
        _onTimeUp();
      }
    });
  }

  void _onTimeUp() {
    if (!mounted || _submitted) return;
    _submitted = true;
    _uiUpdateTimer?.cancel();
    _submitQuiz(autoSubmitted: true);
  }

  @override
  void dispose() {
    _uiUpdateTimer?.cancel();
    super.dispose();
  }

  bool get _isRetry => widget.isRetry;

  void _selectAnswer(int index) {
    HapticFeedback.lightImpact();
    setState(() => _selectedAnswer = index);
  }

  Future<void> _submitQuiz({bool autoSubmitted = false}) async {
    if (_quiz == null) return;

    _uiUpdateTimer?.cancel();

    final correct = _answers
        .where((a) => a == _quiz!.questions[_currentIndex].correctIndex)
        .length;

    final attempt = quiz_models.QuizAttempt(
      id: '',
      quizId: widget.quizId,
      score: correct,
      total: _quiz!.questions.length,
      answers: List.generate(_quiz!.questions.length, (i) {
        final q = _quiz!.questions[i];
        return quiz_models.AnsweredQuestion(
          question: q.question,
          options: q.options,
          selectedIndex: _answers[i],
          correctIndex: q.correctIndex,
          explanation: q.explanation,
        );
      }),
      durationSec: _timer.elapsedSeconds,
      createdAt: DateTime.now(),
    );

    final attemptId =
        await ref.read(quizRepositoryProvider).saveAttempt(attempt);

    // Log analytics event for quiz
    ref.read(analyticsServiceProvider).logQuizFinished(
          quizId: widget.quizId,
          title: _quiz!.title,
          score: correct,
          total: _quiz!.questions.length,
          durationSec: _timer.elapsedSeconds,
        );

    // Award XP for quiz completion (fire-and-forget, never blocks UI)
    // Pass isRetry flag: retry-wrong-only attempts award no XP
    ref
        .read(progressRepositoryProvider)
        .recordActivity('quiz', isRetry: _isRetry)
        .then((_) {})
        .onError((error, stackTrace) {
      developer.log('recordActivity(quiz) error: $error', name: 'QuizScreen');
    });

    if (!mounted) return;
    context.go('${AppRoutes.quizResult}/${widget.quizId}?attemptId=$attemptId');
  }

  @override
  Widget build(BuildContext context) {
    final quiz = _quiz;
    if (quiz == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentIndex >= quiz.questions.length) {
      final correctCount = _answers.where((a) => a >= 0).length;
      return _buildResultScreen(correctCount);
    }

    final question = quiz.questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${_currentIndex + 1}/${quiz.questions.length}'),
        actions: [
          if (_timer.hasTimeLimit)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer, size: 16, color: Colors.red),
                      const Gap(4),
                      Text(
                        _timer.formattedTime,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.question,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Gap(24),
            Expanded(
              child: ListView.builder(
                itemCount: question.options.length,
                itemBuilder: (context, index) {
                  final option = question.options[index];
                  final isSelected = _selectedAnswer == index;
                  return Semantics(
                    label:
                        'Option ${String.fromCharCode(65 + index)}: $option, ${isSelected ? "selected" : "not selected"}',
                    child: GestureDetector(
                      onTap: () => _selectAnswer(index),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _selectedAnswer == index
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _selectedAnswer == index
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: _selectedAnswer == index
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context)
                                      .colorScheme
                                      .outlineVariant,
                              child: _selectedAnswer == index
                                  ? Icon(Icons.check,
                                      size: 20,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary)
                                  : null,
                            ),
                            const Gap(12),
                            Expanded(
                              child: Text(
                                option,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Gap(16),
            ElevatedButton(
              onPressed: _selectedAnswer >= 0 ? _submitQuiz : null,
              child: const Text('Submit Answer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultScreen(int correct) {
    final quiz = _quiz;
    if (quiz == null) return const SizedBox.shrink();

    final score = ((correct / quiz.questions.length) * 100).round();
    final theme = Theme.of(context);

    // Show confetti for good scores
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (score >= 70 && mounted) {
        HapticFeedback.vibrate();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Result')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events,
              size: 80,
              color: score >= 70 ? Colors.amber : Colors.orange,
            ),
            const Gap(24),
            Text(
              '$score%',
              style: theme.textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: score >= 70
                    ? Colors.amber
                    : (score >= 40 ? Colors.orange : Colors.red),
              ),
            ),
            const Gap(16),
            Text(
              '$correct / ${quiz.questions.length} correct',
              style: theme.textTheme.headlineMedium,
            ),
            const Gap(32),
            Semantics(
              label: 'Retry quiz with current questions',
              child: FilledButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _currentIndex = 0;
                    _answers = List.filled(quiz.questions.length, -1);
                  });
                },
                child: const Text('Retry Quiz'),
              ),
            ),
            const Gap(12),
            Semantics(
              label: 'Back to quizzes list',
              child: OutlinedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop();
                },
                child: const Text('Back to Quizzes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuizResultScreen extends ConsumerStatefulWidget {
  final String quizId;
  final String? attemptId;

  const QuizResultScreen({super.key, required this.quizId, this.attemptId});

  @override
  ConsumerState<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends ConsumerState<QuizResultScreen> {
  late final ConfettiController _confettiController;
  bool _playedConfetti = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_QuizResultData?>(
      future: _getResultData(ref),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data;
        if (data == null) {
          return const Center(child: Text('Result not found'));
        }

        final attempt = data.attempt;
        final quiz = data.quiz;

        final score = ((attempt.score / attempt.total) * 100).round();
        final theme = Theme.of(context);

        // Show confetti if score >= 70%
        if (score >= 70 && !_playedConfetti) {
          _playedConfetti = true;
          _confettiController.play();
        }

        // Get wrong answers for retry
        final wrongAnswers = attempt.answers.where((a) {
          return a.selectedIndex != a.correctIndex;
        }).toList();

        return Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: Icon(
                    Icons.emoji_events,
                    size: 80,
                    color: score >= 70 ? Colors.amber : Colors.orange,
                  ),
                ),
                const Gap(24),
                Center(
                  child: Text(
                    '$score%',
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: score >= 70
                          ? Colors.amber
                          : (score >= 40 ? Colors.orange : Colors.red),
                    ),
                  ),
                ),
                const Gap(16),
                Center(
                  child: Text(
                    '${attempt.score} / ${attempt.total} correct',
                    style: theme.textTheme.headlineMedium,
                  ),
                ),
                const Gap(32),
                const SectionHeader(title: 'Detailed Results'),
                const Gap(16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: attempt.answers.length,
                  itemBuilder: (context, index) {
                    final answer = attempt.answers[index];
                    return GlassCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            answer.question,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Gap(8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: answer.options.map((option) {
                              final isSelected = option ==
                                  answer.options[answer.selectedIndex];
                              final isCorrectAnswer =
                                  option == answer.options[answer.correctIndex];
                              return Row(
                                children: [
                                  Icon(
                                    isCorrectAnswer
                                        ? Icons.check_circle
                                        : Icons.check_circle_outline,
                                    color: isCorrectAnswer
                                        ? Colors.green
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const Gap(8),
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: TextStyle(
                                        color: isCorrectAnswer
                                            ? Colors.green
                                            : (isSelected
                                                ? theme.colorScheme.primary
                                                : null),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                          const Gap(16),
                          Text(
                            'Explanation: ${answer.explanation}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const Gap(16),
                if (wrongAnswers.isNotEmpty) ...[
                  FilledButton(
                    onPressed: () => _retryWrongQuestions(
                      context,
                      ref,
                      widget.quizId,
                      wrongAnswers,
                      quiz,
                    ),
                    child: const Text('Retry Wrong Questions Only'),
                  ),
                  const Gap(8),
                ],
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Back to Quizzes'),
                ),
              ],
            ),
            ConfettiWidget(
              confettiController: _confettiController,
              numberOfParticles: 50,
              colors: const [
                Colors.amber,
                Colors.blue,
                Colors.purple,
                Colors.green,
                Colors.pink,
              ],
            ),
          ],
        );
      },
    );
  }

  Future<_QuizResultData?> _getResultData(WidgetRef ref) async {
    final quiz = await ref.watch(quizRepositoryProvider).getQuiz(widget.quizId);
    final attempt = await _getAttempt(widget.quizId, ref);
    if (attempt == null || quiz == null) return null;
    return _QuizResultData(quiz: quiz, attempt: attempt);
  }

  void _retryWrongQuestions(
    BuildContext context,
    WidgetRef ref,
    String quizId,
    List<quiz_models.AnsweredQuestion> wrongAnswers,
    quiz_models.Quiz originalQuiz,
  ) {
    final quizRepository = ref.read(quizRepositoryProvider);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AiProcessingDialog(
        action: 'Preparing retry',
      ),
    );

    Future.microtask(() async {
      try {
        // Fetch the original quiz to get subject and difficulty
        final quiz = await quizRepository.getQuiz(quizId);
        if (quiz == null) {
          if (context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Quiz not found')),
            );
          }
          return;
        }

        // Create a new quiz with only wrong answers
        final newQuizId = await quizRepository.createQuiz(
          title: 'Retry: ${quiz.title}',
          subject: quiz.subject,
          difficulty: quiz.difficulty,
          questions: wrongAnswers
              .map((a) => {
                    'question': a.question,
                    'options': a.options,
                    'correctIndex': a.correctIndex,
                    'explanation': a.explanation,
                  })
              .toList(),
        );

        if (!context.mounted) return;
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '${wrongAnswers.length} wrong questions will appear in the quiz.')),
        );

        GoRouter.of(context)
            .go('${AppRoutes.quizTake}/$newQuizId?isRetry=true');
      } catch (e) {
        if (!context.mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to retry: ${e.toString()}')),
        );
      }
    });
  }

  Future<quiz_models.QuizAttempt?> _getAttempt(
      String quizId, WidgetRef ref) async {
    final attempts =
        await ref.watch(quizRepositoryProvider).getAllAttempts().first;
    if (widget.attemptId == null) {
      final quizAttempts = attempts.where((a) => a.quizId == quizId).toList();
      return quizAttempts.isNotEmpty ? quizAttempts.first : null;
    }
    final attempt = attempts.firstWhere(
      (a) => a.id == widget.attemptId,
      orElse: () => throw Exception('Attempt not found'),
    );
    return attempt;
  }
}

/// Helper class for quiz result data
class _QuizResultData {
  final quiz_models.Quiz quiz;
  final quiz_models.QuizAttempt attempt;

  _QuizResultData({required this.quiz, required this.attempt});
}
