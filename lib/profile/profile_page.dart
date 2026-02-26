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
  final _programController = TextEditingController();

  String? _selectedFaculty;
  String? _selectedYear;

  // All availible faculties, can pull from faculties database list later
  final List<String> _faculties = [
    "Science",
    "Engineering",
    "Business",
    "Health Sciences",
    "Education",
    "Social Science & Humanities",
  ];

  // Availible years for a student
  final List<String> _years = ["1", "2", "3", "4", "5+"];

  // Dispose of controllers to prevent memory leaks
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _studentNumberController.dispose();
    _programController.dispose();
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
          if (_cachedProfile != null) {
            return _buildProfileView(context, auth, _cachedProfile!);
          }
          return const Center(child: CircularProgressIndicator());
        },
        error: (_, _) {
          if (_cachedProfile != null) {
            return _buildProfileView(context, auth, _cachedProfile!);
          }
          return const Center(
            child: Text(
              "Error loading profile",
              style: TextStyle(color: Colors.red),
            ),
          );
        },
        data: (profile) {
          if (profile != null) {
            _cachedProfile = profile;

            if (!_isEditing) {
              _fillControllers(profile);
            }

            return _buildProfileView(context, auth, profile);
          }

          if (_isSigningOut && _cachedProfile != null) {
            return _buildProfileView(context, auth, _cachedProfile!);
          }

          return const Center(child: Text("No profile found"));
        },
      ),
    );
  }

  // Helper to toggle edit mode for the page
  void _toggleEdit(Profile profile) {
    if (_isSigningOut || _isSaving) return;

    if (_isEditing) {
      setState(() => _isEditing = false);
      _fillControllers(profile); // reset fields
    } else {
      _fillControllers(profile);
      setState(() => _isEditing = true);
    }
  }

  // Helper to fill controllers based on copied profile values.
  void _fillControllers(Profile profile) {
    _firstNameController.text = profile.firstname;
    _lastNameController.text = profile.lastname;
    _studentNumberController.text = profile.studentNumber;
    _programController.text = profile.program;

    _selectedFaculty = _faculties.contains(profile.faculty)
        ? profile.faculty
        : null;

    _selectedYear = _years.contains(profile.year) ? profile.year : null;
  }

  // Build the actual profile content
  Widget _buildProfileView(
    BuildContext context,
    dynamic auth,
    Profile profile,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 2,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 34,
                        child: const Icon(Icons.person, size: 34),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        profile.firstname,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
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

        OutlinedButton.icon(
          onPressed: () {
            _snack("Change email coming soon!");
          },
          icon: const Icon(Icons.email_outlined),
          label: const Text("Change Email"),
        ),

        const SizedBox(height: 18),

        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            "Profile information",
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),

        Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                if (!_isEditing)
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
                  _editTile(
                    icon: Icons.person,
                    title: "First Name",
                    controller: _firstNameController,
                    enabled: !_isSaving,
                  ),
                  _editTile(
                    icon: Icons.person_outline,
                    title: "Last Name",
                    controller: _lastNameController,
                    enabled: !_isSaving,
                  ),
                ],

                const Divider(height: 12, indent: 16, endIndent: 16),

                if (!_isEditing)
                  ListTile(
                    leading: const Icon(Icons.numbers),
                    title: const Text("Student Number"),
                    subtitle: Text(profile.studentNumber),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  )
                else
                  _editTile(
                    icon: Icons.numbers,
                    title: "Student Number",
                    controller: _studentNumberController,
                    enabled: !_isSaving,
                    keyboardType: TextInputType.number,
                  ),

                const Divider(height: 12, indent: 16, endIndent: 16),

                if (!_isEditing)
                  ListTile(
                    leading: const Icon(Icons.school),
                    title: const Text("Program"),
                    subtitle: Text(profile.program),
                  )
                else
                  _editTile(
                    icon: Icons.school,
                    title: "Program",
                    controller: _programController,
                    enabled: !_isSaving,
                  ),

                const Divider(height: 12, indent: 16, endIndent: 16),

                if (!_isEditing)
                  ListTile(
                    leading: const Icon(Icons.account_balance),
                    title: const Text("Faculty"),
                    subtitle: Text(profile.faculty),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedFaculty,
                      decoration: const InputDecoration(labelText: "Faculty"),
                      items: _faculties
                          .map(
                            (f) => DropdownMenuItem(value: f, child: Text(f)),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedFaculty = val),
                    ),
                  ),

                const Divider(height: 12, indent: 16, endIndent: 16),

                if (!_isEditing)
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text("Year"),
                    subtitle: Text(profile.year),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedYear,
                      decoration: const InputDecoration(labelText: "Year"),
                      items: _years
                          .map(
                            (y) => DropdownMenuItem(
                              value: y,
                              child: Text("Year $y"),
                            ),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => _selectedYear = val),
                    ),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        if (_isEditing) ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: (_isSaving || _isSigningOut)
                      ? null
                      : () {
                          setState(() => _isEditing = false);
                          _fillControllers(profile);
                        },
                  child: const Text("Cancel"),
                ),
              ),
              const SizedBox(width: 12),
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
          const SizedBox(height: 16),
        ],

        ElevatedButton(
          onPressed: (_isSigningOut || _isSaving)
              ? null
              : () async {
                  setState(() => _isSigningOut = true);
                  Navigator.of(context).pop();
                  await auth.signOut();
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: _isSigningOut
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text("Sign Out", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _editTile({
    required IconData icon,
    required String title,
    required TextEditingController controller,
    required bool enabled,
    TextInputType? keyboardType,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      leading: Icon(icon),
      title: Text(title),
      subtitle: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        decoration: const InputDecoration(isDense: true),
      ),
    );
  }

  Future<void> _saveEdits(Profile currentProfile) async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final studentNumber = _studentNumberController.text.trim();
    final program = _programController.text.trim();

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        studentNumber.isEmpty ||
        program.isEmpty ||
        _selectedFaculty == null ||
        _selectedYear == null) {
      _snack("All fields are required.");
      return;
    }

    setState(() => _isSaving = true);

    try {
      await ref
          .read(profileActionsProvider)
          .updateProfile(
            ProfileUpdatePayload(
              firstname: firstName,
              lastname: lastName,
              email: currentProfile.email,
              studentNumber: studentNumber,
              program: program,
              faculty: _selectedFaculty!,
              year: _selectedYear!,
            ),
          );

      setState(() => _isEditing = false);
      _snack("Profile updated.");
    } catch (e) {
      _snack("Profile could not be updated.");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
