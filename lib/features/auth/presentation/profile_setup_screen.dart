import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/gap.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Profile setup screen after first sign-in
class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedGrade = '10';
  String _selectedLanguage = 'en';
  int _dailyGoal = 30;
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

  static const _languages = [
    ('en', 'English'),
    ('gu', 'ગુજરાતી'),
    ('hi', 'हिंदी'),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  final _passwordController = TextEditingController();

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': _nameController.text.trim(),
        'grade': _selectedGrade,
        'language': _selectedLanguage,
        'dailyGoalMin': _dailyGoal,
        'xp': 0,
        'level': 1,
        'streak': 0,
        'lastStudyDate': null,
        'createdAt': FieldValue.serverTimestamp(),
        'settings': {
          'theme': 'system',
          'notifications': true,
          'aiResponseLanguage': _selectedLanguage,
        },
      }, SetOptions(merge: true));

      if (!mounted) return;
      context.go(AppRoutes.home);
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.failedToUpdate(e))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _linkAccount() async {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => const _EmailLinkDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(16),
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const Gap(8),
                Text(
                  l10n.profileSetup,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(8),
                Text(
                  l10n.helpPersonalize,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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
                      return l10n.enterName;
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
                  items: _languages
                      .map((l) =>
                          DropdownMenuItem(value: l.$1, child: Text(l.$2)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedLanguage = v!),
                ),
                const Gap(24),
                Text(
                  l10n.dailyStudyGoalMinutes,
                  style: theme.textTheme.titleMedium,
                ),
                const Gap(12),
                Slider(
                  value: _dailyGoal.toDouble(),
                  min: 10,
                  max: 120,
                  divisions: 11,
                  label: '$_dailyGoal ${l10n.min}',
                  onChanged: (v) => setState(() => _dailyGoal = v.round()),
                ),
                const Gap(32),
                if (user?.isAnonymous == true) ...[
                  OutlinedButton.icon(
                    onPressed: _linkAccount,
                    icon: const Icon(Icons.link_rounded),
                    label: Text(l10n.linkGoogleEmail),
                  ),
                  const Gap(16),
                  Text(
                    l10n.linkAccountWarning,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Gap(16),
                ],
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

/// Dialog for linking email/password to anonymous account
class _EmailLinkDialog extends StatefulWidget {
  const _EmailLinkDialog();

  @override
  State<_EmailLinkDialog> createState() => _EmailLinkDialogState();
}

class _EmailLinkDialogState extends State<_EmailLinkDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _link(BuildContext dialogContext) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final credential = EmailAuthProvider.credential(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      await user.linkWithCredential(credential);
      if (mounted) {
        Navigator.pop(context);
        final l10n = AppLocalizations.of(dialogContext)!;
        ScaffoldMessenger.of(dialogContext).showSnackBar(
          SnackBar(content: Text(l10n.accountLinkedSuccessfully)),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(dialogContext)!;
        ScaffoldMessenger.of(dialogContext).showSnackBar(
          SnackBar(content: Text(e.message ?? l10n.failedToLoadSettings)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Builder(
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.linkEmailAccount),
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
                  if (!value.contains('@')) {
                    return l10n.validEmail;
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
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.enterPassword;
                  }
                  if (value.length < 6) {
                    return l10n.passwordMin6;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: _isLoading ? null : () => _link(dialogContext),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.linkGoogle),
          ),
        ],
      ),
    );
  }
}
