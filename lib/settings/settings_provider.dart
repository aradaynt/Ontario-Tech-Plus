import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Font size options (single source of truth)
enum FontSizeOption { small, medium, large, extraLarge }

class SettingsState {
  final bool courseNotifications;
  final bool recommendationAlerts;
  final bool reducedMotion;
  final FontSizeOption fontSize;

  const SettingsState({
    this.courseNotifications = true,
    this.recommendationAlerts = true,
    this.reducedMotion = false,
    this.fontSize = FontSizeOption.medium,
  });

  SettingsState copyWith({
    bool? courseNotifications,
    bool? recommendationAlerts,
    bool? reducedMotion,
    FontSizeOption? fontSize,
  }) {
    return SettingsState(
      courseNotifications: courseNotifications ?? this.courseNotifications,
      recommendationAlerts: recommendationAlerts ?? this.recommendationAlerts,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      fontSize: fontSize ?? this.fontSize,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() => const SettingsState();

  void toggleCourseNotifications(bool value) =>
      state = state.copyWith(courseNotifications: value);

  void toggleRecommendationAlerts(bool value) =>
      state = state.copyWith(recommendationAlerts: value);

  void toggleReducedMotion(bool value) =>
      state = state.copyWith(reducedMotion: value);

  void setFontSize(FontSizeOption option) =>
      state = state.copyWith(fontSize: option);
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);
