import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/gap.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Auth screen with Google, Email/Password, and Guest sign-in
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      if (mounted) context.go(AppRoutes.profileSetup);
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        _showError(e.message ?? l10n.googleSignInFailed);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInAsGuest() async {
    setState(() => _isLoading = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      await FirebaseAuth.instance.signInAnonymously();
      if (mounted) context.go(AppRoutes.profileSetup);
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        _showError(e.message ?? l10n.guestSignInFailed);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Gap(40),
              Icon(
                Icons.school_rounded,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const Gap(32),
              Text(
                l10n.welcomeBack,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(16),
              Text(
                l10n.letsStudy,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(48),
              _AuthButton(
                icon: Icons.g_mobiledata_rounded,
                label: l10n.googleSignIn,
                onPressed: _isLoading ? null : _signInWithGoogle,
                isLoading: _isLoading,
              ),
              const Gap(16),
              _AuthButton(
                icon: Icons.person_outline_rounded,
                label: l10n.continueAsGuest,
                onPressed: _isLoading ? null : _signInAsGuest,
                isLoading: _isLoading,
                variant: _AuthButtonVariant.secondary,
              ),
              const Gap(32),
              Text(
                l10n.termsOfService,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _AuthButtonVariant { primary, secondary }

class _AuthButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final _AuthButtonVariant variant;

  const _AuthButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.isLoading,
    this.variant = _AuthButtonVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    final isPrimary = variant == _AuthButtonVariant.primary;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: isPrimary
          ? FilledButton.icon(
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(icon),
              label: Text(label),
              onPressed: onPressed,
            )
          : OutlinedButton.icon(
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(icon),
              label: Text(label),
              onPressed: onPressed,
            ),
    );
  }
}

