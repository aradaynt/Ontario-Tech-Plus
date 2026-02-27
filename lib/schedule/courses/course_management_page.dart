// OntarioTechPlus - course_management_page.dart
//
// Basic page which allows routing to add course and drop course

import 'package:flutter/material.dart';

class CourseManagementPage extends StatelessWidget {
  const CourseManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Course Management")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 8),

              // Page explanation text
              Text(
                "Manage your enrolled courses",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                "Add or drop courses for your current term.",
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              ),

              const SizedBox(height: 20),

              // Add a course
              _managementCard(
                context: context,
                icon: Icons.add_circle_outline,
                title: "Add a Course",
                subtitle: "Enroll in a new course for this term",
                color: scheme.primary,
                route: '/add_course',
              ),

              const SizedBox(height: 10),

              // Drop a course
              _managementCard(
                context: context,
                icon: Icons.remove_circle_outline,
                title: "Drop a Course",
                subtitle: "Remove a course from your schedule",
                color: Colors.red,
                route: '/drop_course',
              ),

              const SizedBox(height: 50),

              // Tip text
              Text(
                "Tip: You can view your timetable in the Schedule tab.",
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to nicely display the add and rop buttons
  Widget _managementCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required String route,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.pushNamed(context, route),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          child: Row(
            children: [
              // Big Plus/Minus
              Container(
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 30),
              ),

              const SizedBox(width: 16),

              //Body
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // subtitle
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Icon right arrow
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
