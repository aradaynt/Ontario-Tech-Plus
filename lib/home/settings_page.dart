// OntarioTechPlus - settings_page.dart

// This page allows the user to manage application preferences
// such as theme settings, notifications and account options.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ontario_tech_plus/theme/theme_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch current theme mode
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    // ================== Build the page ======================
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),

      // Main body with padding
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ================== Appearance Section ======================
          const Text(
            "Appearance",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          SwitchListTile(
            title: const Text("Dark Mode"),
            subtitle: const Text("Enable dark theme for the app"),
            value: isDarkMode,
            onChanged: (value) {
              // Toggle theme using provider
              ref.read(themeProvider.notifier).toggleTheme(value);
            },
          ),

          const Divider(height: 40),

          // ================== Account Section ======================
          const Text(
            "Account",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Edit Profile"),
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),

          const Divider(height: 40),

          // ================== About Section ======================
          const Text(
            "About",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          const ListTile(
            leading: Icon(Icons.info),
            title: Text("OntarioTechPlus"),
            subtitle: Text("Version 1.0.0"),
          ),
        ],
      ),
    );
  }
}
