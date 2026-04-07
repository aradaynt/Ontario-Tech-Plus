//  OntarioTechPlus - settings_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------- Font Size Enum ----------------
enum FontSizeOption { small, medium, large, extraLarge }

// ---------------- Settings State ----------------
class SettingsState {
  final FontSizeOption fontSize;
  final bool courseNotifications;
  final bool recommendationAlerts;
  final bool disableAnimations;

  const SettingsState({
    this.fontSize = FontSizeOption.medium,
    this.courseNotifications = true,
    this.recommendationAlerts = true,
    this.disableAnimations = false,
  });

  SettingsState copyWith({
    FontSizeOption? fontSize,
    bool? courseNotifications,
    bool? recommendationAlerts,
    bool? disableAnimations,
  }) {
    return SettingsState(
      fontSize: fontSize ?? this.fontSize,
      courseNotifications: courseNotifications ?? this.courseNotifications,
      recommendationAlerts: recommendationAlerts ?? this.recommendationAlerts,
      disableAnimations: disableAnimations ?? this.disableAnimations,
    );
  }
}

// ---------------- Settings Notifier ----------------
class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() => const SettingsState();

  void setFontSize(FontSizeOption size) {
    state = state.copyWith(fontSize: size);
  }

  void toggleCourseNotifications(bool value) {
    state = state.copyWith(courseNotifications: value);
  }

  void toggleRecommendationAlerts(bool value) {
    state = state.copyWith(recommendationAlerts: value);
  }

  void toggleAnimations(bool value) {
    state = state.copyWith(disableAnimations: value);
  }
}

// ---------------- Provider ----------------
final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);
