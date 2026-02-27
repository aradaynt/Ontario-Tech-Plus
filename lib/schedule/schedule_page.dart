// OntarioTechPlus - schedule_page.dart

// Schedule page with base buttons for now "My courses, my schedule, course management"

import 'package:flutter/material.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Schedule")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/courses'),
              child: const Text("My Courses"),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/view_schedule'),
              child: const Text("View My Schedule"),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () =>
                  Navigator.pushNamed(context, '/course_management'),
              child: const Text("Course Management"),
            ),
          ],
        ),
      ),
    );
  }
}
