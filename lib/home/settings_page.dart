// OntarioTechPlus - settings_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ontario_tech_plus/theme/theme_provider.dart';
import 'package:ontario_tech_plus/settings/settings_provider.dart';

// Base font sizes for each option
const Map<FontSizeOption, double> _baseFontSizes = {
  FontSizeOption.small: 14.0,
  FontSizeOption.medium: 16.0,
  FontSizeOption.large: 18.0,
  FontSizeOption.extraLarge: 20.0,
};

// Provider that generates scaled TextStyle for the app
final textStyleProvider = Provider.family<TextStyle, BuildContext>((
  ref,
  context,
) {
  final fontSizeOption = ref.watch(settingsProvider.select((s) => s.fontSize));
  final factor = MediaQuery.of(context).textScaleFactor;

  final fontSize = (_baseFontSizes[fontSizeOption]! * factor).clamp(10.0, 30.0);

  return TextStyle(
    fontSize: fontSize,
    color: Theme.of(context).textTheme.bodyLarge?.color,
  );
});

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final settings = ref.watch(settingsProvider);
    final textStyle = ref.watch(textStyleProvider(context));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: textStyle.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Appearance
          Text(
            "Appearance",
            style: textStyle.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          DropdownButton<AppThemeMode>(
            value: theme,
            isExpanded: true,
            underline: Container(
              height: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
            selectedItemBuilder: (context) {
              return const [
                Text("Light"),
                Text("Dark"),
                Text("Less Saturated"),
              ].map((t) => Text(t.data!, style: textStyle)).toList();
            },
            items: [
              DropdownMenuItem(
                value: AppThemeMode.light,
                child: Text("Light", style: textStyle),
              ),
              DropdownMenuItem(
                value: AppThemeMode.dark,
                child: Text("Dark", style: textStyle),
              ),
              DropdownMenuItem(
                value: AppThemeMode.lessSaturated,
                child: Text("Less Saturated", style: textStyle),
              ),
            ],
            onChanged: (mode) {
              if (mode != null) ref.read(themeProvider.notifier).setTheme(mode);
            },
          ),
          const Divider(height: 40),

          // Accessibility
          Text(
            "Accessibility",
            style: textStyle.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          DropdownButton<FontSizeOption>(
            value: settings.fontSize,
            isExpanded: true,
            underline: Container(
              height: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
            selectedItemBuilder: (context) {
              return FontSizeOption.values.map((option) {
                String label;
                switch (option) {
                  case FontSizeOption.small:
                    label = "Small";
                    break;
                  case FontSizeOption.medium:
                    label = "Medium";
                    break;
                  case FontSizeOption.large:
                    label = "Large";
                    break;
                  case FontSizeOption.extraLarge:
                    label = "Extra Large";
                    break;
                }
                return Text(label, style: textStyle);
              }).toList();
            },
            items: FontSizeOption.values.map((option) {
              String label;
              switch (option) {
                case FontSizeOption.small:
                  label = "Small";
                  break;
                case FontSizeOption.medium:
                  label = "Medium";
                  break;
                case FontSizeOption.large:
                  label = "Large";
                  break;
                case FontSizeOption.extraLarge:
                  label = "Extra Large";
                  break;
              }
              return DropdownMenuItem(
                value: option,
                child: Text(label, style: textStyle),
              );
            }).toList(),
            onChanged: (size) {
              if (size != null)
                ref.read(settingsProvider.notifier).setFontSize(size);
            },
          ),
          const SizedBox(height: 10),
          Text("Preview text size", style: textStyle),
          const SizedBox(height: 10),

          // Disable animations
          SwitchListTile(
            secondary: const Icon(Icons.animation, color: Color(0xFF0077CA)),
            title: Text("Disable Animations", style: textStyle),
            subtitle: Text(
              "Turn this on to remove all animations in the app",
              style: textStyle,
            ),
            value: settings.disableAnimations,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).toggleAnimations(value);
            },
          ),
          const Divider(height: 40),

          // Notifications
          Text(
            "Notifications",
            style: textStyle.copyWith(fontWeight: FontWeight.bold),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.school, color: Color(0xFF003C71)),
            title: Text("Course Updates", style: textStyle),
            subtitle: Text(
              "Notifications about enrolled courses",
              style: textStyle,
            ),
            value: settings.courseNotifications,
            onChanged: (value) {
              ref
                  .read(settingsProvider.notifier)
                  .toggleCourseNotifications(value);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.recommend, color: Color(0xFFE75D2A)),
            title: Text("Recommendation Alerts", style: textStyle),
            subtitle: Text(
              "Notify when new courses are recommended",
              style: textStyle,
            ),
            value: settings.recommendationAlerts,
            onChanged: (value) {
              ref
                  .read(settingsProvider.notifier)
                  .toggleRecommendationAlerts(value);
            },
          ),
          const Divider(height: 40),

          // Account
          Text(
            "Account",
            style: textStyle.copyWith(fontWeight: FontWeight.bold),
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Color(0xFF003C71)),
            title: Text("Edit Profile", style: textStyle),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.pushNamed(context, '/profile'),
          ),
          const Divider(height: 40),

          // About
          Text("About", style: textStyle.copyWith(fontWeight: FontWeight.bold)),
          ListTile(
            leading: const Icon(Icons.info, color: Color(0xFF0077CA)),
            title: Text("OntarioTechPlus", style: textStyle),
            subtitle: Text("Version 1.0.0", style: textStyle),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
