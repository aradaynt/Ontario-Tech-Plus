// OntarioTechPlus - my_courses_page.dart

// This page is what displays users actively enrolled courses, filterable by term/semester

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ontario_tech_plus/schedule/courses/models/enrolled_courses_model.dart';
import 'package:ontario_tech_plus/schedule/courses/providers/courses_provider.dart';
import 'package:ontario_tech_plus/schedule/courses/view_course_page.dart';

class MyCoursesPage extends ConsumerWidget {
  const MyCoursesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Load filtered enrolled courses (depending on filter)
    final coursesAsync = ref.watch(filteredMyEnrolledCoursesProvider);
    // Load availible term options for drop down
    final termOptionsAsync = ref.watch(myEnrolledTermOptionsProvider);
    // Current selected term (null is all terms)
    final selectedTerm = ref.watch(myCoursesTermFilterProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("My Courses")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            children: [
              // ====== Term Filter ======
              termOptionsAsync.when(
                data: (terms) {
                  if (terms.isEmpty) {
                    // No terms means no filter UI
                    return const SizedBox.shrink();
                  }

                  // If no term selected yet, automatically select most recent term
                  if (selectedTerm == null) {
                    Future.microtask(() {
                      ref
                          .read(myCoursesTermFilterProvider.notifier)
                          .setTerm(
                            terms.first,
                          ); // terms already sorted newest-first
                    });
                  }

                  return Row(
                    children: [
                      const Text(
                        "Filter by Term:",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),

                      const SizedBox(width: 12),

                      // Drop down expands to fill row
                      Expanded(
                        child: DropdownButtonFormField<String?>(
                          initialValue: selectedTerm ?? terms.first,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          items: [
                            // Option for all terms
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text("All Terms"),
                            ),
                            // Dynamically add the rest of the options
                            ...terms.map(
                              (t) => DropdownMenuItem<String?>(
                                value: t,
                                child: Text(t),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            // Update term filter
                            ref
                                .read(myCoursesTermFilterProvider.notifier)
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

              const SizedBox(height: 18),

              // ===========  Course List ===========
              Expanded(
                child: coursesAsync.when(
                  data: (courses) {
                    // Empty state when no enrolled courses match the filter
                    if (courses.isEmpty) {
                      return Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            selectedTerm == null
                                ? "You are not enrolled in any courses yet."
                                : "No courses found for $selectedTerm.",
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: courses.length + 1,
                      separatorBuilder: (_, index) =>
                          SizedBox(height: index == 0 ? 20 : 14),
                      itemBuilder: (context, i) {
                        if (i == 0) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Your Enrolled Courses",
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Open any course to see its selected sections, meeting times, and instructor details.",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey.shade600,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          );
                        }

                        final course = courses[i - 1];

                        // Whole tile opens the course details page
                        return InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ViewCoursePage(course: course),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 2,
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          course.title,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          course.courseCode,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: scheme.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Instructor: ${_courseInstructorLabel(course)}",
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: Colors.grey.shade800,
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "${course.term} • ${course.subjectCode} (${course.subjectName})",
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: Colors.grey.shade700,
                                                height: 1.35,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: scheme.primary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },

                  // Loading state spinner
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),

                  // error to load message
                  error: (e, _) => Center(
                    child: Text("Failed to load enrolled courses: $e"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _courseInstructorLabel(EnrolledCourse course) {
    // Prefer professor names from lecture sections first
    final lectureProfessorNames =
        course.sections
            .where(
              (section) =>
                  section.scheduleType.trim().toLowerCase() == 'lecture',
            )
            .expand((section) => section.instructors)
            .where(
              (instructor) =>
                  instructor.type.trim().toLowerCase() == 'professor',
            )
            .map((instructor) => instructor.name.trim())
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    if (lectureProfessorNames.isNotEmpty) {
      return lectureProfessorNames.join(', ');
    }

    // Fallback to any professor linked to the course
    final professorNames =
        course.sections
            .expand((section) => section.instructors)
            .where(
              (instructor) =>
                  instructor.type.trim().toLowerCase() == 'professor',
            )
            .map((instructor) => instructor.name.trim())
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    if (professorNames.isEmpty) return 'TBA';
    return professorNames.join(', ');
  }
}
