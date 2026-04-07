// OntarioTechPlus - app_drawer

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ontario_tech_plus/profile/profile_provider.dart';
import 'package:ontario_tech_plus/theme/theme_provider.dart';
import 'package:ontario_tech_plus/core/global_providers/nav_tab_provider.dart';

// ✅ IMPORT ACTUAL PAGES
import 'package:ontario_tech_plus/booking/booking_page.dart';
import 'package:ontario_tech_plus/appointments/appointment_landing.dart';

import '../QRcodes/scan_qr.dart';

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
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(tabIndexProvider.notifier).setIndex(0);
                    },
                    theme: theme,
                  ),

                  // ---- Navigation ----
                  _DrawerTile(
                    icon: Icons.grid_view,
                    label: "Menu",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(
                        context,
                        rootNavigator: true,
                      ).pushNamed('/menu');
                    },
                    theme: theme,
                  ),
                  _DrawerTile(
                    icon: Icons.search,
                    label: "Search",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(
                        context,
                        rootNavigator: true,
                      ).pushNamed('/search');
                    },
                    theme: theme,
                  ),

                  // ---- Booking ----
                  _DrawerTile(
                    icon: Icons.add_box,
                    label: "Booking",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(builder: (_) => const BookingPage()),
                      );
                    },
                    theme: theme,
                  ),

                  // ---- Appointments ----
                  _DrawerTile(
                    icon: Icons.event,
                    label: "Appointments",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (_) => const AppointmentTypePage(),
                        ),
                      );
                    },
                    theme: theme,
                  ),

                  // ---- Scan QR Code ----
                  _DrawerTile(
                    icon: Icons.qr_code,
                    label: "QR Code Scanner",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(builder: (_) => const ScanQRPage()),
                      );
                    },
                    theme: theme,
                  ),
                  // ---- Settings ----
                  _DrawerTile(
                    icon: Icons.settings,
                    label: "Settings",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(
                        context,
                        rootNavigator: true,
                      ).pushNamed('/settings');
                    },
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
  final VoidCallback onTap;
  final ThemeData theme;

  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.zero,
        splashColor: theme.colorScheme.primary.withOpacity(0.1),
        onTap: onTap,
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
