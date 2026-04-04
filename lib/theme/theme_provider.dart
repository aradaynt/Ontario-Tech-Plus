// OntarioTechPlus - theme_provider
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppThemeMode { light, dark, lessSaturated }

class AppColors {
  static const futureBlue = Color(0xFF0055B7);
  static const techBlue = Color(0xFF00AEEF);
  static const techTangerine = Color(0xFFFF6F00);

  static const lightBackground = Color(0xFFF6F7F9);
  static const mutedBackground = Color(0xFFE8EAED);

  static const cardLight = Colors.white;
  static const cardMuted = Color(0xFFF1F2F4);

  static const textDark = Color(0xFF1F2933);
  static const textMuted = Color(0xFF5B6770);
  static const textWhite = Colors.white;
}

class NotificationsCardTheme extends ThemeExtension<NotificationsCardTheme> {
  final Color backgroundColor;
  final Color titleColor;
  final Color bodyColor;

  const NotificationsCardTheme({
    required this.backgroundColor,
    required this.titleColor,
    required this.bodyColor,
  });

  @override
  NotificationsCardTheme copyWith({
    Color? backgroundColor,
    Color? titleColor,
    Color? bodyColor,
  }) {
    return NotificationsCardTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      titleColor: titleColor ?? this.titleColor,
      bodyColor: bodyColor ?? this.bodyColor,
    );
  }

  @override
  NotificationsCardTheme lerp(
    ThemeExtension<NotificationsCardTheme>? other,
    double t,
  ) {
    if (other is! NotificationsCardTheme) return this;
    return NotificationsCardTheme(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      titleColor: Color.lerp(titleColor, other.titleColor, t)!,
      bodyColor: Color.lerp(bodyColor, other.bodyColor, t)!,
    );
  }
}

class ThemeNotifier extends Notifier<AppThemeMode> {
  @override
  AppThemeMode build() => AppThemeMode.light;

  void setTheme(AppThemeMode mode) => state = mode;

  ThemeData get themeData {
    final baseLight = ThemeData.light().textTheme;
    final baseDark = ThemeData.dark().textTheme;

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
          iconTheme: const IconThemeData(color: AppColors.futureBlue),
          textTheme: baseLight.copyWith(
            bodyLarge: baseLight.bodyLarge!.copyWith(
              color: AppColors.textDark,
              fontSize: 18,
            ),
            bodyMedium: baseLight.bodyMedium!.copyWith(
              color: AppColors.textMuted,
              fontSize: 16,
            ),
            bodySmall: baseLight.bodySmall!.copyWith(
              color: AppColors.textMuted,
              fontSize: 14,
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.futureBlue,
            foregroundColor: AppColors.textWhite,
            elevation: 0,
          ),
          extensions: <ThemeExtension<dynamic>>[
            const NotificationsCardTheme(
              backgroundColor: AppColors.futureBlue,
              titleColor: AppColors.textWhite,
              bodyColor: AppColors.textWhite,
            ),
          ],
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
          iconTheme: const IconThemeData(color: AppColors.futureBlue),
          textTheme: baseDark.copyWith(
            bodyLarge: baseDark.bodyLarge!.copyWith(
              color: AppColors.textWhite,
              fontSize: 18,
            ),
            bodyMedium: baseDark.bodyMedium!.copyWith(
              color: AppColors.textWhite,
              fontSize: 16,
            ),
            bodySmall: baseDark.bodySmall!.copyWith(
              color: AppColors.textWhite,
              fontSize: 14,
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.futureBlue,
            foregroundColor: AppColors.textWhite,
          ),
          extensions: <ThemeExtension<dynamic>>[
            const NotificationsCardTheme(
              backgroundColor: AppColors.futureBlue,
              titleColor: AppColors.textWhite,
              bodyColor: AppColors.textWhite,
            ),
          ],
        );

      case AppThemeMode.lessSaturated:
        return ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: AppColors.mutedBackground,
          primaryColor: AppColors.futureBlue,
          cardColor: AppColors.cardMuted,
          colorScheme: const ColorScheme.light(
            primary: AppColors.futureBlue,
            secondary: AppColors.techBlue,
          ),
          iconTheme: const IconThemeData(color: AppColors.textMuted),
          textTheme: baseLight.copyWith(
            bodyLarge: baseLight.bodyLarge!.copyWith(
              color: AppColors.textMuted,
              fontSize: 18,
            ),
            bodyMedium: baseLight.bodyMedium!.copyWith(
              color: AppColors.textMuted,
              fontSize: 16,
            ),
            bodySmall: baseLight.bodySmall!.copyWith(
              color: AppColors.textMuted,
              fontSize: 14,
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.mutedBackground,
            foregroundColor: AppColors.textDark,
            elevation: 0,
          ),
          extensions: <ThemeExtension<dynamic>>[
            const NotificationsCardTheme(
              backgroundColor: AppColors.futureBlue,
              titleColor: AppColors.textWhite,
              bodyColor: AppColors.textWhite,
            ),
          ],
        );
    }
  }

  NotificationsCardTheme get notificationsCardTheme =>
      themeData.extension<NotificationsCardTheme>()!;
}

final themeProvider = NotifierProvider<ThemeNotifier, AppThemeMode>(
  ThemeNotifier.new,
);
