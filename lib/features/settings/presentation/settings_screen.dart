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
import 'package:studymate_ai/core/services/auth_service.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../domain/settings_models.dart';
import '../data/settings_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final settingsAsync = ref.watch(userSettingsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        centerTitle: true,
      ),
      body: settingsAsync.when(
        data: (settings) => _buildSettingsList(context, ref, settings, l10n),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Text(
            l10n.failedToLoadSettings,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context, WidgetRef ref,
      UserSettings settings, AppLocalizations l10n) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(userSettingsStreamProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionHeader(title: l10n.preferences),
          const Gap(16),
          _buildThemeSection(context, settings, l10n),
          const Gap(16),
          _buildLanguageSection(context, settings, l10n),
          const Gap(16),
          _buildDailyGoalSection(context, settings, l10n),
          const Gap(16),
          _buildReminderSection(context, settings, l10n),
          const Gap(16),
          _buildNotificationsSection(context),
          const Gap(16),
          _buildAISettingsSection(context, settings, l10n),
          const Gap(32),
          SectionHeader(title: l10n.account),
          const Gap(16),
          _buildAccountSection(context, l10n),
          const Gap(32),
          SectionHeader(title: l10n.about),
          const Gap(16),
          _buildAboutSection(context, l10n),
        ],
      ),
    );
  }

  Widget _buildThemeSection(
      BuildContext context, UserSettings settings, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final currentTheme = settings.theme;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.theme,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(12),
          Row(
            children: [
              _buildThemeOption(
                context,
                title: l10n.lightMode,
                icon: Icons.light_mode_rounded,
                isSelected: currentTheme == 'light',
                onTap: () => _updateSetting(context, 'theme', 'light'),
              ),
              const Gap(12),
              _buildThemeOption(
                context,
                title: l10n.darkMode,
                icon: Icons.dark_mode_rounded,
                isSelected: currentTheme == 'dark',
                onTap: () => _updateSetting(context, 'theme', 'dark'),
              ),
              const Gap(12),
              _buildThemeOption(
                context,
                title: l10n.systemTheme,
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

  Widget _buildLanguageSection(
      BuildContext context, UserSettings settings, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final languages = [
      ('en', l10n.english),
      ('gu', l10n.gujarati),
      ('hi', l10n.hindi),
    ];
    final currentLang = settings.language;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.language,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(8),
          Text(
            l10n.appLanguage,
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

  Widget _buildDailyGoalSection(
      BuildContext context, UserSettings settings, AppLocalizations l10n) {
    final theme = Theme.of(context);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.dailyGoal,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(8),
          Text(
            '${settings.dailyGoalMin} ${l10n.minutes} ${l10n.perDay}',
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
            label: '${settings.dailyGoalMin} ${l10n.min}',
            onChanged: (v) =>
                _updateSetting(context, 'dailyGoalMin', v.round()),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderSection(
      BuildContext context, UserSettings settings, AppLocalizations l10n) {
    final theme = Theme.of(context);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.notifications,
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
              l10n.notificationStudyReminder,
              style: theme.textTheme.bodyLarge,
            ),
            trailing: Switch(
              value: settings.notificationsEnabled,
              onChanged: (v) {
                if (!context.mounted) return;
                _updateSetting(context, 'notificationsEnabled', v).then((_) {
                  if (!context.mounted) return;
                  if (v && settings.reminderTimeHour != null) {
                    _scheduleReminder(context, settings);
                  }
                });
              },
            ),
          ),
          const Gap(8),
          if (settings.notificationsEnabled)
            ListTile(
              leading: const Icon(Icons.access_time_rounded),
              title: Text(
                l10n.notificationDailySession,
                style: theme.textTheme.bodyMedium,
              ),
              subtitle: settings.reminderTimeHour != null
                  ? Text(
                      '${settings.reminderTimeHour.toString().padLeft(2, '0')}:${settings.reminderTimeMinute!.toString().padLeft(2, '0')}')
                  : Text(
                      l10n.notSet,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
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

  Future<void> _scheduleReminder(
      BuildContext context, UserSettings settings) async {
    final l10n = AppLocalizations.of(context)!;
    final hour = settings.reminderTimeHour;
    final minute = settings.reminderTimeMinute;
    if (hour == null || minute == null) return;

    final notificationService = NotificationService();
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    try {
      await notificationService.scheduleDailyNotification(
        id: 100,
        title: l10n.notificationStudyReminder,
        body: l10n.notificationDailySession,
        hour: hour,
        minute: minute,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.failedToSend(e))),
      );
    }
  }

  Widget _buildNotificationsSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.notifications,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
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

  Widget _buildAISettingsSection(
      BuildContext context, UserSettings settings, AppLocalizations l10n) {
    final theme = Theme.of(context);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.aiResponseLanguage,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(12),
          _buildAiLanguageRow(context, settings, l10n),
          const Gap(16),
          Text(
            l10n.aiResponseStyle,
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

  Widget _buildAiLanguageRow(
      BuildContext context, UserSettings settings, AppLocalizations l10n) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.aiResponseLanguage,
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

  Widget _buildAccountSection(BuildContext context, AppLocalizations l10n) {
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
              l10n.editProfile,
              style: theme.textTheme.bodyLarge,
            ),
            trailing: Icon(Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.link_rounded,
              color: theme.colorScheme.primary,
            ),
            title: Text(
              l10n.linkAccount,
              style: theme.textTheme.bodyLarge,
            ),
            subtitle: Text(
              l10n.linkGoogleEmail,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: Icon(Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant),
            onTap: () {
              final user = FirebaseAuth.instance.currentUser;
              if (user?.isAnonymous == true) {
                _showLinkAccountDialog(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.accountAlreadyLinked)),
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
              l10n.signOut,
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
              l10n.deleteMyAccount,
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Icon(Icons.chevron_right_rounded, color: Colors.red),
            onTap: () {
              _showDeleteAccountDialog(context, l10n);
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

  void _showDeleteAccountDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => _DeleteAccountConfirmDialog(l10n: l10n),
    );
  }

  Future<void> _updateSetting(
      BuildContext context, String field, dynamic value) async {
    final l10n = AppLocalizations.of(context)!;
    final repo =
        ProviderScope.containerOf(context).read(settingsRepositoryProvider);
    try {
      await repo.updateSettingField(field, value);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.failedToSend(e.toString()))),
      );
    }
  }
}

Widget _buildAboutSection(BuildContext context, AppLocalizations l10n) {
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
                l10n.privacyPolicyScreen,
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
                l10n.privacyPolicy,
                style: theme.textTheme.bodyLarge,
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PrivacyPolicyScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      const Gap(12),
      Builder(
        builder: (context) {
          return GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: Icon(
                    Icons.rate_review_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(
                    l10n.rateApp,
                    style: theme.textTheme.bodyLarge,
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    launchUrl(Uri.parse(
                        'market://details?id=${AppConstants.packageName}'));
                  },
                ),
              ],
            ),
          );
        },
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
                l10n.feedback,
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
                l10n.shareApp,
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
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.editProfile),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.access_time_rounded),
            title: Text(l10n.notificationDailySession),
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
              final hour = _selectedTime.hour;
              final minute = _selectedTime.minute;
              Navigator.of(context).pop([hour, minute]);
            },
            child: Text(l10n.save),
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
    final l10n = AppLocalizations.of(context)!;
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
        SnackBar(content: Text(l10n.accountLinkedSuccessfully)),
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(l10n.linkAccount),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(
              Icons.account_circle_rounded,
              color: theme.colorScheme.primary,
            ),
            title: Text(l10n.linkGoogle),
            onTap: _isLoading ? null : _linkWithGoogle,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.email_rounded),
            title: Text(l10n.linkEmailAccount),
            enabled: false,
            trailing: const Icon(Icons.lock_rounded, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
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

/// Helper function to chunk a list into batches
List<List<T>> chunkList<T>(List<T> list, int chunkSize) {
  final List<List<T>> result = [];
  for (var i = 0; i < list.length; i += chunkSize) {
    result.add(list.sublist(
        i, i + chunkSize > list.length ? list.length : i + chunkSize));
  }
  return result;
}

/// Delete operations chunked to max 400 per batch (Firestore limit)
const int maxBatchOperations = 400;

class _DeleteAccountConfirmDialog extends ConsumerStatefulWidget {
  final AppLocalizations l10n;

  const _DeleteAccountConfirmDialog({required this.l10n});

  @override
  ConsumerState<_DeleteAccountConfirmDialog> createState() =>
      _DeleteAccountConfirmDialogState();
}

class _DeleteAccountConfirmDialogState
    extends ConsumerState<_DeleteAccountConfirmDialog> {
  bool _isDeleting = false;
  String _error = '';
  AuthCredential? _reauthCredential;

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(l10n.deleteMyAccount),
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
            l10n.deleteAccountAndConfirm,
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
            _error.isNotEmpty ? _error : l10n.accountDeleteWarning,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (_error.isNotEmpty) ...[
            const Gap(8),
            TextButton(
              onPressed: _isDeleting ? null : _attemptReauthAndDelete,
              child: Text(l10n.reauthAndRetry),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isDeleting
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: Text(l10n.cancel),
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
              : Text(l10n.deleteAccountAndDelete),
        ),
      ],
    );
  }

  Future<void> _deleteAccount() async {
    final l10n = widget.l10n;
    setState(() {
      _isDeleting = true;
      _error = '';
    });

    final authRepo = ref.read(authRepositoryProvider);

    try {
      final result = await authRepo.deleteAccount(
        reauthCredential: _reauthCredential,
      );

      if (!mounted) return;

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.accountDeletedSuccessfully)),
        );
        Navigator.of(context).pop();
      } else if (result.needsReauth) {
        // Show re-auth prompt
        _showReauthDialog(l10n);
      } else {
        setState(() {
          _error = result.error ?? 'Delete failed';
          _isDeleting = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Delete failed: $e';
        _isDeleting = false;
      });
    }
  }

  void _showReauthDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => _ReauthDialog(
        l10n: l10n,
        onCredential: (credential) {
          _reauthCredential = credential;
          // Retry delete with the credential
          _deleteAccount();
        },
      ),
    );
  }

  Future<void> _attemptReauthAndDelete() async {
    final l10n = widget.l10n;
    setState(() => _isDeleting = true);

    final authRepo = ref.read(authRepositoryProvider);
    final credential = await authRepo.getReauthCredential();

    if (credential != null) {
      _reauthCredential = credential;
      await _deleteAccount();
    } else {
      // No credential obtained (Google cancelled, email/password needed)
      _showReauthDialog(l10n);
    }
  }
}

