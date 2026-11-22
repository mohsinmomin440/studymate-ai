// Settings screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../core/constants/app_constants.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionHeader(title: 'Settings'),
        const Gap(16),
        _buildSettingCard(
          context: context,
          icon: Icons.description,
          title: 'About',
          subtitle: 'App version ${AppConstants.version}',
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const AboutDialog(),
            );
          },
        ),
        const Gap(12),
        _buildSettingCard(
          context: context,
          icon: Icons.privacy_tip,
          title: 'Privacy Policy',
          onTap: () {
            // Open privacy policy URL
          },
        ),
        const Gap(12),
        _buildSettingCard(
          context: context,
          icon: Icons.rate_review,
          title: 'Rate App',
          onTap: () {
            // Open Play Store
          },
        ),
        const Gap(12),
        _buildSettingCard(
          context: context,
          icon: Icons.feedback,
          title: 'Send Feedback',
          onTap: () {
            // Open feedback form
          },
        ),
        const Gap(24),
        const SectionHeader(title: 'Account'),
        const Gap(16),
        _buildSettingCard(
          context: context,
          icon: Icons.person,
          title: 'Edit Profile',
          onTap: () {
            // Navigate to profile edit
          },
        ),
        const Gap(12),
        _buildSettingCard(
          context: context,
          icon: Icons.link,
          title: 'Link Account',
          onTap: () {
            // Show link account dialog
          },
        ),
        const Gap(12),
        _buildSettingCard(
          context: context,
          icon: Icons.delete,
          title: 'Delete Account & Data',
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const DeleteAccountDialog(),
            );
          },
        ),
        const Gap(12),
        _buildSettingCard(
          context: context,
          icon: Icons.logout,
          title: 'Sign Out',
          onTap: () async {
            await FirebaseAuth.instance.signOut();
          },
        ),
      ],
    );
  }

  Widget _buildSettingCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
            ),
            child: Icon(icon,
                size: 24, color: Theme.of(context).colorScheme.onPrimary),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}

class DeleteAccountDialog extends ConsumerStatefulWidget {
  const DeleteAccountDialog({super.key});

  @override
  ConsumerState<DeleteAccountDialog> createState() =>
      _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<DeleteAccountDialog> {
  bool _isDeleting = false;

  Future<void> _deleteAccount() async {
    setState(() => _isDeleting = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      final uid = user?.uid;

      if (uid != null) {
        // Delete all user data from Firestore
        final batch = FirebaseFirestore.instance.batch();
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

        for (final collection in collections) {
          final snapshot =
              await FirebaseFirestore.instance.collection(collection).get();
          for (final doc in snapshot.docs) {
            batch.delete(doc.reference);
          }
        }

        await batch.commit();

        // Delete user document
        await FirebaseFirestore.instance.collection('users').doc(uid).delete();

        // Delete auth account
        await user?.delete();
      }

      if (!mounted) return;
      Navigator.of(context).pop(); // Close dialog
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Account'),
      content: const Text(
        'This will permanently delete all your data including:\n'
        '- Profile\n'
        '- Chats\n'
        '- Notes\n'
        '- Flashcards\n'
        '- Quiz history\n'
        '- Study plans\n'
        'Are you sure?',
      ),
      actions: [
        TextButton(
          onPressed: _isDeleting ? null : () => Navigator.of(context).pop(),
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

class AboutDialog extends StatelessWidget {
  const AboutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('StudyMate AI'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Version: ${AppConstants.version}',
              style: Theme.of(context).textTheme.bodyMedium),
          const Gap(8),
          const Text('Learn smarter with AI-powered tutoring.'),
          const Gap(8),
          const Text('Features:'),
          const Gap(4),
          const Text(
              '• AI Tutor Chat\n• Flashcards with SM-2\n• Quiz Generator\n• Study Planner\n• Progress Tracking'),
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
