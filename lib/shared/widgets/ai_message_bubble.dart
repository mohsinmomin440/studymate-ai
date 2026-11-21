import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'gap.dart';
import '../../core/theme/app_theme.dart';

/// AI message bubble with markdown rendering
class AiMessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final bool isStreaming;
  final VoidCallback? onCopy;
  final VoidCallback? onRegenerate;
  final VoidCallback? onSaveToNotes;
  final VoidCallback? onShare;
  final Duration animationDuration;

  const AiMessageBubble({
    super.key,
    required this.text,
    required this.isUser,
    this.isStreaming = false,
    this.onCopy,
    this.onRegenerate,
    this.onSaveToNotes,
    this.onShare,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _Avatar(
              isUser: false,
              isStreaming: isStreaming,
            ),
            const Gap(8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isUser) _buildActions(context),
                  _buildContent(context),
                  if (isStreaming) _buildTypingIndicator(context),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const Gap(8),
            _Avatar(isUser: true),
          ],
        ],
      ),
    ).animate().fadeIn(duration: animationDuration).slideY(begin: 0.1, end: 0);
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onCopy != null)
            _ActionButton(
              icon: Icons.copy_rounded,
              onTap: onCopy,
              tooltip: 'Copy',
            ),
          if (onRegenerate != null)
            _ActionButton(
              icon: Icons.refresh_rounded,
              onTap: onRegenerate,
              tooltip: 'Regenerate',
            ),
          if (onSaveToNotes != null)
            _ActionButton(
              icon: Icons.note_add_rounded,
              onTap: onSaveToNotes,
              tooltip: 'Save to Notes',
            ),
          if (onShare != null)
            _ActionButton(
              icon: Icons.share_rounded,
              onTap: onShare,
              tooltip: 'Share',
            ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);

    if (isUser) {
      return Text(
        text,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onPrimary,
          height: 1.5,
        ),
      );
    }

    return MarkdownBody(
      data: text,
      selectable: true,
      styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
        p: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurface,
          height: 1.6,
        ),
        h1: theme.textTheme.headlineSmall?.copyWith(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
        h2: theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        h3: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        code: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontFamily: 'monospace',
        ),
        codeblockDecoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        codeblockPadding: const EdgeInsets.all(16),
        blockquote: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontStyle: FontStyle.italic,
        ),
        blockquoteDecoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: theme.colorScheme.primary,
              width: 4,
            ),
          ),
        ),
        blockquotePadding: const EdgeInsets.only(left: 16),
        listBullet: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
      ),
      onTapLink: (url, _, __) {
        // Handle link tap
      },
    );
  }

  Widget _buildTypingIndicator(BuildContext context) {
    return const TypingIndicator();
  }
}

class _Avatar extends StatelessWidget {
  final bool isUser;
  final bool isStreaming;

  const _Avatar({required this.isUser, this.isStreaming = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isUser
            ? theme.gradients.primary
            : LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
      ),
      child: Center(
        child: isStreaming
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.onPrimary),
                ),
              )
            : Icon(
                isUser ? Icons.person_rounded : Icons.smart_toy_rounded,
                size: 18,
                color: theme.colorScheme.onPrimary,
              ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String? tooltip;

  const _ActionButton({
    required this.icon,
    this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// Typing indicator animation
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final delay = index * 0.2;
              final value = (_controller.value - delay) % 1.0;
              final opacity = (value * 3).clamp(0.0, 1.0);
              final scale = 0.5 + (value * 2).clamp(0.0, 0.5);

              return Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

/// Streaming text widget for typewriter effect
class StreamingText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration characterDelay;
  final VoidCallback? onComplete;

  const StreamingText({
    super.key,
    required this.text,
    this.style,
    this.characterDelay = const Duration(milliseconds: 20),
    this.onComplete,
  });

  @override
  State<StreamingText> createState() => _StreamingTextState();
}

class _StreamingTextState extends State<StreamingText> {
  String _displayedText = '';

  @override
  void initState() {
    super.initState();
    _startStreaming();
  }

  void _startStreaming() async {
    for (int i = 0; i <= widget.text.length; i++) {
      if (!mounted) return;
      await Future.delayed(widget.characterDelay);
      if (!mounted) return;
      setState(() {
        _displayedText = widget.text.substring(0, i);
      });
    }
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayedText,
      style: widget.style,
    );
  }
}