/// Re-authentication dialog for email/password
class _ReauthDialog extends ConsumerStatefulWidget {
  final AppLocalizations l10n;
  final void Function(AuthCredential) onCredential;

  const _ReauthDialog({required this.l10n, required this.onCredential});

  @override
  ConsumerState<_ReauthDialog> createState() => _ReauthDialogState();
}

class _ReauthDialogState extends ConsumerState<_ReauthDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(l10n.pleaseSignInAgainToDelete),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: l10n.email,
                prefixIcon: const Icon(Icons.email_rounded),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.enterEmail;
                }
                return null;
              },
            ),
            const Gap(16),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: l10n.password,
                prefixIcon: const Icon(Icons.lock_rounded),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.enterPassword;
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.signIn),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final credential = EmailAuthProvider.credential(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) {
        Navigator.of(context).pop();
        widget.onCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Re-authentication failed')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Re-authentication failed: $e')),
      );
    }
  }
}

class _AboutDialog extends StatelessWidget {
  const _AboutDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.school_rounded,
            color: theme.colorScheme.primary,
          ),
          const Gap(8),
          Text(l10n.appName),
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
          child: Text(l10n.done),
        ),
      ],
    );
  }
}

/// Edit Profile Screen
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedGrade = '10';
  String _selectedLanguage = 'en';
  int _dailyGoal = 60;
  String _selectedAvatar = 'A';
  bool _isLoading = false;

  static const _grades = [
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
    'UG 1',
    'UG 2',
    'UG 3',
    'UG 4',
    'PG 1',
    'PG 2',
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  void _loadCurrentSettings() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _nameController.text = user.displayName ?? '';
    // Load other settings from Firestore
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      await userDoc.update({
        'name': _nameController.text.trim(),
        'grade': _selectedGrade,
        'language': _selectedLanguage,
        'dailyGoalMin': _dailyGoal,
        'avatar': _selectedAvatar,
        'settings.dailyGoalMin': _dailyGoal,
        'settings.language': _selectedLanguage,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileUpdatedSuccessfully)),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editProfileTitle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(16),
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      _selectedAvatar,
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ),
                ),
                const Gap(8),
                const Center(
                  child: Text(
                    'Tap avatar to change',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
                const Gap(32),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.name,
                    prefixIcon: const Icon(Icons.person_rounded),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const Gap(24),
                Text(
                  l10n.classGrade,
                  style: theme.textTheme.titleMedium,
                ),
                const Gap(12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedGrade,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.school_rounded),
                  ),
                  items: _grades
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedGrade = v!),
                ),
                const Gap(24),
                Text(
                  l10n.appLanguage,
                  style: theme.textTheme.titleMedium,
                ),
                const Gap(12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedLanguage,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.language_rounded),
                  ),
                  items: AiLanguages.languages.map((lang) {
                    return DropdownMenuItem(
                      value: lang,
                      child: Text(AiLanguages.languageLabels[lang] ?? lang),
                    );
                  }).toList(),
                  onChanged: (v) =>
                      setState(() => _selectedLanguage = v ?? 'en'),
                ),
                const Gap(24),
                Text(
                  l10n.dailyStudyGoalMinutes,
                  style: theme.textTheme.titleMedium,
                ),
                const Gap(12),
                Slider(
                  value: _dailyGoal.toDouble(),
                  min: 15,
                  max: 180,
                  divisions: 33,
                  label: '$_dailyGoal ${l10n.min}',
                  onChanged: (v) => setState(() => _dailyGoal = v.round()),
                ),
                const Gap(32),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.save),
                  ),
                ),
                const Gap(24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Privacy Policy Screen
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.privacyPolicy),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.privacyPolicy,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(16),
              const Text(
                'StudyMate AI respects your privacy. Here\'s what we store '
                'and how we use it:',
              ),
              const Gap(16),
              Text(
                l10n.privacyPolicyDataStored,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(8),
              Text(
                l10n.privacyPolicyStudyData,
                style: theme.textTheme.bodyMedium,
              ),
              const Gap(16),
              Text(
                l10n.privacyPolicyDataProcessing,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(8),
              Text(
                l10n.privacyPolicyGemini,
                style: theme.textTheme.bodyMedium,
              ),
              const Gap(16),
              Text(
                l10n.privacyPolicyDeletion,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(8),
              Text(
                l10n.privacyPolicyDeleteAccount,
                style: theme.textTheme.bodyMedium,
              ),
              const Gap(16),
              Text(
                l10n.privacyPolicyDataLocation,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(8),
              Text(
                l10n.privacyPolicyLocation,
                style: theme.textTheme.bodyMedium,
              ),
              const Gap(32),
              OutlinedButton(
                onPressed: () {
                  // Navigate to settings to delete account
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.deleteMyAccount),
                    ),
                  );
                },
                child: Text(l10n.deleteMyAccount),
              ),
              const Gap(16),
            ],
          ),
        ),
      ),
    );
  }
}
