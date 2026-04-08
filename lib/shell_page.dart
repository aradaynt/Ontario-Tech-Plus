// OntarioTechPlus - ShellPage

// This page is what allows the navbar at the bottom, and makes it so page changes look seamless (no transitions)

// NOTE: The nav bar naming is handled in core/global_widgets/app_bottom_navbar.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ontario_tech_plus/core/global_providers/nav_tab_provider.dart';
import 'package:ontario_tech_plus/core/global_widgets/app_bottom_navbar.dart';
import 'package:ontario_tech_plus/profile/profile_provider.dart';

import 'package:ontario_tech_plus/home/home_page.dart';
import 'package:ontario_tech_plus/booking/booking_page.dart';
import 'package:ontario_tech_plus/home/search_page.dart';
import 'package:ontario_tech_plus/schedule/schedule_page.dart';
import 'package:ontario_tech_plus/maps/maps.dart';

import 'package:ontario_tech_plus/appointments/appointment_landing.dart';

class ShellPage extends ConsumerWidget {
  const ShellPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(tabIndexProvider);
    // Used to hide the nav bar if the signed in user has no profile (Error state)
    final profileAsync = ref.watch(profileProvider);

    // FIX: reorder pages so indices match bottom nav
    final pages = const [
      HomePage(), // index 0 (Home)
      SchedulePage(), // index 1 (Schedule)
      MapsPage(), // index 2 (Map) <-- FIXED
      // remaining pages (not in bottom nav, but still accessible elsewhere)
      AppointmentTypePage(),
      BookingPage(),
      SearchPage(),
    ];

    return Scaffold(
      body: IndexedStack(index: index, children: pages),

      // Logic to hide or show nav bar based on non-broken user
      bottomNavigationBar: profileAsync.maybeWhen(
        data: (profile) => profile == null
            ? null
            : AppBottomNav(
                currentIndex: index,
                onTap: (i) => ref.read(tabIndexProvider.notifier).setIndex(i),
              ),
        orElse: () => AppBottomNav(
          currentIndex: index,
          onTap: (i) => ref.read(tabIndexProvider.notifier).setIndex(i),
        ),
      ),
    );
  }
}
