// OntarioTechPlus - profile_provider.dart

// This is the provider to read and put data from supabase relating to profile

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ontario_tech_plus/core/global_providers/supabase_provider.dart';
import 'package:ontario_tech_plus/core/global_providers/user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ontario_tech_plus/profile/profile_model.dart';

// Storage bucket name used for profile photos.
const String _profilePhotoBucket = 'profile-photos';

// How long the generated signed URL for viewing a profile photo during loading
const int _profilePhotoSignedUrlExpirySeconds = 60 * 60 * 24 * 30;

// Profile fetch provider for user accessible data related to profile
final profileProvider = FutureProvider<Profile?>((ref) async {
  final supabase = ref.read(supabaseProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final data = await supabase
      .from('profiles')
      .select(
        'firstname, lastname, email, student_number, program, faculty, year, profile_image_url',
      )
      .eq('id', user.id)
      .maybeSingle();

  if (data == null) return null;

  // Get the profile image
  final profileImageValue = data['profile_image_url'] as String?;
  if (profileImageValue != null && profileImageValue.isNotEmpty) {
    try {
      data['profile_image_url'] = await _resolveProfileImageUrl(
        supabase,
        profileImageValue,
      );
    } catch (_) {
      // A storage issue relating to the photo should not block the rest of the profile from loading
      data['profile_image_url'] = null;
    }
  }

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

  // Function to upload a profile photo to the database
  Future<String> uploadProfilePhoto(XFile imageFile) async {
    final supabase = ref.read(supabaseProvider);
    final user = ref.read(currentUserProvider);

    // Ensure user is logged in
    if (user == null) {
      throw Exception("Not logged in");
    }

    // Get current stored photo path
    final existingProfile = await supabase
        .from('profiles')
        .select('profile_image_url')
        .eq('id', user.id)
        .maybeSingle();
    final previousStoragePath =
        existingProfile?['profile_image_url'] as String?;

    // Read the image bytes and build the storage file info
    final bytes = await imageFile.readAsBytes();
    final extension = _fileExtension(imageFile.path);
    final contentType = _contentTypeForExtension(extension);
    final timestamp = DateTime.now().toUtc().millisecondsSinceEpoch;
    final storagePath = '${user.id}/profile_image_$timestamp.$extension';

    // Upload the new profile photo to Supabase storage
    await supabase.storage
        .from(_profilePhotoBucket)
        .uploadBinary(
          storagePath,
          bytes,
          fileOptions: FileOptions(contentType: contentType, upsert: true),
        );

    // Create a signed URL so the uploaded photo can be displayed
    final signedUrl = await _resolveProfileImageUrl(supabase, storagePath);

    // Save the new storage path in the user's profile row
    await supabase
        .from('profiles')
        .update({
          'profile_image_url': storagePath,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', user.id);

    // Remove the old stored photo if a different one already existed
    if (previousStoragePath != null &&
        previousStoragePath.isNotEmpty &&
        previousStoragePath != storagePath) {
      await supabase.storage.from(_profilePhotoBucket).remove([
        previousStoragePath,
      ]);
    }

    // Refresh the profile data so the UI shows the new image
    ref.invalidate(profileProvider);
    return signedUrl;
  }

  // Gets the file extension from the image path.
  String _fileExtension(String path) {
    final dotIndex = path.lastIndexOf('.');
    // Default to jpg if the file has no valid extension.
    if (dotIndex == -1 || dotIndex == path.length - 1) {
      return 'jpg';
    }

    return path.substring(dotIndex + 1).toLowerCase();
  }

  // Converts the file extension into correct image content type
  String _contentTypeForExtension(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'heic':
      case 'heif':
        return 'image/heic';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }
}

// Creates a signed URL so stored profile image can be viewed
Future<String> _resolveProfileImageUrl(
  SupabaseClient supabase,
  String profileImageValue,
) async {
  return supabase.storage
      .from(_profilePhotoBucket)
      .createSignedUrl(profileImageValue, _profilePhotoSignedUrlExpirySeconds);
}
