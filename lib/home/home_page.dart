// OntarioTechPlus - home_page.dart

// This is a temporary home page that just displays the users name, student number and a signout button.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ontario_tech_plus/profile/profile_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        // If no profile data found
        if (profile == null) {
          return const Scaffold(body: Center(child: Text("No profile found")));
        }

        // ================== Build the page ======================
        return Scaffold(
          appBar: AppBar(
            title: const Text("Home"),
            actions: [
              // Go to profile
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () {
                  Navigator.pushNamed(context, '/profile');
                },
              ),
            ],
          ),

          // Main body centered
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Welcome ${profile.firstname} ${profile.lastname} 👋",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Student Number: ${profile.studentNumber}",
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
