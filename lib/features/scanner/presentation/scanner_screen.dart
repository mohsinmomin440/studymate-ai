// Doubt Scanner Screen - Camera/Gallery to solve math/scientific problems

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/errors/failures.dart';
import '../../chat/data/ai_service.dart';
import '../data/scanner_repository.dart';
import '../../flashcards/data/flashcard_repository.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  XFile? _selectedImage;
  String? _solution;
  String _selectedSubject = 'Mathematics';
  bool _isProcessing = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doubt Scanner'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionHeader(title: 'How it works'),
            const Gap(8),
            Text(
              'Take a photo or select an image of your question. '
              'StudyMate AI will analyze it and provide a step-by-step solution.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Gap(24),
            const SectionHeader(title: 'Select Subject'),
            const Gap(8),
            _buildSubjectDropdown(),
            const Gap(24),
            const SectionHeader(title: 'Select Image'),
            const Gap(8),
            _buildImageSelector(),
            if (_selectedImage != null) ...[
              const Gap(16),
              _buildImagePreview(),
              const Gap(16),
              _buildProcessButton(),
              const Gap(24),
              if (_isProcessing) ...[
                const Gap(8),
                const Center(child: CircularProgressIndicator()),
              ],
              if (_solution != null) _buildSolutionCard(),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildSubjectDropdown() {
    final subjects = [
      'Mathematics',
      'Physics',
      'Chemistry',
      'Biology',
      'English',
      'Gujarati',
      'Hindi',
      'Social Science',
      'Computer Science',
    ];

    return GlassCard(
      child: DropdownButtonFormField<String>(
        initialValue: _selectedSubject,
        items: subjects
            .map((subject) => DropdownMenuItem(
                  value: subject,
                  child: Text(subject),
                ))
            .toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() => _selectedSubject = value);
          }
        },
        decoration: InputDecoration(
          labelText: 'Select Subject',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withValues(alpha: 0.5),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildImageSelector() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.camera_alt_rounded, size: 20),
            label: const Text('Camera'),
            onPressed: () => _pickImageFromCamera(),
          ),
        ),
        const Gap(12),
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.photo_library_rounded, size: 20),
            label: const Text('Gallery'),
            onPressed: () => _pickImageFromGallery(),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selected Image:',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const Gap(8),
        SizedBox(
          height: 200,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              File(_selectedImage!.path),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessButton() {
    return OutlinedButton.icon(
      icon: const Icon(Icons.code_rounded, size: 20),
      label: const Text('Solve Question'),
      onPressed: _isProcessing ? null : _processImage,
    );
  }

  Widget _buildSolutionCard() {
    if (_solution == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Solution'),
        const Gap(8),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _solution!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Gap(16),
              Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save_rounded, size: 20),
                    label: const Text('Save'),
                    onPressed: () => _saveSolution(),
                  ),
                  const Gap(12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.note_add_rounded, size: 20),
                    label: const Text('Create Note'),
                    onPressed: () => _createNoteFromSolution(),
                  ),
                  const Gap(12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.auto_awesome_rounded, size: 20),
                    label: const Text('AI Flashcards'),
                    onPressed: () => _generateFlashcards(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickImageFromCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission required')),
        );
      }
      return;
    }

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxHeight: 1080,
        maxWidth: 1080,
      );

      if (image != null) {
        setState(() => _selectedImage = image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    final status = await Permission.photos.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo library permission required')),
        );
      }
      return;
    }

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxHeight: 1080,
        maxWidth: 1080,
      );

      if (image != null) {
        setState(() => _selectedImage = image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _processImage() async {
    if (_selectedImage == null) return;

    final canUse = await ref.read(aiServiceProvider).checkAndIncrementUsage();
    if (!canUse) {
      if (!mounted) return;
      _showErrorDialog(
        title: 'Daily limit reached',
        message:
            'You\'ve used your daily AI quota. Try again tomorrow or use fewer AI requests.',
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final solution = await _analyzeImageWithAI();

      if (!mounted) return;
      setState(() => _solution = solution);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);

      final failure = AIFailure.fromException(e);
      _showAiErrorDialog(failure);
    }
    if (mounted) {
      setState(() => _isProcessing = false);
    }
  }

  void _showAiErrorDialog(Failure failure) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Something went wrong'),
        content: Text(failure.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          if (failure is AIFailure) ...[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _processImage();
              },
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }

  void _showErrorDialog({
    required String title,
    required String message,
    required List<Widget> actions,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: actions,
      ),
    );
  }

  Future<String> _analyzeImageWithAI() async {
    final aiService = ref.read(aiServiceProvider);

    final result = await aiService.analyzeImageWithText(
      imagePath: _selectedImage!.path,
      subject: _selectedSubject,
      question: 'Analyze this image and provide a step-by-step solution',
    );
    return result;
  }

  Future<void> _saveSolution() async {
    if (_solution == null || _selectedImage == null) return;

    try {
      await ref.read(scannerRepositoryProvider).saveDoubt(
            question: 'Question from image',
            answer: _solution!,
            subject: _selectedSubject,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solution saved to doubts')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    }
  }

  void _createNoteFromSolution() {
    if (_solution == null) return;
    // Navigate to note creation screen with pre-filled content
    if (mounted) {
      context.go(AppRoutes.notesCreate);
    }
  }

  Future<void> _generateFlashcards() async {
    if (_solution == null) return;

    final canUse = await ref.read(aiServiceProvider).checkAndIncrementUsage();
    if (!canUse) {
      if (!mounted) return;
      _showErrorDialog(
        title: 'Daily limit reached',
        message:
            'You\'ve used your daily AI quota. Try again tomorrow or use fewer AI requests.',
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      );
      return;
    }

    try {
      final aiFlashcardData =
          await ref.read(aiServiceProvider).generateFlashcardsFromNote(
                noteText: _solution!,
                count: 5,
                subject: _selectedSubject,
                language: AppConstants.defaultLocale,
              );

      if (!mounted) return;

      final repository = ref.read(flashcardRepositoryProvider);

      // Create deck first
      final deckTitle = 'Doubt: $_selectedSubject';
      final deckId = await repository.createDeck(
        title: deckTitle,
        subject: _selectedSubject,
        initialCards: null,
      );

      // Create cards from AI data
      final cardsData = aiFlashcardData
          .map((f) => {'front': f.front, 'back': f.back})
          .toList();

      await repository.createCardsFromData(
        deckId: deckId,
        cardsData: cardsData,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generated flashcards successfully!')),
      );

      context.go('${AppRoutes.flashcardsEdit}/$deckId');
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog(
        title: 'Failed to generate flashcards',
        message: e.toString(),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      );
    }
  }
}
