// OntarioTechPlus - user_provider.dart

// Gets the current user
// Temporarily grabs profile data. Will have proper profile provider later with a proper model rather than map.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ontario_tech_plus/auth/auth_providers.dart';
import 'package:ontario_tech_plus/core/global_providers/supabase_provider.dart';

// Provides the currently signed-in supabase user.
// Will return null if signed out, still loading or error occures
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.maybeWhen(
    data: (session) => session?.user,
    orElse: () => null,
  );
});

// Fet the user profile from the profiles table (Only used as a demonstration for home page, will use proper model later)
final profileProvider = FutureProvider.autoDispose<Map<String, dynamic>?>((
  ref,
) async {
  final user = ref.watch(currentUserProvider); // Get the current user

  // If no user, no profile
  if (user == null) return null;

  final supabase = ref.watch(supabaseProvider); //Get supabase through provider

  // Try to fetch the profile table data
  try {
    final row = await supabase
        .from('profiles')
        .select('firstname, lastname, email, student_number')
        .eq('id', user.id)
        .single();

    return row;
  } catch (_) {
    // Return null if profile doesnt exist
    return null;
  }
});
