// OntarioTechPlus - main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Providers
import 'package:ontario_tech_plus/auth/auth_providers.dart';
import 'package:ontario_tech_plus/theme/theme_provider.dart';
import 'package:ontario_tech_plus/settings/settings_provider.dart';

// Pages
import 'package:ontario_tech_plus/auth/login_page.dart';
import 'package:ontario_tech_plus/shell_page.dart';
import 'package:ontario_tech_plus/home/settings_page.dart';
import 'package:ontario_tech_plus/profile/profile_page.dart';
import 'package:ontario_tech_plus/schedule/courses/my_courses_page.dart';
import 'package:ontario_tech_plus/schedule/view_my_schedule_page.dart';
import 'package:ontario_tech_plus/schedule/courses/course_management_page.dart';
import 'package:ontario_tech_plus/schedule/courses/add_course_page.dart';
import 'package:ontario_tech_plus/schedule/courses/drop_course_page.dart';
import 'package:ontario_tech_plus/recs(ml)/reccomendation_pages.dart';

import 'home/menu_page.dart';
import 'home/search_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(const ProviderScope(child: MyApp()));
}

// Font scaling helper
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
    // Auth state
    final authState = ref.watch(authStateProvider);

    // Theme
    final themeModeState = ref.watch(themeProvider);
    final themeData = ref.watch(themeProvider.notifier).themeData;

    // Settings (font scaling)
    final settings = ref.watch(settingsProvider);
    final fontScale = getFontScale(settings.fontSize);

    return MaterialApp(
      title: 'Ontario Tech Plus',
      debugShowCheckedModeBanner: false,

      // Light theme
      theme: themeData.copyWith(
        useMaterial3: true,
        textTheme: themeData.textTheme.apply(fontSizeFactor: fontScale),
      ),

      // Dark theme
      darkTheme: ThemeData.dark().copyWith(
        useMaterial3: true,
        primaryColor: const Color(0xFF003C71),
        textTheme: ThemeData.dark().textTheme.apply(fontSizeFactor: fontScale),
      ),

      themeMode: themeModeState == AppThemeMode.dark
          ? ThemeMode.dark
          : ThemeMode.light,

      // Global text scaling
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: fontScale),
        child: child!,
      ),

      // Routes
      routes: {
        '/profile': (_) => const ProfilePage(),
        '/courses': (_) => const MyCoursesPage(),
        '/view_schedule': (_) => const ViewMySchedulePage(),
        '/course_management': (_) => const CourseManagementPage(),
        '/add_course': (_) => const AddCoursePage(),
        '/drop_course': (_) => const DropCoursePage(),
        '/recommendations': (_) => const RecommendationPage(),
        '/schedule': (_) => const ViewMySchedulePage(),
        '/settings': (_) => const SettingsPage(),
        '/shell': (_) => const ShellPage(),
        '/search': (_) => const SearchPage(),
        '/health': (_) => const Scaffold(body: Center(child: Text("Health"))),
        '/it': (_) => const Scaffold(body: Center(child: Text("IT Services"))),
        '/library': (_) => const Scaffold(body: Center(child: Text("Library"))),
        '/financial_aid': (_) =>
            const Scaffold(body: Center(child: Text("Aid"))),
        '/finances_undergrad': (_) =>
            const Scaffold(body: Center(child: Text("UG Finances"))),
        '/finances_grad': (_) =>
            const Scaffold(body: Center(child: Text("Grad Finances"))),
        '/menu': (_) => const MenuPage(),
      },

      // Auth-based home routing
      home: authState.when(
        data: (session) =>
            session != null ? const ShellPage() : const LoginPage(),
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (_, __) =>
            const Scaffold(body: Center(child: Text("Something went wrong"))),
      ),
    );
  }
}
