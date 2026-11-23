// Notes Screen - List and manage notes

library;

import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_ai/firebase_ai.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/shimmer_box.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/analytics_service.dart';
import '../../chat/data/ai_service.dart';
import '../data/note_repository.dart';
import '../domain/note_models.dart';
import '../../../core/router/app_router.dart';
import '../../../features/progress/data/progress_repository.dart';
import '../../../core/utils/extensions.dart';

/// AI actions available for notes
enum AiAction { summarize, keyPoints, translate, flashcards, quiz, simplify }

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notesTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.go(AppRoutes.notesCreate),
            tooltip: l10n.createNoteTooltip,
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppTextField(
              controller: _searchController,
              hint: l10n.searchNotesHint,
              prefixIcon: Icons.search_rounded,
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                // The stream will automatically refresh when data changes
              },
              child: StreamBuilder<List<NoteModel>>(
                stream: _searchQuery.isEmpty
                    ? ref.watch(noteRepositoryProvider).getNotes()
                    : ref
                        .watch(noteRepositoryProvider)
                        .searchNotes(_searchQuery),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingList();
                  }

                  if (snapshot.hasError) {
                    return ErrorState(
                      title: l10n.errorLoadingNotes,
                      message: snapshot.error.toString(),
                      onRetry: () =>
                          setState(() => _searchQuery = _searchQuery),
                    );
                  }

                  final notes = snapshot.data ?? [];

                  if (notes.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  return ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return _buildNoteCard(note);
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

  Widget _buildEmptyState(BuildContext context) {
    final l10n = context.l10n;
    return EmptyState(
      svgAsset: 'assets/svg/study_book.svg',
      icon: Icons.note_add_rounded,
      title: l10n.noNotesYetTitle,
      message: l10n.createFirstNoteMessage,
      actionLabel: l10n.createNoteAction,
      onAction: () => context.go(AppRoutes.notesCreate),
    );
  }

  Widget _buildNoteCard(NoteModel note) {
    final theme = Theme.of(context);

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => context.go('${AppRoutes.noteDetail}/$note.id'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  note.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (note.pinned)
                const Icon(Icons.push_pin_rounded,
                    color: Color(0xFF00D4C8), size: 20),
            ],
          ),
          const Gap(8),
          Text(
            note.body.length > 150
                ? '${note.body.substring(0, 150)}...'
                : note.body,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const Gap(8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: note.tags.take(5).map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  tag,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }
}

class CreateEditNoteScreen extends ConsumerStatefulWidget {
  final String? noteId;

  const CreateEditNoteScreen({super.key, this.noteId});

  @override
  ConsumerState<CreateEditNoteScreen> createState() =>
      _CreateEditNoteScreenState();
}

class _CreateEditNoteScreenState extends ConsumerState<CreateEditNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _subjectController = TextEditingController();
  final _tagsController = TextEditingController();
  bool _isEditing = false;
  NoteModel? _existingNote;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.noteId != null;
    if (_isEditing) {
      _loadExistingNote();
    }
  }

  Future<void> _loadExistingNote() async {
    final note = await ref.read(noteRepositoryProvider).getNote(widget.noteId!);
    if (note != null) {
      setState(() => _existingNote = note);
      _titleController.text = note.title;
      _bodyController.text = note.body;
      _subjectController.text = note.subject;
      _tagsController.text = note.tags.join(', ');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _subjectController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    final subject = _subjectController.text.trim();
    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final now = DateTime.now();

    if (_isEditing && _existingNote != null) {
      final updatedNote = _existingNote!.copyWith(
        title: title,
        body: body,
        subject: subject,
        tags: tags,
        updatedAt: now,
      );
      await ref.read(noteRepositoryProvider).updateNote(updatedNote);
    } else {
      final newNote = NoteModel(
        id: '',
        title: title,
        body: body,
        subject: subject,
        tags: tags,
        createdAt: now,
        updatedAt: now,
      );
      await ref.read(noteRepositoryProvider).createNote(newNote);

      // Log analytics event for note creation
      ref.read(analyticsServiceProvider).logNoteCreated(
            subject: subject,
            wordCount: body.split(RegExp(r'\s+')).length,
          );

      // Award XP for new note (fire-and-forget, never blocks UI)
      ref
          .read(progressRepositoryProvider)
          .recordActivity('note')
          .then((newBadges) {
        if (newBadges.isNotEmpty && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '🎉 ${context.l10n.notesCreated}: ${newBadges.map((b) => b.title).join(', ')}'),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }).onError((error, stackTrace) {
        developer.log('recordActivity(note) error: $error',
            name: 'NotesScreen');
      });
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(_isEditing
                ? context.l10n.noteUpdated
                : context.l10n.noteCreated)),
      );
      context.go(AppRoutes.notes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            _isEditing ? l10n.editNoteTitleScreen : l10n.newNoteTitleScreen),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_rounded),
            onPressed: _saveNote,
          ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_rounded),
              onPressed: () => _showDeleteDialog(),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isEditing ? l10n.editYourNote : l10n.createNewNote,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(24),
              AppTextField(
                controller: _titleController,
                label: l10n.titleLabel,
                hint: l10n.noteTitleHint,
                maxLines: 1,
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) return l10n.titleRequired;
                  return null;
                },
              ),
              const Gap(16),
              AppTextField(
                controller: _subjectController,
                label: l10n.subjectLabel,
                hint: l10n.subjectHint,
                maxLines: 1,
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return l10n.subjectRequired;
                  return null;
                },
              ),
              const Gap(16),
              AppTextField(
                controller: _tagsController,
                label: l10n.tagsLabel,
                hint: l10n.tagsHint,
                maxLines: 1,
                textCapitalization: TextCapitalization.words,
              ),
              const Gap(16),
              SectionHeader(title: l10n.contentHeader),
              const Gap(8),
              TextFormField(
                controller: _bodyController,
                maxLines: 10,
                minLines: 5,
                decoration: InputDecoration(
                  hintText: l10n.writeNoteHint,
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return l10n.contentRequired;
                  return null;
                },
              ),
              const Gap(24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.upload_file_rounded, size: 20),
                      label: Text(l10n.importPdfTextButton),
                      onPressed: () => _showImportOptions(),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.auto_awesome_rounded, size: 20),
                      label: Text(l10n.aiActionsButton),
                      onPressed: () => _showAiActionsMenu(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImportOptions() {
    final l10n = context.l10n;
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: Text(l10n.pasteTextTitle),
            onTap: () {
              Navigator.pop(context);
              _showPasteDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: Text(l10n.importPdfButton),
            onTap: () {
              Navigator.pop(context);
              _importPdf();
            },
          ),
          ListTile(
            leading: const Icon(Icons.image),
            title: Text(l10n.importImageOcrTitle),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed(AppRoutes.scanner);
            },
          ),
        ],
      ),
    );
  }

  /// Import PDF file and extract text using Gemini
  Future<void> _importPdf() async {
    final l10n = context.l10n;

    try {
      // Pick PDF file using file_selector
      final result = await openFile(
        acceptedTypeGroups: [
          XTypeGroup(
            label: 'PDF',
            extensions: ['pdf'],
          ),
        ],
      );

      if (result == null) {
        // User cancelled
        return;
      }

      final file = result;

      // Check file size (max 10 MB)
      const maxSize = 10 * 1024 * 1024; // 10 MB
      if (await file.length() > maxSize) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.pdfFileTooLarge(maxSize ~/ (1024 * 1024))),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      if (!mounted) return;

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const Gap(16),
              Text(l10n.extractingPdfTextDialog),
            ],
          ),
        ),
      );

      // Extract text using Gemini
      final aiService = ref.read(aiServiceProvider);
      final canUse = await aiService.checkAndIncrementUsage();

      if (!canUse) {
        if (!mounted) return;
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.dailyAILimitReachedSnack)),
        );
        return;
      }

      try {
        final extractedText =
            await _extractTextFromPdf(aiService, await file.readAsBytes());

        if (!mounted) return;
        Navigator.pop(context); // Close loading dialog

        if (extractedText.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.pdfNoTextFound),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          return;
        }

        // Insert extracted text into body controller
        _bodyController.text = extractedText;

        // Record activity and analytics (same as manual note creation)
        ref
            .read(progressRepositoryProvider)
            .recordActivity('note')
            .then((newBadges) {
          if (newBadges.isNotEmpty && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    '🎉 ${context.l10n.notesCreated}: ${newBadges.map((b) => b.title).join(', ')}'),
                backgroundColor: Theme.of(context).colorScheme.secondary,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }).onError((error, stackTrace) {
          developer.log('recordActivity(note) error: $error',
              name: 'NotesScreen');
        });

        // Log analytics event for note creation
        ref.read(analyticsServiceProvider).logNoteCreated(
              subject: _subjectController.text.trim(),
              wordCount: extractedText.split(RegExp(r'\s+')).length,
            );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.pdfImportSuccess)),
        );
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context); // Close loading dialog
        _showAiErrorDialog('PDF import failed: ${e.toString()}');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorImportingPdf(e.toString())),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  /// Extract text from PDF bytes using Gemini
  Future<String> _extractTextFromPdf(
      AiService aiService, List<int> pdfBytes) async {
    // Use the chat model with multimodal input
    final content = [
      Content('user', [
        InlineDataPart('application/pdf', Uint8List.fromList(pdfBytes)),
        TextPart(
            'Extract all text from this PDF. Return ONLY the extracted text, no formatting or extra commentary.'),
      ]),
    ];

    final response = await aiService.generateContent(content);
    return response.text ?? '';
  }

  void _showPasteDialog() {
    final l10n = context.l10n;
    final pasteController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.pasteTextDialogTitle),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: pasteController,
            maxLines: 10,
            decoration: InputDecoration(
              hintText: l10n.pasteTextHint,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancelButton),
          ),
          TextButton(
            onPressed: () {
              final text = pasteController.text.trim();
              if (text.isNotEmpty) {
                _bodyController.text = text;
              }
              Navigator.pop(context);
            },
            child: Text(l10n.pasteButton),
          ),
        ],
      ),
    );
  }

  void _showAiActionsMenu() {
    final l10n = context.l10n;
    final body = _bodyController.text.trim();
    if (body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseEnterContentFirst)),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.auto_awesome),
            title: Text(l10n.summarizeAction),
            onTap: () {
              Navigator.pop(context);
              _performAiAction(AiAction.summarize);
            },
          ),
          ListTile(
            leading: const Icon(Icons.list_alt),
            title: Text(l10n.keyPointsAction),
            onTap: () {
              Navigator.pop(context);
              _performAiAction(AiAction.keyPoints);
            },
          ),
          ListTile(
            leading: const Icon(Icons.translate),
            title: Text(l10n.translateAction),
            onTap: () {
              Navigator.pop(context);
              _performAiAction(AiAction.translate);
            },
          ),
          ListTile(
            leading: const Icon(Icons.flash_on),
            title: Text(l10n.generateFlashcardsAction),
            onTap: () {
              Navigator.pop(context);
              _performAiAction(AiAction.flashcards);
            },
          ),
          ListTile(
            leading: const Icon(Icons.quiz),
            title: Text(l10n.generateQuizAction),
            onTap: () {
              Navigator.pop(context);
              _performAiAction(AiAction.quiz);
            },
          ),
          ListTile(
            leading: const Icon(Icons.calculate),
            title: Text(l10n.simplifyAction),
            onTap: () {
              Navigator.pop(context);
              _performAiAction(AiAction.simplify);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _performAiAction(AiAction action) async {
    final l10n = context.l10n;
    final aiService = ref.read(aiServiceProvider);
    final body = _bodyController.text.trim();
    final subject = _subjectController.text.trim();
    final language = _getSelectedLanguage();
    final canUse = await aiService.checkAndIncrementUsage();

    if (!canUse) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.dailyAILimitReachedSnack)),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _AiProcessingDialog(action: action),
    );

    try {
      final result =
          await _callAiService(aiService, action, body, subject, language);

      if (!mounted) return;
      Navigator.pop(context);

      await _handleAiResult(action, result);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_getActionSuccessMessage(action))),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showAiErrorDialog(e.toString());
      }
    }
  }

  String _getSelectedLanguage() {
    return AppConstants.supportedLocales.firstWhere(
      (locale) => _isLanguageSupported(locale),
      orElse: () => 'en',
    );
  }

  bool _isLanguageSupported(String locale) {
    return ['en', 'gu', 'hi'].contains(locale);
  }

  String _getActionSuccessMessage(AiAction action) {
    final l10n = context.l10n;
    switch (action) {
      case AiAction.summarize:
        return l10n.noteSummarizedSuccess;
      case AiAction.keyPoints:
        return l10n.keyPointsExtractedSuccess;
      case AiAction.translate:
        return l10n.noteTranslatedSuccess;
      case AiAction.flashcards:
        return l10n.flashcardsGeneratedSuccess;
      case AiAction.quiz:
        return l10n.quizGeneratedSuccess;
      case AiAction.simplify:
        return l10n.noteSimplifiedSuccess;
    }
  }

  Future<String> _callAiService(
    AiService aiService,
    AiAction action,
    String body,
    String subject,
    String language,
  ) async {
    switch (action) {
      case AiAction.summarize:
        return await aiService.summarizeNote(
            noteText: body, language: language);
      case AiAction.keyPoints:
        return await aiService.extractKeyPoints(
            noteText: body, language: language);
      case AiAction.translate:
        return await aiService.translateNote(
            noteText: body, targetLanguage: language);
      case AiAction.flashcards:
        final flashcards = await aiService.generateFlashcardsFromNote(
          noteText: body,
          count: 10,
          subject: subject,
          language: language,
        );
        return 'FLASHCARDS:${flashcards.map((f) => '${f.front}|${f.back}').join('||')}';
      case AiAction.quiz:
        final quizzes = await aiService.generateQuizFromNote(
          noteText: body,
          count: 10,
          difficulty: 'Medium',
          subject: subject,
          language: language,
        );
        return 'QUIZ:${quizQuestionToJson(quizzes)}';
      case AiAction.simplify:
        return await aiService.simplifyNote(noteText: body, language: language);
    }
  }

  String quizQuestionToJson(List<dynamic> questions) {
    final buffer = StringBuffer();
    buffer.write('[');
    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];
      buffer.write('{');
      buffer.write('"question":"${_escapeJson(q.question)}",');
      buffer.write(
          '"options":["${_escapeJson(q.options[0])}","${_escapeJson(q.options[1])}","${_escapeJson(q.options[2])}","${_escapeJson(q.options[3])}"],');
      buffer.write('"correctIndex":${q.correctIndex},');
      buffer.write('"explanation":"${_escapeJson(q.explanation)}"}');
      if (i < questions.length - 1) buffer.write(',');
    }
    buffer.write(']');
    return buffer.toString();
  }

  String _escapeJson(String input) {
    return input
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n');
  }

  Future<void> _handleAiResult(AiAction action, String result) async {
    if (result.isEmpty) return;

    switch (action) {
      case AiAction.summarize:
      case AiAction.keyPoints:
      case AiAction.translate:
      case AiAction.simplify:
        _bodyController.text = result;
        break;
      case AiAction.flashcards:
      case AiAction.quiz:
        // Results are saved - could show a preview or navigate to appropriate screen
        break;
    }
  }

  void _showAiErrorDialog(String error) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.aiActionFailedDialogTitle),
        content: Text(l10n.aiActionFailedDialogContent('error: $error')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.okButton),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    if (_existingNote == null) return;

    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteNoteDialogTitle),
        content: Text(l10n.deleteNoteDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancelButton),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(noteRepositoryProvider)
                  .deleteNote(_existingNote!.id);
              if (mounted) {
                context.go(AppRoutes.notes);
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.deleteButton),
          ),
        ],
      ),
    );
  }
}

