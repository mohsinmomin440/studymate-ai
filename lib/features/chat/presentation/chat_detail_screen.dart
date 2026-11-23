// Chat Detail Screen - Individual chat with AI tutor

library;

import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:firebase_ai/firebase_ai.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/extensions.dart';
import '../../../features/progress/data/progress_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/analytics_service.dart';
import '../../../shared/widgets/ai_message_bubble.dart';
import '../../../shared/widgets/app_text_field.dart' show AppTextField;
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/gap.dart';
import '../../chat/data/ai_service.dart';
import '../../chat/data/chat_repository.dart';
import '../../chat/domain/chat_models.dart';
import '../../chat/ai_prompts.dart';
import '../../notes/data/note_repository.dart';
import '../../notes/domain/note_models.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  final String chatId;

  const ChatDetailScreen({super.key, required this.chatId});

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  ChatSessionModel? _chat;
  List<ChatMessage> _messages = [];
  bool _isSending = false;
  StreamSubscription<List<ChatMessage>>? _messagesSubscription;
  ChatSession? _aiChatSession;

  @override
  void initState() {
    super.initState();
    _loadChat();
    _listenToMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messagesSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadChat() async {
    final repository = ref.read(chatRepositoryProvider);
    final chat = await repository.getChat(widget.chatId);
    if (chat != null && mounted) {
      setState(() => _chat = chat);
      _initAIChatSession(chat);
    }
  }

  void _listenToMessages() {
    final repository = ref.read(chatRepositoryProvider);
    _messagesSubscription = repository.getMessages(widget.chatId).listen(
      (messages) {
        if (mounted) {
          setState(() => _messages = messages);
          _scrollToBottom();
        }
      },
      onError: (error, stackTrace) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.errorLoading(error))),
          );
        }
      },
    );
  }

  void _initAIChatSession(ChatSessionModel chat) {
    final aiService = ref.read(aiServiceProvider);
    final systemPrompt = buildSystemPrompt(
      mode: chat.mode,
      subject: chat.subject,
      language: 'English',
    );
    _aiChatSession = aiService.startChat(
      systemPrompt: systemPrompt,
      history: _messages
          .where((m) => m.role == 'user' || m.role == 'model')
          .map((m) => m.toContent())
          .toList(),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending || _chat == null || _aiChatSession == null) {
      return;
    }

    final aiService = ref.read(aiServiceProvider);
    final canUse = await aiService.checkAndIncrementUsage();
    if (!canUse) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.dailyAILimitMessage),
            backgroundColor: Theme.of(context).customColors.warning,
          ),
        );
      }
      return;
    }

    setState(() {
      _isSending = true;
      _messageController.clear();
    });

    try {
      final repository = ref.read(chatRepositoryProvider);
      final userMessage = ChatMessage.user(id: '', text: text);

      await repository.addMessage(widget.chatId, userMessage);

      await repository.updateChat(
        widget.chatId,
        messageCount: _chat!.messageCount + 1,
        lastMessagePreview:
            text.length > 50 ? '${text.substring(0, 50)}...' : text,
      );

      // Award XP for chat activity and check badges (fire-and-forget, never blocks UI)
      ref
          .read(progressRepositoryProvider)
          .recordActivity('chat')
          .then((newBadges) {
        if (newBadges.isNotEmpty && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '🎉 ${context.l10n.newChat}: ${newBadges.map((b) => b.title).join(', ')}'),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }).onError((error, stackTrace) {
        developer.log('recordActivity(chat) error: $error',
            name: 'ChatDetailScreen');
      });

      String fullResponse = '';
      await for (final chunk
          in aiService.sendMessageStream(_aiChatSession!, text)) {
        final chunkText = chunk.text ?? '';
        fullResponse += chunkText;
      }

      final aiMessage = ChatMessage.model(id: '', text: fullResponse);
      await repository.addMessage(widget.chatId, aiMessage);

      await repository.updateChat(
        widget.chatId,
        messageCount: _chat!.messageCount + 2,
        lastMessagePreview: fullResponse.length > 50
            ? '${fullResponse.substring(0, 50)}...'
            : fullResponse,
      );

      // Log analytics event for chat
      ref.read(analyticsServiceProvider).logChatSent(
            messageCount: 1,
            subject: _chat?.subject ?? 'General',
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.failedToSend(e))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _regenerateLastResponse() async {
    if (_messages.length < 2 || _isSending) return;

    ChatMessage? lastUserMessage;
    for (int i = _messages.length - 1; i >= 0; i--) {
      if (_messages[i].role == 'user') {
        lastUserMessage = _messages[i];
        break;
      }
    }
    if (lastUserMessage == null) return;

    _messageController.text = lastUserMessage.text;
    await _sendMessage();
  }

  Future<void> _copyMessage(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.copiedToClipboard)),
      );
    }
  }

  Future<void> _shareMessage(String text) async {
    await Share.share(text, subject: 'StudyMate AI Response');
  }

  Future<void> _saveToNotes(String text) async {
    try {
      final repository = ref.read(noteRepositoryProvider);

      final note = NoteModel(
        id: '',
        title: context.l10n.chatTitle,
        body: text,
        subject: _chat?.subject ?? context.l10n.subject,
        tags: ['ai-chat'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createNote(note);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.savedToNotes)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.errorSaving(e))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: _chat != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _chat!.title,
                    style: theme.textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${_chat!.subject} • ${_chat!.mode}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              )
            : Text(context.l10n.loadingStats),
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleAppMenuAction,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'rename',
                child: Row(
                  children: [
                    Icon(Icons.edit_rounded, size: 20),
                    Gap(12),
                    Text(context.l10n.renameChat),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_rounded,
                        size: 20, color: theme.colorScheme.error),
                    Gap(12),
                    Text(context.l10n.deleteChat,
                        style: TextStyle(color: theme.colorScheme.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _messages.length + (_isSending ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isSending) {
                        return _buildStreamingPlaceholder();
                      }
                      final message = _messages[index];
                      return _buildMessage(message);
                    },
                  ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyState(
      icon: Icons.chat_bubble_outline_rounded,
      title: context.l10n.startNewConversation,
      message: context.l10n.askQuestionGetHelp,
      actionLabel: null,
      onAction: null,
    );
  }

  Widget _buildMessage(ChatMessage message) {
    final isUser = message.role == 'user';
    final isLast = _messages.indexOf(message) == _messages.length - 1;

    return AiMessageBubble(
      text: message.text,
      isUser: isUser,
      isStreaming: !isUser && isLast && _isSending,
      onCopy: () => _copyMessage(message.text),
      onRegenerate: isLast && !isUser ? _regenerateLastResponse : null,
      onSaveToNotes: !isUser ? () => _saveToNotes(message.text) : null,
      onShare: !isUser ? () => _shareMessage(message.text) : null,
    );
  }

  Widget _buildStreamingPlaceholder() {
    return AiMessageBubble(
      text: '',
      isUser: false,
      isStreaming: true,
    );
  }

  Widget _buildInputArea() {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: AppTextField(
              controller: _messageController,
              hint: context.l10n.askQuestionGetHelp,
              maxLines: 5,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onChanged: (value) => setState(() {}),
              onSubmitted: (_) => _sendMessage(),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.mic_rounded,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () {
                      // TODO: voice input
                    },
                    tooltip: context.l10n.voiceInput,
                  ),
                ],
              ),
            ),
          ),
          const Gap(8),
          AnimatedScale(
            scale: _messageController.text.trim().isNotEmpty && !_isSending
                ? 1.0
                : 0.8,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            child: FloatingActionButton.small(
              onPressed:
                  (_messageController.text.trim().isNotEmpty && !_isSending)
                      ? _sendMessage
                      : null,
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              child: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send_rounded),
            ),
          ),
        ],
      ),
    );
  }

  void _handleAppMenuAction(String action) async {
    final repository = ref.read(chatRepositoryProvider);
    switch (action) {
      case 'rename':
        _showRenameDialog(repository);
        break;
      case 'delete':
        _confirmDelete(repository);
        break;
    }
  }

  void _showRenameDialog(ChatRepository repository) {
    final controller = TextEditingController(text: _chat?.title ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.renameChat),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: context.l10n.chatTitle),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.cancel)),
          TextButton(
            onPressed: () async {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty) {
                await repository.renameChat(widget.chatId, newTitle);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(context.l10n.save),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(ChatRepository repository) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.deleteChat),
        content: Text(context.l10n.deleteChatConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.cancel)),
          TextButton(
            onPressed: () async {
              await repository.deleteChat(widget.chatId);
              if (context.mounted) {
                context.go(AppRoutes.chat);
              }
            },
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
  }
}
