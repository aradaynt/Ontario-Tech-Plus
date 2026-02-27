// OntarioTechPlus - course_management_page.dart

// Simple page that shows add a course, and rop a course

import 'package:flutter/material.dart';

class CourseManagementPage extends StatelessWidget {
  const CourseManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Course Management")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/add_course'),
              child: const Text("Add a course"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/drop_course'),
              child: const Text("Drop a course"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
