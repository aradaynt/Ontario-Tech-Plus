// OntarioTechPlus - add_course_page.dart

// Page to allow a user to pick a course they would like to enroll in, bringing to enroll page with more options

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ontario_tech_plus/schedule/courses/providers/courses_provider.dart';
import 'package:ontario_tech_plus/schedule/courses/models/course_model.dart';
import 'package:ontario_tech_plus/schedule/courses/course_enroll_page.dart';

class AddCoursePage extends ConsumerWidget {
  const AddCoursePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Courses and subjects
    final subjectsAsync = ref.watch(courseSubjectOptionsProvider);
    final coursesAsync = ref.watch(filteredCoursesProvider);

    // Watch the filter options
    final selectedFilter = ref.watch(courseSubjectFilterProvider);
    final termOptionsAsync = ref.watch(courseTermOptionsProvider);
    final selectedTerm = ref.watch(courseTermFilterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Add a course")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            subjectsAsync.when(
              data: (subjects) {
                return Row(
                  children: [
                    // =========== Filter by subject ===========
                    const Text(
                      "Filter by Subject:",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        initialValue: selectedFilter,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text("All Subjects"),
                          ),
                          ...subjects.map((subject) {
                            final code = subject['code']!;
                            final name = subject['name']!;
                            return DropdownMenuItem<String?>(
                              value: code,
                              child: Text("$code — $name"),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          ref
                              .read(courseSubjectFilterProvider.notifier)
                              .setFilter(value);
                        },
                      ),
                    ),
                  ],
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (err, _) => Text("Error loading subjects: $err"),
            ),
            const SizedBox(height: 16),

            // =========== Term filter ===========
            termOptionsAsync.when(
              data: (terms) {
                if (terms.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Row(
                  children: [
                    const Text(
                      "Filter by Term:",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        initialValue: selectedTerm,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text("All Terms"),
                          ),
                          ...terms.map(
                            (t) => DropdownMenuItem<String?>(
                              value: t,
                              child: Text(t),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          ref
                              .read(courseTermFilterProvider.notifier)
                              .setTerm(value);
                        },
                      ),
                    ),
                  ],
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (err, _) => Text("Error loading terms: $err"),
            ),

            const SizedBox(height: 16),

            // =============== Course list ===============
            Expanded(
              child: coursesAsync.when(
                data: (courses) {
                  if (courses.isEmpty) {
                    return const Center(child: Text("No courses available."));
                  }

                  return ListView.separated(
                    itemCount: courses.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      return _CourseTile(course: course);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) =>
                    Center(child: Text("Error loading courses: $err")),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============== Course tile widget ===============

class _CourseTile extends ConsumerWidget {
  final Course course;
  const _CourseTile({required this.course});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(
        "${course.courseCode} — ${course.courseName}",
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        "${course.term} • ${course.subjectCode} (${course.subjectName})",
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CourseEnrollPage(course: course)),
        );
      },
    );
  }
}
