// OntarioTechPlus - app_bottom_navbar

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
        indicatorColor: Colors.transparent,

        iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: Colors.blue);
          }
          return IconThemeData(color: Colors.grey.shade600);
        }),

        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((states) {
          const base = TextStyle(fontSize: 12, height: 1.1);

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

        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.schedule), label: 'Schedule'),
          NavigationDestination(icon: Icon(Icons.navigation), label: 'Map'),
        ],
      ),
    );
  }
}
