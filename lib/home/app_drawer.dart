// OntarioTechPlus - app_drawer

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ontario_tech_plus/profile/profile_provider.dart';
import 'package:ontario_tech_plus/theme/theme_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider.notifier).themeData;
    final profileAsync = ref.watch(profileProvider);

    return Drawer(
      elevation: 8,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Container(
        color: theme.scaffoldBackgroundColor,
        child: Column(
          children: [
            // ================= HEADER =================
            profileAsync.when(
              loading: () => const _DrawerHeaderLoading(),
              error: (_, __) => const _DrawerHeaderFallback(),
              data: (profile) {
                if (profile == null) return const _DrawerHeaderFallback();

                return _DrawerHeader(
                  name: "${profile.firstname} ${profile.lastname}",
                  studentId: profile.studentNumber,
                );
              },
            ),

            // ================= NAV ITEMS =================
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // ---- Main ----
                  _DrawerTile(
                    icon: Icons.home,
                    label: "Home",
                    route: '/shell',
                    theme: theme,
                  ),

                  // ---- Navigation ----
                  _DrawerTile(
                    icon: Icons.grid_view,
                    label: "Menu",
                    route: '/menu',
                    theme: theme,
                  ),
                  _DrawerTile(
                    icon: Icons.search,
                    label: "Search",
                    route: '/search',
                    theme: theme,
                  ),

                  // ---- Booking ----
                  _DrawerTile(
                    icon: Icons.add_box,
                    label: "Booking",
                    route: '/booking',
                    theme: theme,
                  ),
                  _DrawerTile(
                    icon: Icons.event,
                    label: "Appointments",
                    route: '/appointments',
                    theme: theme,
                  ),

                  // ---- Settings ----
                  _DrawerTile(
                    icon: Icons.settings,
                    label: "Settings",
                    route: '/settings',
                    theme: theme,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//
// ================= HEADER =================
//

class _DrawerHeader extends StatelessWidget {
  final String name;
  final String studentId;

  const _DrawerHeader({required this.name, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),

      // GRADIENT
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF003C71), // deep blue
            Color(0xFF0055B7), // primary blue
            Color(0xFFFF6F00), // orange
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),

      child: Row(
        children: [
          // PROFILE ICON
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 34, color: Colors.black54),
          ),

          const SizedBox(width: 14),

          // NAME + ID
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                if (studentId.isNotEmpty)
                  Text(
                    "Student #: $studentId",
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//
// ================= LOADING HEADER =================
//

class _DrawerHeaderLoading extends StatelessWidget {
  const _DrawerHeaderLoading();

  @override
  Widget build(BuildContext context) {
    return const _DrawerHeader(name: "Loading...", studentId: "...");
  }
}

//
// ================= FALLBACK HEADER =================
//

class _DrawerHeaderFallback extends StatelessWidget {
  const _DrawerHeaderFallback();

  @override
  Widget build(BuildContext context) {
    return const _DrawerHeader(name: "Ontario Tech Plus", studentId: "");
  }
}

//
// ================= TILE =================
//

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final ThemeData theme;

  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.route,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.zero,
        splashColor: theme.colorScheme.primary.withOpacity(0.1),

        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, route);
        },

        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 24),
              const SizedBox(width: 14),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
