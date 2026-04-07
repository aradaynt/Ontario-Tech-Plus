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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return NavigationBarTheme(
      data: NavigationBarThemeData(
        indicatorColor: Colors.transparent,

        iconTheme: MaterialStateProperty.resolveWith<IconThemeData>((states) {
          if (states.contains(MaterialState.selected)) {
            return IconThemeData(color: colorScheme.primary);
          }
          return IconThemeData(color: colorScheme.onSurface.withOpacity(0.6));
        }),

        labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>((states) {
          const base = TextStyle(fontSize: 12, height: 1.1);
          if (states.contains(MaterialState.selected)) {
            return base.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            );
          }
          return base.copyWith(
            color: colorScheme.onSurface.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          );
        }),
      ),

      child: NavigationBar(
        backgroundColor: colorScheme.background,
        surfaceTintColor: Colors.transparent,
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,

        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.menu_book_rounded),
            label: 'Academics',
          ),
          NavigationDestination(icon: Icon(Icons.navigation), label: 'Map'),
        ],
      ),
    );
  }
}
