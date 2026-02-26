// OntarioTechPlus - user_provider.dart

// Gets the current user

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ontario_tech_plus/auth/auth_providers.dart';

// Provides the currently signed-in supabase user.
// Will return null if signed out, still loading or error occures
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.maybeWhen(
    data: (session) => session?.user,
    orElse: () => null,
  );
});
