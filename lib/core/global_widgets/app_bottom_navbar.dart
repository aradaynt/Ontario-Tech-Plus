// OntarioTechPlus - app_bottom_navbar
//
// Bottom Navbar widget - Navbar is housed by the shell page

import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        // Hide the selected indicator
        indicatorColor: Colors.transparent,

        // Icon configuration
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>((states) {
          // Set to blue if its the active icon
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: Colors.blue);
          }
          return IconThemeData(color: Colors.grey.shade600);
        }),

        // Set the label text size and height
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((states) {
          const base = TextStyle(fontSize: 12, height: 1.1);

          // Set the active index to blue text
          if (states.contains(WidgetState.selected)) {
            return base.copyWith(
              color: Colors.blue,
              fontWeight: FontWeight.w600,
            );
          }

          return base.copyWith(color: Colors.grey, fontWeight: FontWeight.w500);
        }),
      ),
      child: NavigationBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,

        // Nav button labels
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.event), label: 'Appointment'),
          NavigationDestination(icon: Icon(Icons.add_box), label: 'Booking'),
          NavigationDestination(icon: Icon(Icons.schedule), label: 'Academics'),
          NavigationDestination(
            icon: Icon(Icons.navigation),
            label: 'Navigation',
          ),
        ],
      ),
    );
  }
}
