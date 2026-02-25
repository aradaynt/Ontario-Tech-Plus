// OntarioTechPlus - profile_page.dart

// Profile allows the user to view and edit account information. Also allows signout

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ontario_tech_plus/auth/auth_providers.dart';
import 'package:ontario_tech_plus/profile/profile_model.dart';
import 'package:ontario_tech_plus/profile/profile_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  // Track whether the user is currently singing out (disables button and shows spinner)
  bool _isSigningOut = false;
  // Track whether the user is currently editing the profile fields
  bool _isEditing = false;
  // Track whether the user is currently saving the editted profile
  bool _isSaving = false;

  // Cache for profile page.
  // Makes it so that the profile data stays during logout for visual affect
  Profile? _cachedProfile;

  // Controllers for user input for profile updates
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _studentNumberController = TextEditingController();

  // Dispose of controllers to prevent memory leaks
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _studentNumberController.dispose();
    super.dispose();
  }

  // UI Builder for page
  @override
  Widget build(BuildContext context) {
    // Watch the profile provider to fetch profile and rebuild on change
    final profileAsync = ref.watch(profileProvider);
    // Read auth service provider for signout
    final auth = ref.read(authServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),

      // Body depends on async profile state
      body: profileAsync.when(
        loading: () {
          // If data loaded, keep it instead of showing loading
          if (_cachedProfile != null) {
            return _buildProfileView(context, auth, _cachedProfile!);
          }
          return const Center(child: CircularProgressIndicator());
        },
        error: (_, _) {
          // If the profile data is already loaded, keep showing rather than error
          if (_cachedProfile != null) {
            return _buildProfileView(context, auth, _cachedProfile!);
          }
          // If there is an error loading data at all, print error
          return const Center(
            child: Text(
              "Error loading profile",
              style: TextStyle(color: Colors.red),
            ),
          );
        },
        data: (profile) {
          // If real profile found, create cache. (Used to hold data on screen during logout)
          if (profile != null) {
            _cachedProfile = profile;

            // If the profile refreshed while not editing, keep controllers in sync
            if (!_isEditing) {
              _fillControllers(profile);
            }

            // Build the profile with latest profile data
            return _buildProfileView(context, auth, profile);
          }

          // During signout, use the cached profile
          if (_isSigningOut && _cachedProfile != null) {
            return _buildProfileView(context, auth, _cachedProfile!);
          }

          // This is only shown if not during a signout and there is actually not profile
          return const Center(child: Text("No profile found"));
        },
      ),
    );
  }

  // Helper to toggle edit mode for the page
  void _toggleEdit(Profile profile) {
    if (_isSigningOut || _isSaving) return;

    if (_isEditing) {
      // Cancel edit
      setState(() => _isEditing = false);
      _fillControllers(profile); // reset fields
    } else {
      // Start edit
      _fillControllers(profile);
      setState(() => _isEditing = true);
    }
  }

  // Helper to fill controllers based on copied profile values.
  void _fillControllers(Profile profile) {
    _firstNameController.text = profile.firstname;
    _lastNameController.text = profile.lastname;
    _studentNumberController.text = profile.studentNumber;
  }

  // Build the actual profile content
  Widget _buildProfileView(
    BuildContext context,
    dynamic auth,
    Profile profile,
  ) {
    // Scollable list of sections
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Top profile card
        Card(
          // Card elevation/shadow
          elevation: 2,
          // Stack to put pencil top right
          child: Stack(
            children: [
              // Inside padding for card
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                // Center profile icon, firstName name and email
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Profile icon top center
                      CircleAvatar(
                        radius: 34,
                        child: const Icon(Icons.person, size: 34),
                      ),

                      const SizedBox(height: 12),

                      // Student firstName name
                      Text(
                        profile.firstname,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Student email
                      Text(
                        profile.email,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Pencil icon in top right of card
              Positioned(
                top: 6,
                right: 6,
                child: IconButton(
                  tooltip: _isEditing ? "Cancel edit" : "Edit profile",
                  icon: Icon(_isEditing ? Icons.close : Icons.edit),
                  onPressed: (_isSigningOut || _isSaving)
                      ? null
                      : () => _toggleEdit(profile),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Change email button below card
        OutlinedButton.icon(
          onPressed: () {
            _snack("Change email coming soon!");
          },
          icon: const Icon(Icons.email_outlined),
          label: const Text("Change Email"),
        ),

        const SizedBox(height: 18),

        // Profile information
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            "Profile information",
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),

        // Information cards
        Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                // Full name
                if (!_isEditing) // Not editting
                  ListTile(
                    leading: const Icon(Icons.badge_outlined),
                    title: const Text("Full Name"),
                    subtitle: Text(profile.fullName),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  )
                else ...[
                  // Editting
                  _editTile(
                    icon: Icons.person,
                    title: "First Name",
                    controller: _firstNameController,
                    enabled: !_isSaving,
                    textInputAction: TextInputAction.next,
                  ),
                  _editTile(
                    icon: Icons.person_outline,
                    title: "Last Name",
                    controller: _lastNameController,
                    enabled: !_isSaving,
                    textInputAction: TextInputAction.next,
                  ),
                ],

                //Put a devider
                const Divider(height: 12, indent: 16, endIndent: 16),

                // Student Number
                if (!_isEditing) //Not edittign
                  ListTile(
                    leading: const Icon(Icons.numbers),
                    title: const Text("Student Number"),
                    subtitle: Text(profile.studentNumber),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  )
                else // Editting
                  _editTile(
                    icon: Icons.numbers,
                    title: "Student Number",
                    controller: _studentNumberController,
                    enabled: !_isSaving,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    helperText: "Must be exactly 9 digits.",
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Save and cancel button appearing under information
        if (_isEditing) ...[
          // Check if editting
          Row(
            children: [
              // Cancel button
              Expanded(
                child: OutlinedButton(
                  onPressed: (_isSaving || _isSigningOut)
                      ? null
                      : () {
                          setState(() => _isEditing = false);
                          _fillControllers(profile); // reset edits
                        },
                  child: const Text("Cancel"),
                ),
              ),

              const SizedBox(width: 12),

              // Save button
              Expanded(
                child: ElevatedButton(
                  onPressed: (_isSaving || _isSigningOut)
                      ? null
                      : () async {
                          await _saveEdits(profile);
                        },
                  child: _isSaving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Save"),
                ),
              ),
            ],
          ),

          // Space for save button
          const SizedBox(height: 16),
        ],

        // Sign Out Button
        ElevatedButton(
          // Disable if signout or saving
          onPressed: (_isSigningOut || _isSaving)
              ? null
              : () async {
                  // On signout
                  setState(() => _isSigningOut = true); // Set signout true

                  Navigator.of(context).pop(); // Pop back

                  // Signout, allowing main to route back to login
                  await auth.signOut();
                },
          // Signout button styling
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child:
              _isSigningOut // If is signing out
              ? const SizedBox(
                  // Put a circle loading indication in place of the text
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              // Otherwise display the signout out btn text
              : const Text("Sign Out", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  // Widget for displaying the the information in edit mode
  Widget _editTile({
    required IconData icon,
    required String title,
    required TextEditingController controller,
    required bool enabled,
    TextInputAction? textInputAction,
    TextInputType? keyboardType,
    String? helperText,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      leading: Icon(icon),
      title: Text(title),
      subtitle: TextField(
        controller: controller,
        enabled: enabled,
        textInputAction: textInputAction,
        keyboardType: keyboardType,
        decoration: InputDecoration(isDense: true, helperText: helperText),
      ),
    );
  }

  // Function to handle saving the edits made
  Future<void> _saveEdits(Profile currentProfile) async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final studentNumber = _studentNumberController.text.trim();

    // Make sure the fields are not empty
    if (firstName.isEmpty || lastName.isEmpty || studentNumber.isEmpty) {
      _snack("All fields are required.");
      return;
    }

    // Make sure student number is valid (numeric, 9 chars)
    final studentNumberError = _validateStudentNumber(studentNumber);
    // Return error if not valid
    if (studentNumberError != null) {
      _snack(studentNumberError);
      return;
    }

    // Set is saving to true
    setState(() => _isSaving = true);

    // Try to update the profile data using provider
    try {
      await ref
          .read(profileActionsProvider)
          .updateProfile(
            ProfileUpdatePayload(
              firstname: firstName,
              lastname: lastName,
              studentNumber: studentNumber,
            ),
          );

      // Update cache immediately so UI feels instant
      setState(() {
        _cachedProfile = Profile(
          firstname: firstName,
          lastname: lastName,
          email: currentProfile.email,
          studentNumber: studentNumber,
        );
        _isEditing = false; // Set iseditting to false
      });

      // Display snackbar for success
      _snack("Profile updated.");
    } catch (e) {
      // display a user friendly message on update failure
      _snack(_friendlyUpdateErrorMessage(e.toString()));
    } finally {
      // set is saving to false no matter what success
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // Helper function to validate the student number
  String? _validateStudentNumber(String value) {
    final val = value.trim();

    if (!RegExp(r'^\d+$').hasMatch(val)) {
      return "Student number must contain only digits.";
    }
    if (val.length != 9) {
      return "Student number must be exactly 9 digits.";
    }
    return null;
  }

  // Helper function to take supabase jargon and turn it into user friendly message
  String _friendlyUpdateErrorMessage(String raw) {
    final msg = raw.toLowerCase();

    // Unique constraint / duplicate student number
    if (msg.contains('duplicate') ||
        msg.contains('unique') ||
        msg.contains('profiles_student_number_key') ||
        msg.contains('student_number')) {
      return "Issue with student number.";
    }

    return "Profile could not be updated.";
  }

  // Helper function for the snack bar
  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
