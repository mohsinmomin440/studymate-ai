// Settings screen - Phase 8A Implementation

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:studymate_ai/core/constants/app_constants.dart';
import 'package:studymate_ai/core/services/notification_service.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../domain/settings_models.dart';
import '../data/settings_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settingsAsync = ref.watch(userSettingsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: settingsAsync.when(
        data: (settings) => _buildSettingsList(context, ref, settings),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Text(
            'Failed to load settings',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsList(
      BuildContext context, WidgetRef ref, UserSettings settings) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(userSettingsStreamProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader(title: 'Preferences'),
          const Gap(16),
          _buildThemeSection(context, settings),
          const Gap(16),
          _buildLanguageSection(context, settings),
          const Gap(16),
          _buildDailyGoalSection(context, settings),
          const Gap(16),
          _buildReminderSection(context, settings),
          const Gap(16),
          _buildNotificationsSection(context),
          const Gap(16),
          _buildAISettingsSection(context, settings),
          const Gap(32),
          const SectionHeader(title: 'Account'),
          const Gap(16),
          _buildAccountSection(context),
          const Gap(32),
          const SectionHeader(title: 'About'),
          const Gap(16),
          _buildAboutSection(context),
        ],
      ),
    );
  }

  Widget _buildThemeSection(BuildContext context, UserSettings settings) {
    final theme = Theme.of(context);
    final currentTheme = settings.theme;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Theme',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(12),
          Row(
            children: [
              _buildThemeOption(
                context,
                title: 'Light',
                icon: Icons.light_mode_rounded,
                isSelected: currentTheme == 'light',
                onTap: () => _updateSetting(context, 'theme', 'light'),
              ),
              const Gap(12),
              _buildThemeOption(
                context,
                title: 'Dark',
                icon: Icons.dark_mode_rounded,
                isSelected: currentTheme == 'dark',
                onTap: () => _updateSetting(context, 'theme', 'dark'),
              ),
              const Gap(12),
              _buildThemeOption(
                context,
                title: 'System',
                icon: Icons.auto_mode_rounded,
                isSelected: currentTheme == 'system',
                onTap: () => _updateSetting(context, 'theme', 'system'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const Gap(8),
              Text(
                title,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSection(BuildContext context, UserSettings settings) {
    final theme = Theme.of(context);
    final languages = [
      ('en', 'English'),
      ('gu', 'ગુજરાતી'),
      ('hi', 'हिंदी'),
    ];
    final currentLang = settings.language;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'App Language',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(8),
          Text(
            'Changes the language of the app interface',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Gap(12),
          Column(
            children: languages.map((lang) {
              final value = lang.$1;
              final label = lang.$2;

              return RadioListTile<String>(
                value: value,
                groupValue: currentLang,
                title: Text(
                  label,
                  style: theme.textTheme.bodyMedium,
                ),
                onChanged: (v) {
                  if (v != null) _updateSetting(context, 'language', v);
                },
                activeColor: theme.colorScheme.primary,
                contentPadding: EdgeInsets.zero,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyGoalSection(BuildContext context, UserSettings settings) {
    final theme = Theme.of(context);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Study Goal',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(8),
          Text(
            '${settings.dailyGoalMin} minutes per day',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(12),
          Slider(
            value: settings.dailyGoalMin.toDouble(),
            min: 15,
            max: 180,
            divisions: 33,
            label: '${settings.dailyGoalMin} min',
            onChanged: (v) =>
                _updateSetting(context, 'dailyGoalMin', v.round()),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderSection(BuildContext context, UserSettings settings) {
    final theme = Theme.of(context);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Study Reminders',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(8),
          ListTile(
            leading: Icon(
              settings.notificationsEnabled
                  ? Icons.notifications_rounded
                  : Icons.notifications_none_rounded,
              color: theme.colorScheme.primary,
            ),
            title: Text(
              'Enable Notifications',
              style: theme.textTheme.bodyLarge,
            ),
            trailing: Switch(
              value: settings.notificationsEnabled,
              onChanged: (v) =>
                  _updateSetting(context, 'notificationsEnabled', v),
            ),
          ),
          const Gap(8),
          if (settings.notificationsEnabled)
            ListTile(
              leading: const Icon(Icons.access_time_rounded),
              title: Text(
                'Reminder Time',
                style: theme.textTheme.bodyMedium,
              ),
              subtitle: settings.reminderTimeHour != null
                  ? Text(
                      '${settings.reminderTimeHour}:${settings.reminderTimeMinute!.toString().padLeft(2, '0')}')
                  : const Text('Not set'),
              trailing: IconButton(
                icon: const Icon(Icons.edit_rounded, size: 20),
                onPressed: () => _showTimePicker(context),
              ),
            ),
        ],
      ),
    );
  }

  void _showTimePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _TimePickerDialog(),
    );
  }

  Widget _buildNotificationsSection(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notifications',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(8),
          SwitchListTile(
            title: const Text('Streak reminders'),
            subtitle: const Text('Get notified to maintain your study streak'),
            value: true,
            onChanged: (__) {},
            secondary: const Icon(Icons.local_fire_department_rounded),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Daily goal reminders'),
            subtitle: const Text('Be reminded when you reach your daily goal'),
            value: false,
            onChanged: (__) {},
            secondary: const Icon(Icons.flag_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildAISettingsSection(BuildContext context, UserSettings settings) {
    final theme = Theme.of(context);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Settings',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(12),
          _buildAiLanguageRow(context, settings),
          const Gap(16),
          Text(
            'Response Style',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AiStyles.styles.map((style) {
              final isSelected = settings.aiResponseStyle == style;
              return FilterChip(
                selected: isSelected,
                label: Text(AiStyles.styleLabels[style] ?? style),
                onSelected: (selected) {
                  if (selected) {
                    _updateSetting(context, 'aiResponseStyle', style);
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAiLanguageRow(BuildContext context, UserSettings settings) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            'AI Response Language',
            style: theme.textTheme.bodyMedium,
          ),
        ),
        DropdownButton<String>(
          value: settings.aiResponseLanguage,
          items: AiLanguages.languages.map((lang) {
            return DropdownMenuItem(
              value: lang,
              child: Text(AiLanguages.languageLabels[lang] ?? lang),
            );
          }).toList(),
          onChanged: (v) {
            if (v != null) _updateSetting(context, 'aiResponseLanguage', v);
          },
        ),
      ],
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Icon(
              Icons.person_rounded,
              color: theme.colorScheme.primary,
            ),
            title: Text(
              'Edit Profile',
              style: theme.textTheme.bodyLarge,
            ),
            trailing: Icon(Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant),
            onTap: () {
              // Navigate to profile edit
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.link_rounded,
              color: theme.colorScheme.primary,
            ),
            title: Text(
              'Link Account',
              style: theme.textTheme.bodyLarge,
            ),
            subtitle: const Text('Link Google or Email for data backup'),
            trailing: Icon(Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant),
            onTap: () {
              final user = FirebaseAuth.instance.currentUser;
              if (user?.isAnonymous == true) {
                _showLinkAccountDialog(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Account already linked'),
                  ),
                );
              }
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.logout_rounded,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            title: Text(
              'Sign Out',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: Icon(Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant),
            onTap: () {
              FirebaseAuth.instance.signOut();
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.delete_rounded,
              color: Colors.red,
            ),
            title: Text(
              'Delete Account & Data',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Icon(Icons.chevron_right_rounded, color: Colors.red),
            onTap: () {
              _showDeleteAccountDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showLinkAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _LinkAccountDialog(),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _DeleteAccountConfirmDialog(),
    );
  }

  void _updateSetting(BuildContext context, String field, dynamic value) async {
    final repo =
        ProviderScope.containerOf(context).read(settingsRepositoryProvider);
    try {
      await repo.updateSettingField(field, value);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update: $e')),
      );
    }
  }
}

Widget _buildAboutSection(BuildContext context) {
  final theme = Theme.of(context);

  return Column(
    children: [
      GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(
                Icons.info_rounded,
                color: theme.colorScheme.primary,
              ),
              title: Text(
                'About StudyMate AI',
                style: theme.textTheme.bodyLarge,
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => const _AboutDialog(),
                );
              },
            ),
          ],
        ),
      ),
      const Gap(12),
      GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(
                Icons.privacy_tip_rounded,
                color: theme.colorScheme.primary,
              ),
              title: Text(
                'Privacy Policy',
                style: theme.textTheme.bodyLarge,
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                launchUrl(Uri.parse('https://studymate.ai/privacy'));
              },
            ),
          ],
        ),
      ),
      const Gap(12),
      GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(
                Icons.rate_review_rounded,
                color: theme.colorScheme.primary,
              ),
              title: Text(
                'Rate App',
                style: theme.textTheme.bodyLarge,
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                launchUrl(
                  Uri.parse('market://details?id=${AppConstants.packageName}'),
                );
              },
            ),
          ],
        ),
      ),
      const Gap(12),
      GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(
                Icons.send_rounded,
                color: theme.colorScheme.primary,
              ),
              title: Text(
                'Send Feedback',
                style: theme.textTheme.bodyLarge,
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Share.share('Feedback for StudyMate AI');
              },
            ),
          ],
        ),
      ),
      const Gap(12),
      GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(
                Icons.share_rounded,
                color: theme.colorScheme.primary,
              ),
              title: Text(
                'Share App',
                style: theme.textTheme.bodyLarge,
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Share.share(
                  'Check out StudyMate AI! https://play.google.com/store/apps/details?id=${AppConstants.packageName}',
                );
              },
            ),
          ],
        ),
      ),
    ],
  );
}

