// OntarioTechPlus - home_page.dart

// This is the main dashboard page that displays the users name, student number
// and provides navigation to main sections of the app.

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
      // Show a spinner when loading profile data
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
            title: const Text("Dashboard"),
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

          // Main body with padding
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================== Welcome Section ======================
                Text(
                  "Welcome ${profile.firstname} ${profile.lastname} 👋",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Student Number: ${profile.studentNumber}",
                  style: const TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 30),

                // ================== Navigation Cards ======================
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _MenuCard(
                        icon: Icons.book,
                        title: "Courses",
                        onTap: () {
                          Navigator.pushNamed(context, '/courses');
                        },
                      ),
                      _MenuCard(
                        icon: Icons.grade,
                        title: "Club Recommendations",
                        onTap: () {
                          Navigator.pushNamed(context, '/recommendations');
                        },
                      ),
                      _MenuCard(
                        icon: Icons.schedule,
                        title: "Schedule",
                        onTap: () {
                          Navigator.pushNamed(context, '/schedule');
                        },
                      ),
                      _MenuCard(
                        icon: Icons.settings,
                        title: "Settings",
                        onTap: () {
                          Navigator.pushNamed(context, '/settings');
                        },
                      ),
                    ],
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

// ================== Reusable Menu Card Widget ======================

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.primaryContainer,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
