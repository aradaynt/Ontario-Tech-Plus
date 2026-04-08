// OntarioTechPlus - drop_course_page.dart

// This is where a user picks the sections/times and adds the course

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/enrolled_courses_model.dart';
import 'providers/courses_provider.dart'; // myEnrolledCoursesProvider + dropCourseProvider

class DropCoursePage extends ConsumerStatefulWidget {
  const DropCoursePage({super.key});

  @override
  ConsumerState<DropCoursePage> createState() => _DropCoursePageState();
}

class _DropCoursePageState extends ConsumerState<DropCoursePage> {
  bool _hasAppliedInitialTerm = false;

  @override
  Widget build(BuildContext context) {
    // Load enrolled courses for the selected drop-page term filter
    final enrolledAsync = ref.watch(filteredDropEnrolledCoursesProvider);
    // Load available terms for the filter dropdown
    final termOptionsAsync = ref.watch(myEnrolledTermOptionsProvider);
    // Current selected term (null means all terms)
    final selectedTerm = ref.watch(dropCoursesTermFilterProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // Check if intiial term being applied
    final termOptions = termOptionsAsync.asData?.value;
    final isApplyingInitialTerm =
        !_hasAppliedInitialTerm &&
        termOptions != null &&
        termOptions.isNotEmpty &&
        selectedTerm == null;

    if (isApplyingInitialTerm) {
      // Apply the newest term before the course list is shown
      Future.microtask(() {
        ref
            .read(dropCoursesTermFilterProvider.notifier)
            .setTerm(termOptions.first);
        if (mounted) {
          setState(() => _hasAppliedInitialTerm = true);
        }
      });
    } else if (!_hasAppliedInitialTerm && termOptions != null) {
      // Mark the initial setup complete when there is nothing to auto-select
      Future.microtask(() {
        if (mounted) {
          setState(() => _hasAppliedInitialTerm = true);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Drop a Course")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            children: [
              // Term filter shown above the drop list
              termOptionsAsync.when(
                data: (terms) {
                  if (terms.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  final dropdownValue =
                      _hasAppliedInitialTerm && selectedTerm == null
                      ? null
                      : selectedTerm ?? terms.first;

                  return Row(
                    children: [
                      const Text(
                        "Filter by Term:",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String?>(
                          initialValue: dropdownValue,
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
                                .read(dropCoursesTermFilterProvider.notifier)
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
              Expanded(
                // Hold the list until the first term filter is ready
                child: isApplyingInitialTerm
                    ? const Center(child: CircularProgressIndicator())
                    : enrolledAsync.when(
                        data: (courses) {
                          // Empty state when there are no courses
                          if (courses.isEmpty) {
                            return Center(
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: scheme.surfaceContainerLowest,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.menu_book_outlined,
                                      size: 42,
                                      color: scheme.primary,
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      "No courses to drop",
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      selectedTerm == null
                                          ? "You are not enrolled in any courses right now."
                                          : "No courses found for $selectedTerm.",
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: Colors.grey.shade600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          // Section title and subtext
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
                                      "Manage Your Enrolment",
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Select a course below if you want to remove it from your enrolled courses.",
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: Colors.grey.shade600,
                                            height: 1.4,
                                          ),
                                    ),
                                  ],
                                );
                              }

                              final c = courses[i - 1];

                              // Course cards
                              return Card(
                                elevation: 2,
                                margin: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              c.title,
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              c.courseCode,
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                    color: scheme.primary,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "Instructor: ${_courseInstructorLabel(c)}",
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                    color: Colors.grey.shade800,
                                                  ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "${c.term} • ${c.subjectCode} (${c.subjectName})",
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
                                      IconButton(
                                        onPressed: () async {
                                          // Ask for confirmation before removing the course
                                          final ok = await _confirmDrop(
                                            context,
                                            c.title,
                                          );
                                          if (ok != true) return;

                                          try {
                                            // Remove the enrolled course and its selected sections
                                            await ref
                                                .read(dropCourseProvider)
                                                .dropCourse(c.courseId);

                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    "Dropped ${c.courseCode}",
                                                  ),
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    "Drop failed: $e",
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        icon: Icon(
                                          Icons.remove_circle_outline,
                                          color: scheme.error,
                                        ),
                                        tooltip: "Drop ${c.courseCode}",
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              "Failed to load courses: $e",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Course instructor labeling for drop courses
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

  // Confirmation for drop dialog
  Future<bool?> _confirmDrop(BuildContext context, String title) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        // Simple confirmation dialog before dropping the course
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
