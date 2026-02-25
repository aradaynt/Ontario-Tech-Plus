// OntarioTechPlus - ShellPage

// This page is what allows the navbar at the bottom, and makes it so page changes look seemless (no transitions)

// NOTE: The nav bar naming is handled in core/global_widgets/app_bottom_navbar.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ontario_tech_plus/core/global_providers/nav_tab_provider.dart';
import 'package:ontario_tech_plus/core/global_widgets/app_bottom_navbar.dart';

import 'package:ontario_tech_plus/home/home_page.dart';
import 'package:ontario_tech_plus/appointments/appointment.dart';
import 'package:ontario_tech_plus/booking/booking_page.dart';
import 'package:ontario_tech_plus/schedule/schedule_page.dart';
import 'package:ontario_tech_plus/navigation/navigation_page.dart';

class ShellPage extends ConsumerWidget {
  const ShellPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(tabIndexProvider);

    final pages = const [
      HomePage(),
      AppointmentPage(),
      BookingPage(),
      SchedulePage(),
      NavigationPage(),
    ];

    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: AppBottomNav(
        currentIndex: index,
        onTap: (i) => ref.read(tabIndexProvider.notifier).setIndex(i),
      ),
    );
  }
}
