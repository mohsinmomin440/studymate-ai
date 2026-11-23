// Flashcards Screen - Deck list and quick actions

import 'dart:developer' as developer;

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
import '../../../core/services/analytics_service.dart';
import '../../chat/data/ai_service.dart';
import '../data/flashcard_repository.dart';
import '../domain/flashcard_models.dart';
import '../../../core/router/app_router.dart';
import '../../../features/progress/data/progress_repository.dart';

class FlashcardsScreen extends ConsumerStatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  ConsumerState<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends ConsumerState<FlashcardsScreen> {
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
        title: const Text('Flashcards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.go(AppRoutes.flashcardsCreate),
          ),
          IconButton(
            icon: const Icon(Icons.auto_awesome_rounded),
            onPressed: () => _showAiGenerateSheet(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppTextField(
              controller: _searchController,
              hint: 'Search decks...',
              prefixIcon: Icons.search_rounded,
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<FlashcardDeck>>(
              stream: ref.watch(flashcardRepositoryProvider).getDecks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final decks = snapshot.data ?? [];

                if (decks.isEmpty) {
                  return const EmptyState(
                    icon: Icons.flash_on_rounded,
                    title: 'No decks yet',
                    message:
                        'Create your first deck or generate flashcards from AI',
                  );
                }

                final filteredDecks = _searchQuery.isEmpty
                    ? decks
                    : decks
                        .where((d) => d.title
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()))
                        .toList();

                if (filteredDecks.isEmpty) {
                  return const EmptyState(
                    icon: Icons.search,
                    title: 'No decks found',
                    message: 'Try a different search term',
                  );
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filteredDecks.length,
                  itemBuilder: (context, index) {
                    final deck = filteredDecks[index];
                    return _buildDeckCard(deck, context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeckCard(FlashcardDeck deck, BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => context.go('${AppRoutes.deckDetail}/${deck.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  deck.title,
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
            deck.subject,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
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
      builder: (context) => const AiGenerateSheet(),
    );
  }
}

class AiGenerateSheet extends ConsumerStatefulWidget {
  const AiGenerateSheet({super.key});

  @override
  ConsumerState<AiGenerateSheet> createState() => _AiGenerateSheetState();
}

class _AiGenerateSheetState extends ConsumerState<AiGenerateSheet> {
  final _topicController = TextEditingController();
  String _selectedSubject = 'Mathematics';
  int _cardCount = 10;

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _generateDeck() async {
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
          action: 'Generating flashcards',
        ),
      );
    }

    try {
      final flashcards = await aiService.generateFlashcards(
        topic: topic,
        count: _cardCount,
        subject: _selectedSubject,
        language: AppConstants.defaultLocale,
      );

      if (!mounted) return;
      Navigator.pop(context);

      final deckId = await ref.read(flashcardRepositoryProvider).createDeck(
            title: topic,
            subject: _selectedSubject,
          );

      // Convert AI response to map format for repository
      final cardsData =
          flashcards.map((f) => {'front': f.front, 'back': f.back}).toList();

      await ref.read(flashcardRepositoryProvider).createCardsFromData(
            deckId: deckId,
            cardsData: cardsData,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deck created successfully!')),
      );

      context.go('${AppRoutes.deckDetail}/$deckId');
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
          const SectionHeader(title: 'Generate Flashcards'),
          const Gap(16),
          AppTextField(
            controller: _topicController,
            label: 'Topic',
            hint: 'e.g., Photosynthesis, Quadratic Equations',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Card Count',
                style: theme.textTheme.titleMedium,
              ),
              DropdownButton<int>(
                value: _cardCount,
                items: AppConstants.quizQuestionCounts
                    .map((c) =>
                        DropdownMenuItem(value: c, child: Text('$c cards')))
                    .toList(),
                onChanged: (v) => setState(() => _cardCount = v ?? 10),
              ),
            ],
          ),
          const Gap(24),
          FilledButton(
            onPressed: _generateDeck,
            child: const Text('Generate'),
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

class CreateEditDeckScreen extends ConsumerStatefulWidget {
  final String? deckId;

  const CreateEditDeckScreen({super.key, this.deckId});

  @override
  ConsumerState<CreateEditDeckScreen> createState() =>
      _CreateEditDeckScreenState();
}

class _CreateEditDeckScreenState extends ConsumerState<CreateEditDeckScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();
  bool _isEditing = false;
  FlashcardDeck? _existingDeck;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.deckId != null;
    if (_isEditing) {
      _loadExistingDeck();
    }
  }

  Future<void> _loadExistingDeck() async {
    final deck =
        await ref.read(flashcardRepositoryProvider).getDeck(widget.deckId!);
    if (deck != null) {
      setState(() => _existingDeck = deck);
      _titleController.text = deck.title;
      _subjectController.text = deck.subject;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _saveDeck() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final subject = _subjectController.text.trim();

    if (_isEditing && _existingDeck != null) {
      final updatedDeck = _existingDeck!.copyWith(
        title: title,
        subject: subject,
        updatedAt: DateTime.now(),
      );
      await ref.read(flashcardRepositoryProvider).updateDeck(updatedDeck);
    } else {
      await ref.read(flashcardRepositoryProvider).createDeck(
            title: title,
            subject: subject,
          );
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Deck updated' : 'Deck created')),
      );
      context.go(AppRoutes.flashcards);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Deck' : 'New Deck'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_rounded),
            onPressed: _saveDeck,
          ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_rounded),
              onPressed: _showDeleteDialog,
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
                _isEditing ? 'Edit your deck' : 'Create a new deck',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(24),
              AppTextField(
                controller: _titleController,
                label: 'Deck Title',
                hint: 'Enter deck name',
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
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Subject required';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    if (_existingDeck == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Deck'),
        content: const Text(
            'Are you sure you want to delete this deck? All cards will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(flashcardRepositoryProvider)
                  .deleteDeck(_existingDeck!.id);
              if (mounted) {
                context.go(AppRoutes.flashcards);
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

class CardEditorScreen extends ConsumerStatefulWidget {
  final String deckId;
  final String? cardId;

  const CardEditorScreen({super.key, required this.deckId, this.cardId});

  @override
  ConsumerState<CardEditorScreen> createState() => _CardEditorScreenState();
}

class _CardEditorScreenState extends ConsumerState<CardEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _frontController = TextEditingController();
  final _backController = TextEditingController();
  bool _isEditing = false;
  Flashcard? _existingCard;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.cardId != null;
    if (_isEditing) {
      _loadExistingCard();
    }
  }

  Future<void> _loadExistingCard() async {
    final card = await ref
        .read(flashcardRepositoryProvider)
        .getCard(widget.deckId, widget.cardId!);
    if (card != null) {
      setState(() => _existingCard = card);
      _frontController.text = card.front;
      _backController.text = card.back;
    }
  }

  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    super.dispose();
  }

  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) return;

    final front = _frontController.text.trim();
    final back = _backController.text.trim();

    if (_isEditing && _existingCard != null) {
      final updatedCard = _existingCard!.copyWith(front: front, back: back);
      await ref.read(flashcardRepositoryProvider).updateCard(updatedCard);
    } else {
      await ref.read(flashcardRepositoryProvider).createCard(
            deckId: widget.deckId,
            front: front,
            back: back,
          );
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Card updated' : 'Card created')),
      );
      context.go('${AppRoutes.deckDetail}/${widget.deckId}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Card'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_rounded),
            onPressed: _saveCard,
          ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_rounded),
              onPressed: _showDeleteDialog,
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
                _isEditing ? 'Edit Card' : 'New Card',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(24),
              AppTextField(
                controller: _frontController,
                label: 'Front (Question / Term)',
                hint: 'What is...?',
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Front required';
                  return null;
                },
              ),
              const Gap(16),
              TextFormField(
                controller: _backController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Back (Answer / Definition)',
                  hintText: 'Answer...',
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
                  if (value == null || value.isEmpty) return 'Back required';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    if (_existingCard == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Card'),
        content: const Text('Are you sure you want to delete this card?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(flashcardRepositoryProvider)
                  .deleteCard(widget.deckId, _existingCard!.id);
              if (mounted) {
                context.go('${AppRoutes.deckDetail}/${widget.deckId}');
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

class DeckDetailScreen extends ConsumerStatefulWidget {
  final String deckId;

  const DeckDetailScreen({super.key, required this.deckId});

  @override
  ConsumerState<DeckDetailScreen> createState() => _DeckDetailScreenState();
}

class _DeckDetailScreenState extends ConsumerState<DeckDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Deck'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: () =>
                  context.go('${AppRoutes.flashcardsEdit}/${widget.deckId}'),
            ),
            IconButton(
              icon: const Icon(Icons.play_circle_rounded),
              onPressed: () =>
                  context.go('${AppRoutes.studyMode}/${widget.deckId}'),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Cards'),
              Tab(text: 'Stats'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            CardsListScreen(deckId: widget.deckId),
            const DeckStatsScreen(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () =>
              context.go('${AppRoutes.cardCreate}/${widget.deckId}'),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class CardsListScreen extends ConsumerWidget {
  final String deckId;

  const CardsListScreen({super.key, required this.deckId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<FlashcardDeck?>(
      future: ref.watch(flashcardRepositoryProvider).getDeck(deckId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final deck = snapshot.data;
        if (deck == null) {
          return const Center(child: Text('Deck not found'));
        }

        return StreamBuilder<List<Flashcard>>(
          stream: ref.watch(flashcardRepositoryProvider).getAllCards(deckId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final cards = snapshot.data ?? [];

            if (cards.isEmpty) {
              return const EmptyState(
                icon: Icons.question_answer,
                title: 'No cards yet',
                message: 'Add flashcards to start studying',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                final card = cards[index];
                return _buildCardTile(card, context);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCardTile(Flashcard card, BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          card.front,
          style: theme.textTheme.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          card.back,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => showDialog(
          context: context,
          builder: (context) => CardStudyDialog(card: card),
        ),
      ),
    );
  }
}

class CardStudyDialog extends StatelessWidget {
  final Flashcard card;

  const CardStudyDialog({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              card.front,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(24),
            Text(
              card.back,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class DeckStatsScreen extends ConsumerWidget {
  const DeckStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deckId = GoRouter.of(context).state.pathParameters['deckId'];
    if (deckId == null) {
      return const Center(child: Text('Deck not found'));
    }

    return FutureBuilder<DeckStats?>(
      future: ref.watch(flashcardRepositoryProvider).getDeckStats(deckId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = snapshot.data;
        if (stats == null) {
          return const Center(child: Text('Loading stats...'));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildStatRow(context, 'Total Cards', stats.totalCards.toString(),
                Icons.format_size, Theme.of(context).colorScheme.primary),
            const Gap(12),
            _buildStatRow(
                context,
                'Due Today',
                '${stats.dueToday}',
                Icons.schedule,
                stats.dueToday > 0
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.secondary),
            const Gap(12),
            _buildStatRow(context, 'Mastered', stats.mastered.toString(),
                Icons.star, Theme.of(context).colorScheme.secondary),
            const Gap(16),
            const SectionHeader(title: 'By State'),
            const Gap(12),
            _buildStateStat('New', stats.newCards),
            const Gap(8),
            _buildStateStat('Learning', stats.learning),
          ],
        );
      },
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value,
      IconData icon, Color color) {
    final theme = Theme.of(context);
    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.5)],
              ),
            ),
            child: Icon(icon, size: 20, color: theme.colorScheme.onPrimary),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Gap(2),
                Text(
                  value,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateStat(String label, int count) {
    return Row(
      children: [
        Expanded(
          child:
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ),
        Text(count.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class StudyModeScreen extends ConsumerStatefulWidget {
  final String deckId;

  const StudyModeScreen({super.key, required this.deckId});

  @override
  ConsumerState<StudyModeScreen> createState() => _StudyModeScreenState();
}

class _StudyModeScreenState extends ConsumerState<StudyModeScreen> {
  Flashcard? _currentCard;
  bool _showBack = false;

  @override
  void initState() {
    super.initState();
    _loadDueCards();
  }

  Future<void> _loadDueCards() async {
    final cardsSnap = await ref
        .read(flashcardRepositoryProvider)
        .getDeckCards(widget.deckId)
        .where('dueAt', isLessThanOrEqualTo: DateTime.now())
        .orderBy('dueAt')
        .get();

    final cards =
        cardsSnap.docs.map((d) => Flashcard.fromFirestore(d)).toList();

    if (cards.isNotEmpty && mounted) {
      setState(() {
        _currentCard = cards.first;
      });
    }
  }

  Future<void> _onRating(int rating) async {
    final card = _currentCard;
    if (card == null) return;

    await ref.read(flashcardRepositoryProvider).reviewCard(
          deckId: widget.deckId,
          cardId: card.id,
          rating: rating,
        );

    // Log analytics event for flashcard review
    ref.read(analyticsServiceProvider).logFlashcardReviewed(
          deckId: widget.deckId,
          cardsReviewed: 1,
          correct: rating >= 2 ? 1 : 0, // Good or Easy = correct
        );

    // Award XP for flashcard review (fire-and-forget, never blocks UI)
    ref
        .read(progressRepositoryProvider)
        .recordActivity('flashcard_review')
        .then((newBadges) {
      if (newBadges.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '🎉 New badge: ${newBadges.map((b) => b.title).join(', ')}'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }).onError((error, stackTrace) {
      developer.log('recordActivity(flashcard_review) error: $error',
          name: 'FlashcardsScreen');
    });

    if (!mounted) return;

    setState(() {
      _showBack = false;
    });

    await Future.delayed(const Duration(milliseconds: 300));

    _loadDueCards();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_currentCard == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Study')),
        body: const Center(
          child: EmptyState(
            icon: Icons.check_circle,
            title: 'All cards due!',
            message: 'You\'ve reviewed all cards due today. Great job!',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Study')),
      body: GestureDetector(
        onTap: () {
          if (_showBack) {
            setState(() => _showBack = false);
          } else {
            setState(() => _showBack = true);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: GlassCard(
                  onTap: () {},
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                      child: Column(
                        key: ValueKey(_showBack),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _showBack
                                ? _currentCard!.back
                                : _currentCard!.front,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const Gap(24),
                          if (!_showBack)
                            const Icon(Icons.question_answer, size: 64),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const Gap(16),
              if (_showBack)
                Column(
                  children: [
                    const Text(
                      'How well did you know this?',
                      style: TextStyle(fontSize: 16),
                    ),
                    const Gap(12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _RatingButton(
                          label: 'Again',
                          color: theme.colorScheme.error,
                          onTap: () => _onRating(0),
                        ),
                        _RatingButton(
                          label: 'Hard',
                          color: theme.colorScheme.tertiary,
                          onTap: () => _onRating(1),
                        ),
                        _RatingButton(
                          label: 'Good',
                          color: theme.colorScheme.secondary,
                          onTap: () => _onRating(2),
                        ),
                        _RatingButton(
                          label: 'Easy',
                          color: theme.colorScheme.primary,
                          onTap: () => _onRating(3),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RatingButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _RatingButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
