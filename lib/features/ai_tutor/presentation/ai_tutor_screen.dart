import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../services/ai_service.dart';

class AiTutorScreen extends StatefulWidget {
  const AiTutorScreen({super.key});

  @override
  State<AiTutorScreen> createState() => _AiTutorScreenState();
}

class _AiTutorScreenState extends State<AiTutorScreen> {
  int _selectedTabIndex = 0; // 0: Summarize, 1: Quiz, 2: Ask AI
  final _textController = TextEditingController(
    text: 'A Queue is a linear data structure that follows the First In First Out (FIFO) principle. '
        'The element inserted first is the one to be removed first. Operations include enqueue, dequeue, peek, and isEmpty.',
  );
  bool _isLoading = false;
  AiSummaryResult? _summaryResult;
  String? _askAiAnswer;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedTabIndex = index;
      _summaryResult = null;
      _askAiAnswer = null;
    });
  }

  Future<void> _handleGenerate() async {
    final input = _textController.text.trim();
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your text or question first.')),
      );
      return;
    }

    if (_selectedTabIndex == 1) {
      // Quiz Generation
      context.push('/quiz', extra: {'topic': input});
      return;
    }

    if (_selectedTabIndex == 2) {
      // Ask AI
      setState(() {
        _isLoading = true;
        _askAiAnswer = null;
      });

      try {
        final answer = await AiService.askAi(input);
        setState(() {
          _askAiAnswer = answer;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('AI Tutor error: $e')),
          );
        }
      }
      return;
    }

    // Summarize Generation (Tab 0)
    setState(() {
      _isLoading = true;
      _summaryResult = null;
    });

    try {
      final res = await AiService.generateSummary(input);
      setState(() {
        _summaryResult = res;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating summary: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.neonPurple : AppColors.primaryPurple;

    String sectionTitle;
    String sectionSubtitle;
    String hintText;
    String buttonText;

    if (_selectedTabIndex == 0) {
      sectionTitle = 'Upload or Paste Study Material';
      sectionSubtitle = 'Paste lecture notes or textbook material to generate instant AI summary.';
      hintText = 'Paste your study material here...';
      buttonText = 'Generate AI Summary';
    } else if (_selectedTabIndex == 1) {
      sectionTitle = 'Practice Quiz Topic';
      sectionSubtitle = 'Enter any subject, chapter, or topic to generate a 5-question test.';
      hintText = 'e.g. Operating Systems Paging, DBMS SQL Queries, Java OOP...';
      buttonText = 'Start Quiz Practice';
    } else {
      sectionTitle = 'Ask AI Tutor Any Question';
      sectionSubtitle = 'Get clear conceptual explanations, code snippets, and study guidance.';
      hintText = 'Type your doubt or question here...';
      buttonText = 'Ask Gemini AI';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Tutor'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Segmented Tabs (Summarize, Quiz, Ask AI)
              Row(
                children: ['Summarize', 'Quiz', 'Ask AI'].asMap().entries.map((entry) {
                  final idx = entry.key;
                  final title = entry.value;
                  final isSelected = _selectedTabIndex == idx;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _onTabChanged(idx),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryColor
                              : (isDark
                                  ? AppColors.darkSurfaceVariant
                                  : AppColors.lightSurfaceVariant),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            title,
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

              // Section Header
              Text(
                sectionTitle,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                sectionSubtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 14),

              // Text Area
              TextFormField(
                controller: _textController,
                maxLines: _selectedTabIndex == 1 ? 2 : 5,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                ),
              ),
              const SizedBox(height: 20),

              // Action Button
              CustomButton(
                text: buttonText,
                isLoading: _isLoading,
                onPressed: _handleGenerate,
              ),
              const SizedBox(height: 24),

              // Ask AI Output Display
              if (_askAiAnswer != null) ...[
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'AI Tutor Response',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AppCard(
                  padding: const EdgeInsets.all(18),
                  child: SelectableText(
                    _askAiAnswer!,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Generated Summary Output Display
              if (_summaryResult != null) ...[
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Generated Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AppCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _summaryResult!.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _summaryResult!.overview,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      const Divider(height: 24),
                      Text(
                        'Key Takeaways:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._summaryResult!.keyPoints.map(
                        (pt) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.arrow_right_rounded, color: primaryColor, size: 20),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  pt,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_summaryResult!.examTips.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.neonPurple.withOpacity(0.12)
                                : AppColors.primaryPurple.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.lightbulb_outline_rounded, color: primaryColor, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Exam Tips:',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? AppColors.neonPurple : AppColors.primaryPurple,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    ..._summaryResult!.examTips.map(
                                      (tip) => Padding(
                                        padding: const EdgeInsets.only(bottom: 2),
                                        child: Text(
                                          '• $tip',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: isDark ? AppColors.neonPurple : AppColors.primaryPurple,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
