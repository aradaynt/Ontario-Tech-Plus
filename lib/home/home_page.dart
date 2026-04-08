// OntarioTechPlus - home_page

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ontario_tech_plus/auth/auth_providers.dart';
import 'package:ontario_tech_plus/profile/profile_model.dart';
import 'package:ontario_tech_plus/profile/profile_provider.dart';
import 'package:ontario_tech_plus/home/app_drawer.dart';

import '../QRcodes/scan_qr.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return profileAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),

      error: (_, _) => const Scaffold(
        body: Center(
          child: Text(
            "Error loading profile",
            style: TextStyle(color: Colors.red),
          ),
        ),
      ),

      data: (profile) {
        if (profile == null) {
          return const _MissingProfileScaffold();
        }

        return Scaffold(
          drawer: const AppDrawer(),

          // =================  HEADER =================
          appBar: AppBar(
            toolbarHeight: 90,
            backgroundColor: const Color(0xFF0055B7),
            elevation: 0,

            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),

            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  // Show the saved profile photo in the app bar when available
                  icon: CircleAvatar(
                    radius: 16,
                    backgroundImage: _buildProfileImage(profile),
                    child: profile.profileImageUrl == null
                        ? const Icon(Icons.person, size: 24)
                        : null,
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/profile'),
                ),
              ),
            ],

            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Welcome back,",
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  "${profile.firstname} ${profile.lastname}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Student #: ${profile.studentNumber}",
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ),

          // ================= BODY =================
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER EXTENSION
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0055B7), Color(0xFF00AEEF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Text(
                    "Quick Actions",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),

                // ================= CONTENT =================
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: const Color(0xFF0055B7),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Notifications",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "No new notifications",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      _MobileFeatureCard(
                        title: "Courses",
                        subtitle: "View your courses",
                        icon: Icons.book,
                        color: const Color(0xFF0055B7),
                        onTap: () => Navigator.pushNamed(context, '/courses'),
                      ),
                      const SizedBox(height: 12),

                      _MobileFeatureCard(
                        title: "QR Code Scanner",
                        subtitle: "Scan QR Code",
                        icon: Icons.qr_code,
                        color: const Color(0xFF00AEEF),
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (_) => const ScanQRPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      _MobileFeatureCard(
                        title: "Schedule",
                        subtitle: "See your timetable",
                        icon: Icons.schedule,
                        color: const Color(0xFFFF6F00),
                        onTap: () => Navigator.pushNamed(context, '/schedule'),
                      ),
                      const SizedBox(height: 12),

                      _MobileFeatureCard(
                        title: "Settings",
                        subtitle: "Manage preferences",
                        icon: Icons.settings,
                        color: const Color(0xFF0055B7),
                        onTap: () => Navigator.pushNamed(context, '/settings'),
                      ),

                      const SizedBox(height: 32),
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

// Builds the home page avatar image from the saved profile photo URL.
ImageProvider? _buildProfileImage(Profile profile) {
  final profileImageUrl = profile.profileImageUrl;
  if (profileImageUrl == null || profileImageUrl.isEmpty) {
    return null;
  }

  return NetworkImage(profileImageUrl);
}

// ================= MISSING PROFILE =================

class _MissingProfileScaffold extends ConsumerStatefulWidget {
  const _MissingProfileScaffold();

  @override
  ConsumerState<_MissingProfileScaffold> createState() =>
      _MissingProfileScaffoldState();
}

class _MissingProfileScaffoldState
    extends ConsumerState<_MissingProfileScaffold> {
  bool _isSigningOut = false;

  Future<void> _signOut() async {
    setState(() => _isSigningOut = true);

    try {
      await ref.read(authServiceProvider).signOut();
    } finally {
      if (mounted) {
        setState(() => _isSigningOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'There seems an issue with your account.\nPlease contact administration.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isSigningOut ? null : _signOut,
                child: _isSigningOut
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= FEATURE CARD =================

class _MobileFeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MobileFeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Ink(
        width: screenWidth - 32,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.85),
              color.withValues(alpha: 0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white24,
              ),
              child: Icon(icon, size: 36, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
