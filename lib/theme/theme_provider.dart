import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppThemeMode { light, dark, lessSaturated }

class AppColors {
  static const futureBlue = Color(0xFF003C71);
  static const simcoeBlue = Color(0xFF0077CA);
  static const techTangerine = Color(0xFFE75D2A);

  static const lightBackground = Color(0xFFF6F7F9);
  static const mutedBackground = Color(0xFFE8EAED);

  static const cardLight = Colors.white;
  static const cardMuted = Color(0xFFF1F2F4);

  static const textDark = Color(0xFF1F2933);
  static const textMuted = Color(0xFF5B6770);
}

class ThemeNotifier extends Notifier<AppThemeMode> {
  @override
  AppThemeMode build() => AppThemeMode.light;

  void setTheme(AppThemeMode mode) => state = mode;

  ThemeData get themeData {
    switch (state) {
      case AppThemeMode.light:
        return ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: AppColors.lightBackground,
          primaryColor: AppColors.futureBlue,
          colorScheme: const ColorScheme.light(
            primary: AppColors.futureBlue,
            secondary: AppColors.techTangerine,
          ),
          cardColor: AppColors.cardLight,
          iconTheme: const IconThemeData(color: AppColors.simcoeBlue),
          dividerColor: Colors.grey.shade300,
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: AppColors.textDark),
            bodyMedium: TextStyle(color: AppColors.textMuted),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.futureBlue,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        );

      case AppThemeMode.dark:
        return ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF121212),
          primaryColor: AppColors.futureBlue,
          colorScheme: const ColorScheme.dark(
            primary: AppColors.futureBlue,
            secondary: AppColors.techTangerine,
          ),
          cardColor: const Color(0xFF1E1E1E),
          iconTheme: const IconThemeData(color: AppColors.simcoeBlue),
          dividerColor: Colors.grey,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.futureBlue,
            foregroundColor: Colors.white,
          ),
        );

      case AppThemeMode.lessSaturated:
        return ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: AppColors.mutedBackground,
          primaryColor: AppColors.futureBlue,
          cardColor: AppColors.cardMuted,
          colorScheme: const ColorScheme.light(
            primary: AppColors.futureBlue,
            secondary: AppColors.simcoeBlue,
          ),
          iconTheme: const IconThemeData(color: AppColors.textMuted),
          dividerColor: Colors.grey,
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: AppColors.textMuted),
            bodyMedium: TextStyle(color: AppColors.textMuted),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.mutedBackground,
            foregroundColor: AppColors.textDark,
            elevation: 0,
          ),
        );
    }
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, AppThemeMode>(
  ThemeNotifier.new,
);
