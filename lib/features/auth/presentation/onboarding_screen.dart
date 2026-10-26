import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/custom_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  final List<Map<String, dynamic>> _pages = [
    {
      'titleLight': 'Plan Smarter\nStudy Better',
      'titleDark': 'Your AI Study\nCompanion',
      'subtitleLight':
          'AI-powered study plans, personalized schedules, quizzes and progress tracking - all in one place.',
      'subtitleDark':
          'Plan smarter, learn better, achieve more with AI.',
      'icon': Icons.auto_stories_rounded,
    },
    {
      'titleLight': 'Rule-Based\nSmart Planner',
      'titleDark': 'Intelligent\nDaily Scheduling',
      'subtitleLight':
          'Automated daily and weekly study schedules tailored to your upcoming exam dates and target hours.',
      'subtitleDark':
          'Adaptive scheduling based on exam deadlines, task difficulty, and available study hours.',
      'icon': Icons.event_note_rounded,
    },
    {
      'titleLight': 'Instant Summaries\n& Practice Quizzes',
      'titleDark': 'AI Summaries\n& Quiz Generator',
      'subtitleLight':
          'Upload notes or paste text to generate quick revisions, flashcards, and multiple-choice practice tests.',
      'subtitleDark':
          'Reinforce your concepts with AI-assisted question sets and detailed performance reviews.',
      'icon': Icons.psychology_rounded,
    },
    {
      'titleLight': 'Track Performance\n& Master Exams',
      'titleDark': 'Deep Analytics\n& Exam Readiness',
      'subtitleLight':
          'Visual progress indicators, weekly study hours bar charts, and subject completion targets.',
      'subtitleDark':
          'Monitor study consistency, task completion rates, and subject-wise exam readiness.',
      'icon': Icons.insights_rounded,
    },
  ];

  Future<void> _completeOnboarding({required bool toLogin}) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(AppConstants.hasSeenOnboardingKey, true);
    if (!mounted) return;
    if (toLogin) {
      context.go('/login');
    } else {
      context.go('/signup');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => _completeOnboarding(toLogin: true),
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final item = _pages[index];
                    final title = isDark ? item['titleDark'] : item['titleLight'];
                    final subtitle = isDark ? item['subtitleDark'] : item['subtitleLight'];
                    final icon = item['icon'] as IconData;

                    return Center(
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Showcase circular decorative illustration
                            Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark
                                    ? AppColors.neonPurple.withOpacity(0.12)
                                    : AppColors.primaryPurple.withOpacity(0.08),
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.neonPurple.withOpacity(0.3)
                                      : AppColors.primaryPurple.withOpacity(0.15),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark
                                        ? AppColors.neonPurple.withOpacity(0.2)
                                        : AppColors.primaryPurple.withOpacity(0.08),
                                    blurRadius: 30,
                                    spreadRadius: 6,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  icon,
                                  size: 76,
                                  color: isDark ? AppColors.neonPurple : AppColors.primaryPurple,
                                ),
                              ),
                            ),
                            const SizedBox(height: 36),
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                height: 1.25,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                subtitle,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  height: 1.5,
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
              // Dots Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? (isDark ? AppColors.neonPurple : AppColors.primaryPurple)
                          : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Get Started Button
              CustomButton(
                text: _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                onPressed: () {
                  if (_currentPage < _pages.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    _completeOnboarding(toLogin: false);
                  }
                },
              ),
              const SizedBox(height: 16),
              // Already have an account? Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _completeOnboarding(toLogin: true),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.neonPurple : AppColors.primaryPurple,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
