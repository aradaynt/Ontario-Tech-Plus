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

    // Helper for preview text size
    TextStyle previewStyle() {
      switch (settings.fontSize) {
        case FontSizeOption.small:
          return Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14);
        case FontSizeOption.medium:
          return Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16);
        case FontSizeOption.large:
          return Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18);
        case FontSizeOption.extraLarge:
          return Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 20);
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          /// ================= Appearance =================
          const Text(
            "Appearance",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          DropdownButton<AppThemeMode>(
            value: theme,
            isExpanded: true,
            underline: Container(
              height: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
            items: const [
              DropdownMenuItem(value: AppThemeMode.light, child: Text("Light")),
              DropdownMenuItem(value: AppThemeMode.dark, child: Text("Dark")),
              DropdownMenuItem(
                value: AppThemeMode.lessSaturated,
                child: Text("Less Saturated"),
              ),
            ],
            onChanged: (mode) {
              if (mode != null) ref.read(themeProvider.notifier).setTheme(mode);
            },
          ),

          const Divider(height: 40),

          /// ================= Accessibility =================
          const Text(
            "Accessibility",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          DropdownButton<FontSizeOption>(
            value: settings.fontSize,
            isExpanded: true,
            underline: Container(
              height: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
            items: const [
              DropdownMenuItem(
                value: FontSizeOption.small,
                child: Text("Small"),
              ),
              DropdownMenuItem(
                value: FontSizeOption.medium,
                child: Text("Medium"),
              ),
              DropdownMenuItem(
                value: FontSizeOption.large,
                child: Text("Large"),
              ),
              DropdownMenuItem(
                value: FontSizeOption.extraLarge,
                child: Text("Extra Large"),
              ),
            ],
            onChanged: (size) {
              if (size != null)
                ref.read(settingsProvider.notifier).setFontSize(size);
            },
          ),
          const SizedBox(height: 10),
          Text("Preview text size", style: previewStyle()),

          const Divider(height: 40),

          /// ================= Notifications =================
          const Text(
            "Notifications",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.school, color: Color(0xFF003C71)),
            title: const Text("Course Updates"),
            subtitle: const Text("Notifications about enrolled courses"),
            value: settings.courseNotifications,
            onChanged: (value) {
              ref
                  .read(settingsProvider.notifier)
                  .toggleCourseNotifications(value);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.recommend, color: Color(0xFFE75D2A)),
            title: const Text("Recommendation Alerts"),
            subtitle: const Text("Notify when new courses are recommended"),
            value: settings.recommendationAlerts,
            onChanged: (value) {
              ref
                  .read(settingsProvider.notifier)
                  .toggleRecommendationAlerts(value);
            },
          ),

          const Divider(height: 40),

          /// ================= Account =================
          const Text(
            "Account",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Color(0xFF003C71)),
            title: const Text("Edit Profile"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.pushNamed(context, '/profile'),
          ),

          const Divider(height: 40),

          /// ================= About =================
          const Text(
            "About",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const ListTile(
            leading: Icon(Icons.info, color: Color(0xFF0077CA)),
            title: Text("OntarioTechPlus"),
            subtitle: Text("Version 1.0.0"),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
