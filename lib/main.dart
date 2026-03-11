import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'settings/settings_provider.dart';
import 'theme/theme_provider.dart';
import 'home/settings_page.dart';
import 'auth/login_page.dart';
import 'shell_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(const ProviderScope(child: MyApp()));
}

double getFontScale(FontSizeOption option) {
  switch (option) {
    case FontSizeOption.small:
      return 0.85;
    case FontSizeOption.medium:
      return 1.0;
    case FontSizeOption.large:
      return 1.2;
    case FontSizeOption.extraLarge:
      return 1.4;
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeState = ref.watch(themeProvider);
    final themeData = ref.watch(themeProvider.notifier).themeData;
    final settings = ref.watch(settingsProvider);

    final fontScale = getFontScale(settings.fontSize);

    return MaterialApp(
      title: 'Ontario Tech Plus',
      debugShowCheckedModeBanner: false,
      theme: themeData.copyWith(
        useMaterial3: true,
        textTheme: themeData.textTheme.apply(fontSizeFactor: fontScale),
      ),
      darkTheme: ThemeData.dark().copyWith(
        useMaterial3: true,
        textTheme: ThemeData.dark().textTheme.apply(fontSizeFactor: fontScale),
      ),
      themeMode: themeModeState == AppThemeMode.dark
          ? ThemeMode.dark
          : ThemeMode.light,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: fontScale),
        child: child!,
      ),
      home: const LoginPage(), // Replace with auth logic if needed
      routes: {
        '/settings': (_) => const SettingsPage(),
        '/shell': (_) => const ShellPage(),
      },
    );
  }
}
