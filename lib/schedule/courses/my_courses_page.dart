// OntarioTechPlus - my_courses_page.dart

// This page is what displays users actively enrolled courses, filterable by term/semester

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ontario_tech_plus/schedule/courses/providers/courses_provider.dart';
import 'package:ontario_tech_plus/schedule/courses/models/course_section_model.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text("My Courses")),
      body: Padding(
        padding: const EdgeInsets.all(16),
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

            const SizedBox(height: 16),

            // ===========  Course List ===========
            Expanded(
              child: coursesAsync.when(
                data: (courses) {
                  if (courses.isEmpty) {
                    return Center(
                      child: Text(
                        // If not coureses, display not yet enrolled
                        selectedTerm == null
                            ? "You are not enrolled in any courses yet." // For all terms
                            : "No courses found for $selectedTerm.", // For a filter term
                      ),
                    );
                  }

                  // Render the course cards
                  return ListView.separated(
                    itemCount: courses.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final course = courses[i];

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Course title
                              Text(
                                course.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              const SizedBox(height: 4),

                              // Term and subject
                              Text(
                                "${course.term} • ${course.subjectCode} (${course.subjectName})",
                              ),

                              const SizedBox(height: 12),

                              // devider title
                              const Text(
                                "Selected Sections",
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              const Divider(height: 16),

                              // If no sections
                              if (course.sections.isEmpty)
                                const Text("No sections selected yet.")
                              else
                                // Otherwise render each selected section
                                ...course.sections.map((s) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        // section header
                                        Text(
                                          "${s.scheduleType} • Section ${s.section} • CRN ${s.crn}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),

                                        const SizedBox(height: 4),

                                        // Instructor
                                        Text(
                                          "Instructor: ${s.displayinstructor}",
                                        ),

                                        const SizedBox(height: 4),

                                        // Meeting times
                                        Text(_formatMeetings(s.meetings)),
                                      ],
                                    ),
                                  );
                                }),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },

                // Loading state spinner
                loading: () => const Center(child: CircularProgressIndicator()),

                // error to load message
                error: (e, _) =>
                    Center(child: Text("Failed to load enrolled courses: $e")),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Format meeting list into readable string
  String _formatMeetings(List<SectionMeeting> meetings) {
    if (meetings.isEmpty) return "Meeting times: TBA";

    return meetings
        .map((m) {
          final day = _shortDay(m.day);
          final start = m.startTime.length >= 5
              ? m.startTime.substring(0, 5)
              : m.startTime;
          final end = m.endTime.length >= 5
              ? m.endTime.substring(0, 5)
              : m.endTime;
          return "$day $start-$end @ ${m.displayLocation}";
        })
        .join(" • ");
  }

  // Convert full weekday to short form
  String _shortDay(String day) {
    switch (day) {
      case 'Monday':
        return 'Mon';
      case 'Tuesday':
        return 'Tue';
      case 'Wednesday':
        return 'Wed';
      case 'Thursday':
        return 'Thu';
      case 'Friday':
        return 'Fri';
      case 'Saturday':
        return 'Sat';
      case 'Sunday':
        return 'Sun';
      default:
        return day;
    }
  }
}
