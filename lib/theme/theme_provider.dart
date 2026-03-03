// OntarioTechPlus - theme_provider.dart

// This provider manages the application's theme mode (light / dark)
// and allows it to be toggled from anywhere in the app.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

// StateNotifier that holds ThemeMode
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light);

  // Toggle between light and dark mode
  void toggleTheme(bool isDarkMode) {
    state = isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }
}

// Global theme provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});
