import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../services/ai_service.dart';

class QuizScreen extends StatefulWidget {
  final String? topic;
  const QuizScreen({super.key, this.topic});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int? _selectedOptionIndex;
  int _score = 0;
  List<QuizQuestion> _questions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final topic = widget.topic?.trim().isNotEmpty == true
        ? widget.topic!.trim()
        : 'Data Structures and Algorithms';
    final list = await AiService.generateQuiz(topic);
    if (!mounted) return;
    setState(() {
      _questions = list;
      _isLoading = false;
      _currentIndex = 0;
      _selectedOptionIndex = null;
    });
  }

  void _onNext() {
    if (_selectedOptionIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an option')),
      );
      return;
    }

    if (_selectedOptionIndex == _questions[_currentIndex].correctOptionIndex) {
      _score++;
    }

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOptionIndex = null;
      });
    } else {
      // Completed, navigate to result
      context.pushReplacement(
        '/quiz/result',
        extra: {
          'score': _score,
          'total': _questions.length,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.neonPurple : AppColors.primaryPurple;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final question = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Quiz'),
            Text(
              widget.topic?.isNotEmpty == true ? widget.topic! : 'Data Structures',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question Counter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_currentIndex + 1} / ${_questions.length}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: isDark
                      ? AppColors.darkSurfaceVariant
                      : AppColors.lightSurfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              ),
              const SizedBox(height: 32),

              // Question Text
              Text(
                question.question,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  height: 1.4,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 28),

              // Option Cards
              Expanded(
                child: ListView.builder(
                  itemCount: question.options.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedOptionIndex == index;

                    Color cardBorderColor;
                    Color cardBgColor;

                    if (isSelected) {
                      cardBorderColor = primaryColor;
                      cardBgColor = isDark
                          ? primaryColor.withOpacity(0.12)
                          : primaryColor.withOpacity(0.08);
                    } else {
                      cardBorderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
                      cardBgColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: AppCard(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        color: cardBgColor,
                        border: Border.all(color: cardBorderColor, width: isSelected ? 2 : 1),
                        onTap: () {
                          setState(() {
                            _selectedOptionIndex = index;
                          });
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? primaryColor : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? primaryColor
                                      : (isDark
                                          ? AppColors.darkBorder
                                          : AppColors.lightBorder),
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                question.options[index],
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? (isDark
                                          ? AppColors.darkSuccessText
                                          : AppColors.lightSuccessText)
                                      : (isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.lightTextPrimary),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Next Button
              CustomButton(
                text: _currentIndex == _questions.length - 1 ? 'Finish Quiz' : 'Next',
                onPressed: _onNext,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
