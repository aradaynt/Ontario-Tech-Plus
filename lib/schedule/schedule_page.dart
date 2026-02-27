// OntarioTechPlus - schedule_page.dart
//
//

import 'package:flutter/material.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Academics and Schedule")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 8),

              // Page explanation text
              Text(
                "Your Academic Dashboard",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                "Access your courses, timetable, and enrollment tools.",
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              ),

              const SizedBox(height: 20),

              // My courses button
              _tileDisplayCard(
                context: context,
                icon: Icons.menu_book_outlined,
                title: "My Courses",
                subtitle: "View enrolled courses and instructors",
                color: scheme.primary,
                route: '/courses',
              ),

              const SizedBox(height: 10),

              // View my schedule button
              _tileDisplayCard(
                context: context,
                icon: Icons.calendar_month_outlined,
                title: "View My Schedule",
                subtitle: "See your weekly timetable layout",
                color: Colors.teal,
                route: '/view_schedule',
              ),

              const SizedBox(height: 10),

              // Course management button
              _tileDisplayCard(
                context: context,
                icon: Icons.settings_outlined,
                title: "Course Management",
                subtitle: "Add or drop courses",
                color: Colors.orange,
                route: '/course_management',
              ),

              const SizedBox(height: 50),

              Text(
                "Tip: Keep your enrollment up to date before exams.",
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for the tile display buttons
  Widget _tileDisplayCard({
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
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
