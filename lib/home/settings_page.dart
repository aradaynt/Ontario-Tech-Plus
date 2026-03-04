// OntarioTechPlus - settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ontario_tech_plus/theme/theme_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Appearance
          const Text(
            "Appearance",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // Dropdown for Light / Dark / Less Saturated
          DropdownButton<AppThemeMode>(
            value: currentTheme,
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: AppThemeMode.light, child: Text("Light")),
              DropdownMenuItem(value: AppThemeMode.dark, child: Text("Dark")),
              DropdownMenuItem(
                value: AppThemeMode.lessSaturated,
                child: Text("Less Saturated"),
              ),
            ],
            onChanged: (mode) {
              if (mode != null) {
                ref.read(themeProvider.notifier).setTheme(mode);
              }
            },
          ),

          const Divider(height: 40),

          // Account
          const Text(
            "Account",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.person, color: Color(0xFF003C71)),
            title: const Text("Edit Profile"),
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),

          const Divider(height: 40),

          // About
          const Text(
            "About",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const ListTile(
            leading: Icon(Icons.info, color: Color(0xFF0077CA)),
            title: Text("OntarioTechPlus"),
            subtitle: Text("Version 1.0.0"),
          ),
        ],
      ),
    );
  }
}
