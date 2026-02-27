// OntarioTechPlus - main.dart
// PLEASE NOTE: YOU MUST HAVE THE .env IN YOUR PROJECT ROOT FOLDER
// Initializes the app including supabase using .env

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:ontario_tech_plus/auth/auth_providers.dart';
import 'package:ontario_tech_plus/auth/login_page.dart';

import 'package:ontario_tech_plus/profile/profile_page.dart'; // To display the users name and student number

import 'package:ontario_tech_plus/schedule/courses/my_courses_page.dart';
import 'package:ontario_tech_plus/schedule/courses/course_management_page.dart';
import 'package:ontario_tech_plus/schedule/view_my_schedule_page.dart';
import 'package:ontario_tech_plus/schedule/courses/add_course_page.dart';
import 'package:ontario_tech_plus/schedule/courses/drop_course_page.dart';

import 'package:ontario_tech_plus/shell_page.dart'; //This page is the shell for the nav bar

Future<void> main() async {
  //Ensures Flutter engine/bindings are ready before doing async work
  //Required for: Loading dotenv, init plugins, etc
  WidgetsFlutterBinding.ensureInitialized();

  //Load enviroment variables from .env
  await dotenv.load(fileName: '.env');

  // Initialize Supabase at app start
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  //ProviderScope is the root riverpod container
  //Required for: ref.watch, ref.read
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(
      authStateProvider,
    ); //Watch the auth state to decide routing

    return MaterialApp(
      // App title
      title: 'Ontario Tech Plus',
      // Theme
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      routes: {
        // Profile route
        '/profile': (_) => const ProfilePage(),

        // course/schedule Routes
        '/courses': (_) => const MyCoursesPage(),
        '/view_schedule': (_) => const ViewMySchedulePage(),
        '/course_management': (_) => const CourseManagementPage(),
        '/add_course': (_) => const AddCoursePage(),
        '/drop_course': (_) => const DropCoursePage(),
      },
      // Routing
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
