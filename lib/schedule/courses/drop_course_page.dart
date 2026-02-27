import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/courses_provider.dart'; // myEnrolledCoursesProvider + dropCourseProvider

class DropCoursePage extends ConsumerWidget {
  const DropCoursePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enrolledAsync = ref.watch(myEnrolledCoursesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Drop a Course")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: enrolledAsync.when(
          data: (courses) {
            if (courses.isEmpty) {
              return const Center(
                child: Text("You are not enrolled in any courses."),
              );
            }

            return ListView.separated(
              itemCount: courses.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final c = courses[i];

                return ListTile(
                  title: Text(
                    c.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    "${c.term} • ${c.subjectCode} (${c.subjectName})",
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    tooltip: "Drop",
                    onPressed: () async {
                      final ok = await _confirmDrop(context, c.title);
                      if (ok != true) return;

                      try {
                        await ref
                            .read(dropCourseProvider)
                            .dropCourse(c.courseId);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Dropped ${c.courseCode}")),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Drop failed: $e")),
                          );
                        }
                      }
                    },
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text("Failed to load courses: $e")),
        ),
      ),
    );
  }

  Future<bool?> _confirmDrop(BuildContext context, String title) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Drop course?"),
          content: Text(
            "This will remove the course and all selected sections:\n\n$title",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Drop"),
            ),
          ],
        );
      },
    );
  }
}
