import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../student.dart';
import 'advisor_appointment.dart';
import 'course_appointment.dart';
import 'my_appointments.dart';

class AppointmentTypePage extends StatefulWidget {
  const AppointmentTypePage({super.key});
  @override
  State<AppointmentTypePage> createState() => AppointmentTypePageState();
}

class AppointmentTypePageState extends State<AppointmentTypePage> {
  bool _isLoading = true;
  late Student student1;

  Future<void> _initializeData() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception("User is not logged in!");
      }

      final profileResponse = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      student1 = Student(
        name: "${profileResponse['firstname']} ${profileResponse['lastname']}",
        studentid: int.parse(profileResponse['student_number'].toString()),
        email: profileResponse['email'],
        program: profileResponse['program'],
        faculty: profileResponse['faculty'],
        year: int.parse(profileResponse['year'].toString()),
        courses: [],
      );
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error initializing data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text("Schedule an Appointment")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "What do you need help with?",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              // ADVISOR BUTTON
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 80),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdvisorAppointmentPage(),
                    ),
                  );
                },
                child: const Text(
                  "Meet with an Advisor",
                  style: TextStyle(fontSize: 20),
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 80),
                  backgroundColor: colorScheme.secondary,
                  foregroundColor: colorScheme.onSecondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CourseAppointmentPage(),
                    ),
                  );
                },
                child: const Text(
                  "Course Office Hours (Prof/TA)",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 80),
                  backgroundColor: colorScheme.tertiary,
                  foregroundColor: colorScheme.onTertiary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MyAppointmentsPage(student: student1),
                    ),
                  );
                },
                child: const Text(
                  "My Appointments",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
