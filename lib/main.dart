// OntarioTechPlus - main.dart
// NOTE: You must have a `.env` file in the project root.
// Initializes the app and Supabase using values from `.env`.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:home_widget/home_widget.dart';
import 'package:ontario_tech_plus/core/widget_manager.dart';

// Pages
import 'package:ontario_tech_plus/home/settings_page.dart';
import 'package:ontario_tech_plus/recs(ml)/reccomendation_pages.dart';
import 'package:ontario_tech_plus/auth/login_page.dart';
import 'package:ontario_tech_plus/auth/auth_providers.dart';
import 'package:ontario_tech_plus/profile/profile_page.dart';
import 'package:ontario_tech_plus/schedule/courses/my_courses_page.dart';
import 'package:ontario_tech_plus/schedule/courses/course_management_page.dart';
import 'package:ontario_tech_plus/schedule/view_my_schedule_page.dart';
import 'package:ontario_tech_plus/schedule/courses/add_course_page.dart';
import 'package:ontario_tech_plus/schedule/courses/drop_course_page.dart';
import 'package:ontario_tech_plus/shell_page.dart'; // Shell for bottom navigation
import 'package:ontario_tech_plus/theme/theme_provider.dart'; // Riverpod theme provider

@pragma('vm:entry-point')
Future<void> interactiveCallback(Uri? data) async {
  if (data?.host == 'updatewidget') {
    await WidgetManager.updateNextClassWidget();
  }
}

Future<void> main() async {
  // Ensure Flutter bindings are ready before async initialization.
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from project root `.env`.
  await dotenv.load(fileName: '.env');

  // Initialize Supabase client at app startup.
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  // Register background callback for HomeWidget
  HomeWidget.registerInteractivityCallback(interactiveCallback);

  // Update widget immediately on startup
  await WidgetManager.updateNextClassWidget();

  // ProviderScope is required for Riverpod providers.
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch auth state to decide whether to show shell or login page.
    final authState = ref.watch(authStateProvider);
    // Watch current app theme mode and computed ThemeData.
    final appThemeMode = ref.watch(themeProvider);
    final themeData = ref.watch(themeProvider.notifier).themeData;

    return MaterialApp(
      // App title
      title: 'Ontario Tech Plus',
      // Active app theme from Riverpod theme provider.
      theme: themeData.copyWith(useMaterial3: true),
      darkTheme: ThemeData.dark().copyWith(
        useMaterial3: true,
        primaryColor: const Color(0xFF003C71),
      ),
      // Use Flutter ThemeMode.dark only for dark mode; other custom modes map to light.
      themeMode: appThemeMode == AppThemeMode.dark
          ? ThemeMode.dark
          : ThemeMode.light,

      // App routes
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
      },

      // Routing based on Supabase auth session state.
      home: authState.when(
        data: (session) =>
            session != null ? const ShellPage() : const LoginPage(),
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (_, _) =>
            const LoginPage(), // If theres some type of session error, just go to login page
      ),
    );
  }
}