class _TimePickerDialog extends StatefulWidget {
  const _TimePickerDialog();

  @override
  State<_TimePickerDialog> createState() => _TimePickerDialogState();
}

class _TimePickerDialogState extends State<_TimePickerDialog> {
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Reminder Time'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.access_time_rounded),
            title: const Text('Reminder Time'),
            subtitle: Text(
              '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            onTap: () {
              showTimePicker(
                context: context,
                initialTime: _selectedTime,
              ).then((time) {
                if (time != null) {
                  setState(() => _selectedTime = time);
                }
              });
            },
          ),
          const Gap(16),
          ElevatedButton(
            onPressed: () {
              // Save settings
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _LinkAccountDialog extends ConsumerStatefulWidget {
  const _LinkAccountDialog();

  @override
  ConsumerState<_LinkAccountDialog> createState() => _LinkAccountDialogState();
}

class _LinkAccountDialogState extends ConsumerState<_LinkAccountDialog> {
  bool _isLoading = false;

  Future<void> _linkWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await user.linkWithCredential(credential);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account linked successfully')),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to link account: ${e.message}')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to link account: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Link Account'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(
              Icons.local_fire_department_rounded,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Google'),
            onTap: _isLoading ? null : _linkWithGoogle,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.email_rounded),
            title: const Text('Email'),
            enabled: false,
            trailing: const Icon(Icons.lock_rounded, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}

class _DeleteAccountConfirmDialog extends ConsumerStatefulWidget {
  const _DeleteAccountConfirmDialog();

  @override
  ConsumerState<_DeleteAccountConfirmDialog> createState() =>
      _DeleteAccountConfirmDialogState();
}

class _DeleteAccountConfirmDialogState
    extends ConsumerState<_DeleteAccountConfirmDialog> {
  bool _isDeleting = false;
  String _deleteMethod = 'full';

  @override
  void initState() {
    super.initState();
    _checkDeleteMethod();
  }

  Future<void> _checkDeleteMethod() async {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _deleteMethod = user?.isAnonymous == true ? 'full' : 'full';
    });
  }

  Future<void> _deleteAccount() async {
    setState(() => _isDeleting = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      final uid = user?.uid;

      if (uid == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user to delete')),
        );
        setState(() => _isDeleting = false);
        return;
      }

      await _performDelete(uid);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account and data deleted successfully')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      String errorMsg = 'Delete failed: $e';

      if (e.toString().contains('requires-recent-login')) {
        setState(() {
          _deleteMethod = 'requires_recent_login';
        });
        errorMsg = 'Please sign in again to delete your account';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  Future<void> _performDelete(String uid) async {
    // Delete all subcollections first
    final batch = FirebaseFirestore.instance.batch();
    int deleteCount = 0;

    // List of collections to delete
    final collections = [
      'users/$uid/chats',
      'users/$uid/doubts',
      'users/$uid/notes',
      'users/$uid/decks',
      'users/$uid/quizzes',
      'users/$uid/quizAttempts',
      'users/$uid/plans',
      'users/$uid/dailyStats',
      'users/$uid/badges',
    ];

    // Delete main collections
    for (final collection in collections) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection(collection.substring(8))
          .get();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
        deleteCount++;
      }
    }

    // Delete nested messages in chats
    final chatsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('chats')
        .get();
    for (final chatDoc in chatsSnapshot.docs) {
      final messagesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('chats')
          .doc(chatDoc.id)
          .collection('messages')
          .get();
      for (final msgDoc in messagesSnapshot.docs) {
        batch.delete(msgDoc.reference);
        deleteCount++;
      }
    }

    // Delete nested cards in decks
    final decksSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('decks')
        .get();
    for (final deckDoc in decksSnapshot.docs) {
      final cardsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('decks')
          .doc(deckDoc.id)
          .collection('cards')
          .get();
      for (final cardDoc in cardsSnapshot.docs) {
        batch.delete(cardDoc.reference);
        deleteCount++;
      }
    }

    if (deleteCount > 0) {
      await batch.commit();
    }

    // Delete user document
    await FirebaseFirestore.instance.collection('users').doc(uid).delete();

    // Cancel all scheduled notifications
    await NotificationService().cancelAllNotifications();

    // Delete auth account
    await FirebaseAuth.instance.currentUser?.delete();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Delete Account'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning_rounded,
            color: Colors.red,
            size: 48,
          ),
          const Gap(16),
          Text(
            'This will permanently delete all your data:',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(8),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '• Profile information\n'
              '• All study chats and messages\n'
              '• Notes and flashcards\n'
              '• Quiz history and attempts\n'
              '• Study plans and progress\n'
              '• All daily statistics',
            ),
          ),
          const Gap(16),
          Text(
            _deleteMethod == 'requires_recent_login'
                ? 'Please sign in again to confirm account deletion.'
                : 'This action cannot be undone. You will lose all saved data.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isDeleting
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _isDeleting ? null : _deleteAccount,
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: _isDeleting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Delete My Account'),
        ),
      ],
    );
  }
}

class _AboutDialog extends StatelessWidget {
  const _AboutDialog();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.school_rounded,
            color: theme.colorScheme.primary,
          ),
          const Gap(8),
          const Text('StudyMate AI'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Version ${AppConstants.version}',
            style: theme.textTheme.bodyMedium,
          ),
          const Gap(8),
          const Text(
            'Learn smarter with AI-powered tutoring. Features include:',
          ),
          const Gap(8),
          const Text('• AI Tutor Chat with Gemini'),
          const Text('• Flashcards with SM-2 scheduling'),
          const Text('• Quiz Generator'),
          const Text('• Study Planner'),
          const Text('• Progress Tracking & Gamification'),
          const Gap(16),
          const Text(
            '© 2024 StudyMate AI\n'
            'All rights reserved',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
