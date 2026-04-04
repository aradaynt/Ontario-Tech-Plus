// OntarioTechPlus - auth_providers.dart

// Auth providers uses Supabase and Riverpod

import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ontario_tech_plus/core/global_providers/supabase_provider.dart';

// Auth State Stream Provider (login/logout)
// Will listen for any future auth changes
final authStateProvider = StreamProvider<Session?>((ref) async* {
  final supabase = ref.watch(supabaseProvider);

  // Try to restore the session
  try {
    yield supabase.auth.currentSession;

    await for (final event in supabase.auth.onAuthStateChange) {
      yield event.session;
    }
  } catch (_) {
    // If restoring or listening to auth state fails, clear any stale
    // session and treat the user as signed out.
    await supabase.auth.signOut();
    yield null;
  }
});

/// Porvides the auth service to the app
final authServiceProvider = Provider<AuthService>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return AuthService(supabase);
});

// Stores a one time success message after a successful password change on the login page
final authStatusMessageProvider =
    NotifierProvider<AuthStatusMessageNotifier, String?>(
      AuthStatusMessageNotifier.new,
    );

// Redirect URL for password reset
const passwordResetRedirectUri = 'ontariotechplus://password-reset';

enum AuthAction { signIn, signUp, signOut, resetPassword, updatePassword }

class AuthFailure implements Exception {
  final String message;

  const AuthFailure(this.message);

  @override
  String toString() => message;
}

// Stores one-time auth messages. ex. password reset success
class AuthStatusMessageNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setMessage(String? message) {
    state = message;
  }

  void clear() {
    state = null;
  }
}

// Handles anyhthing related to authentication (signup, signin, signout)
class AuthService {
  final SupabaseClient _supabase;

  // Inject supabase client
  AuthService(this._supabase);

  // Creates a new user account
  Future<void> signUp(
    String email,
    String password,
    String firstName,
    String lastName,
    String studentNumber,
    String program,
    String faculty,
    String year,
  ) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'firstname': firstName,
          'lastname': lastName,
          'student_number': studentNumber,
          'program': program,
          'faculty': faculty,
          'year': year,
        },
      );

      if (response.user == null) {
        throw const AuthFailure(
          'Sign up could not be completed. Please try again.',
        );
      }
    } on AuthFailure {
      rethrow;
    } catch (error) {
      throw _mapAuthError(error, action: AuthAction.signUp);
    }
  }

  // Logs in an existing user
  Future<void> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const AuthFailure('Login failed. Please try again.');
      }
    } on AuthFailure {
      rethrow;
    } catch (error) {
      throw _mapAuthError(error, action: AuthAction.signIn);
    }
  }

  // Logs out the current user
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (error) {
      throw _mapAuthError(error, action: AuthAction.signOut);
    }
  }

  // Sends a password reset email if the account exists.
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: passwordResetRedirectUri,
      );
    } catch (error) {
      throw _mapAuthError(error, action: AuthAction.resetPassword);
    }
  }

  // Updates the current users password during recovery.
  Future<void> updatePassword(String password) async {
    try {
      await _supabase.auth.updateUser(UserAttributes(password: password));
    } catch (error) {
      throw _mapAuthError(error, action: AuthAction.updatePassword);
    }
  }

  // Handles mapping raw errors to user friendly messages
  AuthFailure _mapAuthError(Object error, {required AuthAction action}) {
    if (error is AuthFailure) {
      return error;
    }

    // Check if its a non-wrapped network error
    if (error is SocketException || error is TimeoutException) {
      return const AuthFailure(
        'No internet connection. Check your network and try again.',
      );
    }

    // Check if its a password strength error
    if (error is AuthWeakPasswordException) {
      return AuthFailure(
        error.reasons.isNotEmpty
            ? error.reasons.first
            : 'Password is too weak. Choose a stronger password.',
      );
    }

    // Otherwise send it to the friendly message helper
    if (error is AuthException) {
      return AuthFailure(_friendlyAuthMessage(error, action: action));
    }

    // Otherwise send a default message for given action
    return AuthFailure(_defaultMessageForAction(action));
  }

  // Handles the actual conversion from raw error to something friendly
  String _friendlyAuthMessage(
    AuthException error, {
    required AuthAction action,
  }) {
    final message = error.message.trim();
    final lowerMessage = message.toLowerCase();
    final code = error.code?.toLowerCase();
    final statusCode = error.statusCode;

    // Handles a duplicated student id (Its kind of a bad way to do this, but its easiest for now)
    if (action == AuthAction.signUp &&
        lowerMessage.contains('database error saving new user') &&
        (code == 'unexpected_failure' ||
            lowerMessage.contains('"code":"unexpected_failure"') ||
            lowerMessage.contains("'code':'unexpected_failure'") ||
            lowerMessage.contains('unexpected_failure'))) {
      return 'Student ID already exists.';
    }

    // Handle Supabase-wrapped network errors
    if (error is AuthRetryableFetchException &&
        (_looksLikeNetworkIssue(lowerMessage) ||
            (statusCode == null && message.isEmpty))) {
      return 'No internet connection. Check your network and try again.';
    }

    // Email not confirmed
    if (code == 'email_not_confirmed' ||
        lowerMessage.contains('email not confirmed')) {
      return 'Confirm your email address before signing in.';
    }

    // Invalid login
    if (code == 'invalid_credentials' ||
        lowerMessage.contains('invalid login credentials')) {
      return 'Incorrect email or password.';
    }

    // User already exists
    if (code == 'user_already_exists' ||
        lowerMessage.contains('user already registered') ||
        lowerMessage.contains('already registered')) {
      return 'An account with this email already exists.';
    }

    // Signup disabled
    if (code == 'signup_disabled' ||
        lowerMessage.contains('signups not allowed')) {
      return 'Sign up is currently unavailable.';
    }

    // Weak password
    if (code == 'weak_password' || lowerMessage.contains('weak password')) {
      return 'Password is too weak. Choose a stronger password.';
    }

    // Rate Limit error
    if (statusCode == '429' || lowerMessage.contains('rate limit')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }

    if (statusCode == '500' || statusCode == '503') {
      return 'Authentication service is temporarily unavailable. '
          'Try again shortly.';
    }

    // LEFT FOR DEBUG (If error not handled, but raw error is returned just display it)
    if (message.isNotEmpty) {
      return message;
    }

    // Just display the default message for the given action if error not caught
    return _defaultMessageForAction(action);
  }

  String _defaultMessageForAction(AuthAction action) {
    switch (action) {
      case AuthAction.signIn:
        return 'Login failed. Please try again.';
      case AuthAction.signUp:
        return 'Sign up could not be completed. Please try again.';
      case AuthAction.signOut:
        return 'Sign out failed. Please try again.';
      case AuthAction.resetPassword:
        return 'Password reset could not be requested. Please try again.';
      case AuthAction.updatePassword:
        return 'Password could not be updated. Please try again.';
    }
  }

  // Helper to catch all network related error messages wrapped by supabase
  bool _looksLikeNetworkIssue(String lowerMessage) {
    return lowerMessage.contains('socketexception') ||
        lowerMessage.contains('failed host lookup') ||
        lowerMessage.contains('connection refused') ||
        lowerMessage.contains('network is unreachable') ||
        lowerMessage.contains('connection reset') ||
        lowerMessage.contains('timed out') ||
        lowerMessage.contains('timeout') ||
        lowerMessage.contains('clientexception');
  }
}
