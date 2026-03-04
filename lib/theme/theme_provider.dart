// OntarioTechPlus - theme_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Enum for theme modes
enum AppThemeMode { light, dark, lessSaturated }

// StateNotifier for managing theme
class ThemeNotifier extends StateNotifier<AppThemeMode> {
  ThemeNotifier() : super(AppThemeMode.light);

  void setTheme(AppThemeMode mode) => state = mode;

  void cycleTheme() {
    switch (state) {
      case AppThemeMode.light:
        state = AppThemeMode.dark;
        break;
      case AppThemeMode.dark:
        state = AppThemeMode.lessSaturated;
        break;
      case AppThemeMode.lessSaturated:
        state = AppThemeMode.light;
        break;
    }
  }

  ThemeData get themeData {
    switch (state) {
      case AppThemeMode.dark:
        return ThemeData.dark().copyWith(primaryColor: const Color(0xFF003C71));

      case AppThemeMode.lessSaturated:
        return ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: const Color(0xFFACA39A),
          cardColor: const Color(0xFFFFFFFF),
          primaryColor: const Color(0xFF003C71),
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF003C71),
            secondary: Color(0xFFE75D2A),
            surface: Color(0xFFACA39A),
            onPrimary: Color(0xFFFFFFFF),
            onSurface: Color(0xFF5B6770),
          ),
          iconTheme: const IconThemeData(color: Color(0xFF0077CA)),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Color(0xFF5B6770)),
            bodyMedium: TextStyle(color: Color(0xFFA7A8AA)),
            titleMedium: TextStyle(color: Color(0xFFA7A8AA)),
          ),
          dividerColor: const Color(0xFFA7A8AA),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFACA39A),
            foregroundColor: Color(0xFF5B6770),
            elevation: 0,
          ),
          switchTheme: SwitchThemeData(
            thumbColor: MaterialStateProperty.all(const Color(0xFF0077CA)),
            trackColor: MaterialStateProperty.all(const Color(0xFFACA39A)),
          ),
        );

      case AppThemeMode.light:
      default:
        return ThemeData(
          brightness: Brightness.light,
          primaryColor: const Color(0xFF003C71),
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF003C71),
            secondary: Color(0xFFE75D2A),
          ),
        );
    }
  }
}

// Global provider
final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeMode>(
  (ref) => ThemeNotifier(),
);
