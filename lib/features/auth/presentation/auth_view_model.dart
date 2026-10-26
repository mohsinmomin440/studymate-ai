import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_provider.dart';
import '../data/auth_repository.dart';
import '../domain/app_user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthRepositoryImpl(prefs);
});

class AuthState {
  final bool isLoading;
  final AppUser? user;
  final String? errorMessage;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.errorMessage,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    bool? isLoading,
    AppUser? user,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    final repo = ref.watch(authRepositoryProvider);
    return AuthState(user: repo.currentUser);
  }

  Future<bool> signIn({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.signIn(email: email, password: password);
      state = state.copyWith(isLoading: false, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _formatErrorMessage(e),
      );
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      state = state.copyWith(isLoading: false, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _formatErrorMessage(e),
      );
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.signInWithGoogle();
      if (user == null) {
        // User cancelled the Google sign-in dialog
        state = state.copyWith(isLoading: false);
        return false;
      }
      state = state.copyWith(isLoading: false, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _formatErrorMessage(e),
      );
      return false;
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.sendPasswordResetEmail(email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _formatErrorMessage(e),
      );
      return false;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    final repo = ref.read(authRepositoryProvider);
    await repo.signOut();
    state = const AuthState();
  }

  String _formatErrorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email. Please sign up first.';
        case 'wrong-password':
        case 'invalid-credential':
          return 'Invalid email or password. Please verify your credentials.';
        case 'email-already-in-use':
          return 'This email is already registered. Please log in instead.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'weak-password':
          return 'Password should be at least 6 characters.';
        case 'user-disabled':
          return 'This user account has been disabled.';
        case 'operation-not-allowed':
          return 'This sign-in method is not enabled in Firebase Console.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again after a few moments.';
        case 'account-exists-with-different-credential':
          return 'An account already exists with the same email using a different sign-in method.';
        default:
          return error.message ?? 'Authentication error (${error.code}).';
      }
    }

    final raw = error.toString();
    if (raw.contains('12500') || raw.contains('ApiException: 10')) {
      return 'Google Sign-In configuration error: Please verify SHA-1 key in Firebase Console.';
    }
    if (raw.contains('network') || raw.contains('SocketException')) {
      return 'Network connection error. Please verify your internet connection.';
    }
    return raw.replaceAll('Exception:', '').trim();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
