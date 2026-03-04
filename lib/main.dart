// OntarioTechPlus - main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
import 'package:ontario_tech_plus/shell_page.dart';
import 'package:ontario_tech_plus/theme/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final appThemeMode = ref.watch(themeProvider);
    final themeData = ref.watch(themeProvider.notifier).themeData;

    return MaterialApp(
      title: 'Ontario Tech Plus',
      theme: themeData.copyWith(useMaterial3: true),
      darkTheme: ThemeData.dark().copyWith(
        useMaterial3: true,
        primaryColor: const Color(0xFF003C71),
      ),
      themeMode: appThemeMode == AppThemeMode.dark
          ? ThemeMode.dark
          : ThemeMode.light,

      //Routing
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
