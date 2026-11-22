// Notes Screen - List and manage notes

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../core/constants/app_constants.dart';
import '../../chat/data/ai_service.dart';
import '../data/note_repository.dart';
import '../domain/note_models.dart';
import '../../../core/router/app_router.dart';

/// AI actions available for notes
enum AiAction { summarize, keyPoints, translate, flashcards, quiz }

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.go(AppRoutes.notesCreate),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppTextField(
              controller: _searchController,
              hint: 'Search notes...',
              prefixIcon: Icons.search_rounded,
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<NoteModel>>(
              stream: _searchQuery.isEmpty
                  ? ref.watch(noteRepositoryProvider).getNotes()
                  : ref.watch(noteRepositoryProvider).searchNotes(_searchQuery),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final notes = snapshot.data ?? [];

                if (notes.isEmpty) {
                  return const EmptyState(
                    icon: Icons.note_add_rounded,
                    title: 'No notes yet',
                    message: 'Create your first note to get started',
                  );
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
        ],
      ),
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
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Note updated' : 'Note created')),
      );
      context.go(AppRoutes.notes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Note' : 'New Note'),
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
                _isEditing ? 'Edit your note' : 'Create a new note',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(24),
              AppTextField(
                controller: _titleController,
                label: 'Title',
                hint: 'Note title',
                maxLines: 1,
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Title required';
                  return null;
                },
              ),
              const Gap(16),
              AppTextField(
                controller: _subjectController,
                label: 'Subject',
                hint: 'e.g., Mathematics, Physics',
                maxLines: 1,
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Subject required';
                  return null;
                },
              ),
              const Gap(16),
              AppTextField(
                controller: _tagsController,
                label: 'Tags (comma separated)',
                hint: 'Algebra, Geometry, Important',
                maxLines: 1,
                textCapitalization: TextCapitalization.words,
              ),
              const Gap(16),
              const SectionHeader(title: 'Content'),
              const Gap(8),
              TextFormField(
                controller: _bodyController,
                maxLines: 10,
                minLines: 5,
                decoration: InputDecoration(
                  hintText: 'Write your note here...',
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
                  if (value == null || value.isEmpty) return 'Content required';
                  return null;
                },
              ),
              const Gap(24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.upload_file_rounded, size: 20),
                      label: const Text('Import PDF/Text'),
                      onPressed: () => _showImportOptions(),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.auto_awesome_rounded, size: 20),
                      label: const Text('AI Actions'),
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
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: const Text('Paste Text'),
            onTap: () {
              Navigator.pop(context);
              _showPasteDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: const Text('Choose PDF file'),
            onTap: () {
              Navigator.pop(context);
              // PDF import deferred - requires additional package compatibility
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PDF import coming soon')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('Import Image (OCR)'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed(AppRoutes.scanner);
            },
          ),
        ],
      ),
    );
  }

  void _showPasteDialog() {
    final pasteController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Paste Text'),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: pasteController,
            maxLines: 10,
            decoration: const InputDecoration(
              hintText: 'Paste text here...',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final text = pasteController.text.trim();
              if (text.isNotEmpty) {
                _bodyController.text = text;
              }
              Navigator.pop(context);
            },
            child: const Text('Paste'),
          ),
        ],
      ),
    );
  }

  void _showAiActionsMenu() {
    final body = _bodyController.text.trim();
    if (body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter content first')),
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
            title: const Text('Summarize'),
            onTap: () {
              Navigator.pop(context);
              _performAiAction(AiAction.summarize);
            },
          ),
          ListTile(
            leading: const Icon(Icons.list_alt),
            title: const Text('Key Points'),
            onTap: () {
              Navigator.pop(context);
              _performAiAction(AiAction.keyPoints);
            },
          ),
          ListTile(
            leading: const Icon(Icons.translate),
            title: const Text('Translate'),
            onTap: () {
              Navigator.pop(context);
              _performAiAction(AiAction.translate);
            },
          ),
          ListTile(
            leading: const Icon(Icons.flash_on),
            title: const Text('Generate Flashcards'),
            onTap: () {
              Navigator.pop(context);
              _performAiAction(AiAction.flashcards);
            },
          ),
          ListTile(
            leading: const Icon(Icons.quiz),
            title: const Text('Generate Quiz'),
            onTap: () {
              Navigator.pop(context);
              _performAiAction(AiAction.quiz);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _performAiAction(AiAction action) async {
    final aiService = ref.read(aiServiceProvider);
    final body = _bodyController.text.trim();
    final subject = _subjectController.text.trim();
    final language = _getSelectedLanguage();
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
    switch (action) {
      case AiAction.summarize:
        return 'Note summarized successfully';
      case AiAction.keyPoints:
        return 'Key points extracted successfully';
      case AiAction.translate:
        return 'Note translated successfully';
      case AiAction.flashcards:
        return 'Flashcards generated successfully';
      case AiAction.quiz:
        return 'Quiz generated successfully';
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
        return 'QUIZ:${QuizQuestionToJson(quizzes)}';
    }
  }

  String QuizQuestionToJson(List<dynamic> questions) {
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
        _bodyController.text = result;
        break;
      case AiAction.flashcards:
      case AiAction.quiz:
        // Results are saved - could show a preview or navigate to appropriate screen
        break;
    }
  }

  void _showAiErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Action Failed'),
        content: Text('Something went wrong: $error\n\nPlease try again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    if (_existingNote == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text(
            'Are you sure you want to delete this note? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
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
            child: const Text('Delete'),
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
    final actionName = switch (action) {
      AiAction.summarize => 'Summarizing',
      AiAction.keyPoints => 'Extracting key points',
      AiAction.translate => 'Translating',
      AiAction.flashcards => 'Generating flashcards',
      AiAction.quiz => 'Generating quiz',
    };

    return AlertDialog(
      title: Text('$actionName...'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const Gap(16),
          Text('StudyMate AI is working on it...'),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(_note?.title ?? 'Note'),
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
              const PopupMenuItem(
                value: 'pin',
                child: ListTile(
                  leading: Icon(Icons.push_pin_rounded),
                  title: Text('Pin'),
                ),
              ),
              const PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit_rounded),
                  title: Text('Edit'),
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete_rounded, color: Colors.red),
                  title: Text('Delete', style: TextStyle(color: Colors.red)),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
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
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