class _AiProcessingDialog extends StatelessWidget {
  final AiAction action;

  const _AiProcessingDialog({required this.action});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final actionName = switch (action) {
      AiAction.summarize => l10n.summarizingDialog,
      AiAction.keyPoints => l10n.extractingKeyPointsDialog,
      AiAction.translate => l10n.translatingDialog,
      AiAction.flashcards => l10n.generatingFlashcardsDialog,
      AiAction.quiz => l10n.generatingQuizDialog,
      AiAction.simplify => l10n.simplifyingDialog,
    };

    return AlertDialog(
      title: Text('$actionName...'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const Gap(16),
          Text(l10n.aiWorkingDialog),
        ],
      ),
    );
  }
}

class NoteDetailScreen extends ConsumerStatefulWidget {
  final String noteId;

  const NoteDetailScreen({super.key, required this.noteId});

  @override
  ConsumerState<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends ConsumerState<NoteDetailScreen> {
  NoteModel? _note;

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  Future<void> _loadNote() async {
    final note = await ref.read(noteRepositoryProvider).getNote(widget.noteId);
    setState(() => _note = note);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(_note?.title ?? l10n.noteDetailTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_rounded),
            onPressed: () {
              // Save action
            },
          ),
          PopupMenuButton<String>(
            onSelected: (action) => _handleAction(action),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'pin',
                child: ListTile(
                  leading: const Icon(Icons.push_pin_rounded),
                  title: Text(l10n.pinAction),
                ),
              ),
              PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: const Icon(Icons.edit_rounded),
                  title: Text(l10n.editAction),
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete_rounded,
                      color: theme.colorScheme.error),
                  title: Text(l10n.deleteAction,
                      style: TextStyle(color: theme.colorScheme.error)),
                ),
              ),
            ],
          ),
        ],
      ),
      body: _note == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _note!.subject,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    _note!.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        _note!.body,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                  if (_note!.tags.isNotEmpty) ...[
                    const Gap(16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _note!.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            tag,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  void _handleAction(String action) {
    switch (action) {
      case 'pin':
        ref.read(noteRepositoryProvider).togglePin(_note!.id);
        break;
      case 'edit':
        if (mounted) {
          context.push(AppRoutes.notesCreate);
        }
        break;
      case 'delete':
        _showDeleteDialog();
        break;
    }
  }

  void _showDeleteDialog() {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteNoteDialogTitle),
        content: Text(l10n.deleteNoteConfirmSimple),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancelButton),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(noteRepositoryProvider).deleteNote(_note!.id);
              if (mounted) {
                context.go(AppRoutes.notes);
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.deleteButton),
          ),
        ],
      ),
    );
  }
}
