// OntarioTechPlus - auth_providers.dart

// Auth providers uses Supabase and Riverpod

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ontario_tech_plus/core/global_providers/supabase_provider.dart';

// Auth State Stream Provider (login/logout)
// Will listen for any future auth changes
final authStateProvider = StreamProvider<Session?>((ref) async* {
  final supabase = ref.watch(supabaseProvider);

  yield supabase.auth.currentSession;

  await for (final event in supabase.auth.onAuthStateChange) {
    yield event.session;
  }
});

/// Porvides the auth service to the app
final authServiceProvider = Provider<AuthService>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return AuthService(supabase);
});

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
  ) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'firstname': firstName,
        'lastname': lastName,
        'student_number': studentNumber,
      },
    );

    if (response.user == null) {
      throw Exception("Signup failed");
    }
  }

  // Logs in an existing user
  Future<void> signIn(String email, String password) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception("Login failed");
    }
  }

  // Logs out the current user
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
