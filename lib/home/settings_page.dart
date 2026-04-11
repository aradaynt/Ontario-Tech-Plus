// OntarioTechPlus - settings_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ontario_tech_plus/theme/theme_provider.dart';
import 'package:ontario_tech_plus/settings/settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final settings = ref.watch(settingsProvider);

    final textStyle = Theme.of(context).textTheme.bodyLarge;
    final boldTextStyle = textStyle?.copyWith(fontWeight: FontWeight.bold);

    return Scaffold(
      appBar: AppBar(title: Text("Settings", style: boldTextStyle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Appearance
          Text("Appearance", style: boldTextStyle),
          const SizedBox(height: 10),
          DropdownButton<AppThemeMode>(
            value: theme,
            isExpanded: true,
            underline: Container(
              height: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
            selectedItemBuilder: (context) {
              return [
                "Light",
                "Dark",
                "Less Saturated",
              ].map((label) => Text(label, style: textStyle)).toList();
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
              if (mode != null) {
                ref.read(themeProvider.notifier).setTheme(mode);
              }
            },
          ),
          const Divider(height: 40),

          // Accessibility
          Text("Accessibility", style: boldTextStyle),
          const SizedBox(height: 10),

          // Disable animations
          SwitchListTile(
            secondary: Icon(
              Icons.animation,
              color: Theme.of(context).colorScheme.primary,
            ),
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
          Text("Notifications", style: boldTextStyle),
          SwitchListTile(
            secondary: Icon(
              Icons.school,
              color: Theme.of(context).colorScheme.primary,
            ),
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
            secondary: Icon(
              Icons.recommend,
              color: Theme.of(context).colorScheme.primary,
            ),
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
          Text("Account", style: boldTextStyle),
          ListTile(
            leading: Icon(
              Icons.person,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text("Edit Profile", style: textStyle),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.pushNamed(context, '/profile'),
          ),
          const Divider(height: 40),

          // About
          Text("About", style: boldTextStyle),
          ListTile(
            leading: Icon(
              Icons.info,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text("OntarioTechPlus", style: textStyle),
            subtitle: Text("Version 1.0.0", style: textStyle),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
