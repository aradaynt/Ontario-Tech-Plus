// OntarioTechPlus - home_page.dart

// This is a temporary home page that just displays the users name, student number and a signout button.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ontario_tech_plus/auth/auth_providers.dart';
import 'package:ontario_tech_plus/core/global_providers/user_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // read the auth for signout
    final auth = ref.read(authServiceProvider);

    // get the profile data, and will reactively rebuild on changes (Currently housed in user_provider.dart)
    final profileAsync = ref.watch(profileProvider);

    // Handle loading, error and data states
    return profileAsync.when(
      // Show a spinnder when loading profile data
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),

      // Show error message if profile cant be loaded
      error: (error, _) => Scaffold(
        body: Center(
          child: Text(
            "Error loading profile",
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),

      // Profile load success
      data: (profile) {
        // If no profile row exists
        if (profile == null) {
          return const Scaffold(body: Center(child: Text("No profile found")));
        }

        // Extract data from map
        final firstName = profile['firstname'];
        final lastName = profile['lastname'];
        final studentNumber = profile['student_number'];

        // ================== Build the page ======================
        return Scaffold(
          //App bar
          appBar: AppBar(
            title: const Text("Home"),
            actions: [
              // Add a signout button at the top
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await auth.signOut();
                },
              ),
            ],
          ),

          // Main body centered
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Welcome message
                Text(
                  "Welcome $firstName $lastName 👋",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // Student number
                Text(
                  "Student Number: $studentNumber",
                  style: const TextStyle(fontSize: 18),
                ),

                const SizedBox(height: 32),

                // Actual signout button
                ElevatedButton(
                  onPressed: () async {
                    await auth.signOut();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                  ),
                  child: const Text(
                    "Sign Out",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
