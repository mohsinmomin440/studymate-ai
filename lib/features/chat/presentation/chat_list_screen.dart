// Chat List Screen - Shows all user's chat sessions

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/glass_card.dart' show GlassCard;
import '../../../shared/widgets/shimmer_box.dart';
import '../../chat/data/chat_repository.dart';
import '../../chat/domain/chat_models.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatsAsync = ref.watch(chatListStreamProvider(_searchQuery));

    return Scaffold(
      appBar: AppBar(
        title: Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _showNewChatBottomSheet,
            tooltip: 'New Chat',
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => context.go(AppRoutes.settings),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppSearchField(
              controller: _searchController,
              hint: 'Search chats...',
              onChanged: (value) => setState(() => _searchQuery = value),
              onClear: () => setState(() => _searchQuery = ''),
            ),
          ),
          Expanded(
            child: chatsAsync.when(
              data: (chats) {
                if (chats.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    return _ChatListTile(chat: chat)
                        .animate()
                        .fadeIn(duration: 300.ms, delay: (index * 50).ms)
                        .slideX(begin: 0.2, end: 0);
                  },
                );
              },
              loading: () => _buildLoadingList(),
              error: (err, stack) => _buildErrorState(err.toString()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewChatBottomSheet,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyState(
      icon: Icons.chat_bubble_outline_rounded,
      title: 'No chats yet',
      message: 'Start a new conversation with StudyMate AI',
      actionLabel: 'New Chat',
      onAction: _showNewChatBottomSheet,
    );
  }

  Widget _buildLoadingList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 6,
      itemBuilder: (context, index) => ShimmerBox(
        height: 80,
        margin: const EdgeInsets.only(bottom: 12),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return EmptyState(
      icon: Icons.error_outline_rounded,
      title: 'Unable to load chats',
      message: error,
      actionLabel: 'Retry',
      onAction: () => ref.invalidate(chatListStreamProvider(_searchQuery)),
    );
  }

  void _showNewChatBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NewChatBottomSheet(onCreate: (chatId) {
        Navigator.of(context).pop();
        context.go('${AppRoutes.chatDetail}/$chatId');
      }),
    );
  }
}

final chatListStreamProvider =
    StreamProvider.family<List<ChatSessionModel>, String>((ref, query) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.getChats().map((chats) {
    if (query.isEmpty) return chats;
    final lowerQuery = query.toLowerCase();
    return chats
        .where((chat) =>
            chat.title.toLowerCase().contains(lowerQuery) ||
            chat.subject.toLowerCase().contains(lowerQuery) ||
            (chat.lastMessagePreview?.toLowerCase().contains(lowerQuery) ??
                false))
        .toList();
  });
});

class _ChatListTile extends ConsumerWidget {
  final ChatSessionModel chat;

  const _ChatListTile({required this.chat});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return GlassCard(
      onTap: () => context.go('${AppRoutes.chatDetail}/${chat.id}'),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                chat.subject.isNotEmpty ? chat.subject[0] : '?',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        chat.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (chat.messageCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${chat.messageCount}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const Gap(4),
                Row(
                  children: [
                    Text(
                      chat.mode,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      _formatDate(chat.updatedAt),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                if (chat.lastMessagePreview != null &&
                    chat.lastMessagePreview!.isNotEmpty) ...[
                  const Gap(4),
                  Text(
                    chat.lastMessagePreview!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, ref, value, chat),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'rename',
                child: Row(
                  children: [
                    Icon(Icons.edit_rounded, size: 20),
                    Gap(12),
                    Text('Rename'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_rounded, size: 20, color: Colors.red),
                    Gap(12),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            child: Icon(
              Icons.more_vert_rounded,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return DateFormat.jm().format(date);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat.E().format(date);
    } else {
      return DateFormat.MMMd().format(date);
    }
  }
}

void _handleMenuAction(BuildContext context, WidgetRef ref, String action,
    ChatSessionModel chat) async {
  final repository = ref.read(chatRepositoryProvider);
  switch (action) {
    case 'rename':
      _showRenameDialog(context, chat, repository);
      break;
    case 'delete':
      _confirmDelete(context, chat, repository);
      break;
  }
}

void _showRenameDialog(
    BuildContext context, ChatSessionModel chat, ChatRepository repository) {
  final controller = TextEditingController(text: chat.title);
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Rename Chat'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Chat Title'),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        TextButton(
          onPressed: () async {
            final newTitle = controller.text.trim();
            if (newTitle.isNotEmpty) {
              await repository.renameChat(chat.id, newTitle);
            }
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

void _confirmDelete(
    BuildContext context, ChatSessionModel chat, ChatRepository repository) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Chat'),
      content: const Text(
          'This will permanently delete the chat and all messages. Are you sure?'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        TextButton(
          onPressed: () async {
            await repository.deleteChat(chat.id);
            if (context.mounted) {
              context.go(AppRoutes.chat);
            }
          },
          style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}

class _NewChatBottomSheet extends ConsumerStatefulWidget {
  final void Function(String chatId) onCreate;

  const _NewChatBottomSheet({required this.onCreate});

  @override
  ConsumerState<_NewChatBottomSheet> createState() =>
      _NewChatBottomSheetState();
}

class _NewChatBottomSheetState extends ConsumerState<_NewChatBottomSheet> {
  final _titleController = TextEditingController();
  String _selectedSubject = AppConstants.subjects.first;
  String _selectedMode = AppConstants.chatModes.first;
  bool _isCreating = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Gap(16),
          Text(
            'New Chat',
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const Gap(24),
          AppTextField(
            label: 'Chat Title',
            hint: 'e.g., Calculus Derivatives',
            controller: _titleController,
            textCapitalization: TextCapitalization.words,
          ),
          const Gap(16),
          Text('Subject', style: theme.textTheme.labelMedium),
          const Gap(8),
          DropdownButtonFormField<String>(
            initialValue: _selectedSubject,
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            items: AppConstants.subjects
                .map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(s),
                    ))
                .toList(),
            onChanged: (value) =>
                setState(() => _selectedSubject = value ?? _selectedSubject),
          ),
          const Gap(16),
          Text('Mode', style: theme.textTheme.labelMedium),
          const Gap(8),
          DropdownButtonFormField<String>(
            value: _selectedMode,
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            items: AppConstants.chatModes
                .map((m) => DropdownMenuItem(
                      value: m,
                      child: Text(m),
                    ))
                .toList(),
            onChanged: (value) =>
                setState(() => _selectedMode = value ?? _selectedMode),
          ),
          const Gap(24),
          FilledButton(
            onPressed: _isCreating ? null : _createChat,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: _isCreating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Create Chat'),
          ),
          const Gap(8),
        ],
      ),
    );
  }

  Future<void> _createChat() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    setState(() => _isCreating = true);

    try {
      final repository = ref.read(chatRepositoryProvider);
      final chatId = await repository.createChat(
        title: title,
        subject: _selectedSubject,
        mode: _selectedMode,
      );
      if (mounted) {
        widget.onCreate(chatId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create chat: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }
}
