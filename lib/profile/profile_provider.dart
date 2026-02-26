// OntarioTechPlus - profile_provider.dart

// This is the provider to read and put data from supabase relating to profile

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ontario_tech_plus/core/global_providers/supabase_provider.dart';
import 'package:ontario_tech_plus/core/global_providers/user_provider.dart';

import 'package:ontario_tech_plus/profile/profile_model.dart';

// Profile fetch provider for user accessible data related to profile
final profileProvider = FutureProvider<Profile?>((ref) async {
  final supabase = ref.read(supabaseProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final data = await supabase
      .from('profiles')
      .select('*') // Pull everything from profile table
      .eq('id', user.id)
      .maybeSingle();

  if (data == null) return null;

  return Profile.fromMap(data);
});

// Profile updating
// data class used when updating profile fields
class ProfileUpdatePayload {
  final String firstname;
  final String lastname;
  final String email;
  final String studentNumber;
  final String program;
  final String faculty;
  final String year;

  const ProfileUpdatePayload({
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.studentNumber,
    required this.program,
    required this.faculty,
    required this.year,
  });
}

//A provider to expose the profile actions class
final profileActionsProvider = Provider<ProfileActions>((ref) {
  return ProfileActions(ref);
});

// Handles profile updates
class ProfileActions {
  // reference riverpod container to access other providers
  final Ref ref;
  ProfileActions(this.ref);

  // method to update profile in supabase
  Future<void> updateProfile(ProfileUpdatePayload payload) async {
    // Get supabase client from provider
    final supabase = ref.read(supabaseProvider);
    // Get the user from the provider
    final user = ref.read(currentUserProvider);
    // Ensure the user is logged in
    if (user == null) {
      throw Exception("Not logged in");
    }

    // Perform update query to supabase profile table
    await supabase
        .from('profiles')
        .update({
          'firstname': payload.firstname.trim(),
          'lastname': payload.lastname.trim(),
          'email': payload.email.trim(),
          'student_number': payload.studentNumber.trim(),
          'program': payload.program.trim(),
          'faculty': payload.faculty.trim(),
          'year': payload.year.trim(),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', user.id);

    // Refresh profileProvider so UI updates
    ref.invalidate(profileProvider);
  }
}
