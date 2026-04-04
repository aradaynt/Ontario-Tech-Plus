// OntarioTechPlus - course_enroll_page.dart

// This is where a user picks the sections/times and adds the course

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ontario_tech_plus/schedule/courses/models/course_model.dart';
import 'package:ontario_tech_plus/schedule/courses/providers/courses_provider.dart';
import 'package:ontario_tech_plus/schedule/courses/models/course_section_model.dart';

class CourseEnrollPage extends ConsumerStatefulWidget {
  // Course being enrolled into
  final Course course;
  const CourseEnrollPage({super.key, required this.course});

  @override
  ConsumerState<CourseEnrollPage> createState() => _CourseEnrollPageState();
}

class _CourseEnrollPageState extends ConsumerState<CourseEnrollPage> {
  // Single choice per type
  int? _selectedLectureId;
  int? _selectedTutorialId;
  int? _selectedLabId;

  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    // Load sections for this course
    final sectionsAsync = ref.watch(courseSectionsProvider(widget.course.id));

    return Scaffold(
      // Show course code in app bar
      appBar: AppBar(title: Text(widget.course.courseCode)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: sectionsAsync.when(
          // === Data loaded for section ===
          data: (sections) {
            if (sections.isEmpty) {
              return const Center(
                // Default message if no sections for course
                child: Text("No sections found for this course."),
              );
            }

            // Group sections by type
            final lectures = sections
                .where((s) => _normType(s.scheduleType) == 'lecture')
                .toList();
            final tutorials = sections
                .where((s) => _normType(s.scheduleType) == 'tutorial')
                .toList();
            final labs = sections
                .where(
                  (s) =>
                      _normType(s.scheduleType) == 'laboratory' ||
                      _normType(s.scheduleType) == 'lab',
                )
                .toList();

            // Determine which types are required for registration
            final requiresLecture = lectures.isNotEmpty;
            final requiresTutorial = tutorials.isNotEmpty;
            final requiresLab = labs.isNotEmpty;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.course.courseName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                // Term and subject info
                Text(
                  "${widget.course.term} • ${widget.course.subjectCode} (${widget.course.subjectName})",
                ),

                const SizedBox(height: 16),

                const Text(
                  "Choose your schedule:",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),

                const SizedBox(height: 8),

                // Scrollable section list
                Expanded(
                  child: ListView(
                    children: [
                      // If course has lecture
                      if (requiresLecture) ...[
                        _sectionHeader("Lecture (must pick 1)"),
                        const Divider(height: 1),

                        RadioGroup<int>(
                          groupValue: _selectedLectureId,
                          onChanged: (value) {
                            setState(() => _selectedLectureId = value);
                          },
                          child: Column(
                            children: lectures
                                .map((s) => _radioTile(section: s))
                                .toList(),
                          ),
                        ),

                        const SizedBox(height: 16),
                      ],

                      // If course has tutorial
                      if (requiresTutorial) ...[
                        _sectionHeader("Tutorial (must pick 1)"),
                        const Divider(height: 1),

                        RadioGroup<int>(
                          groupValue: _selectedTutorialId,
                          onChanged: (value) {
                            setState(() => _selectedTutorialId = value);
                          },
                          child: Column(
                            children: tutorials
                                .map((s) => _radioTile(section: s))
                                .toList(),
                          ),
                        ),

                        const SizedBox(height: 16),
                      ],

                      // If course has lab
                      if (requiresLab) ...[
                        _sectionHeader("Lab (must pick 1)"),
                        const Divider(height: 1),

                        RadioGroup<int>(
                          groupValue: _selectedLabId,
                          onChanged: (value) {
                            setState(() => _selectedLabId = value);
                          },
                          child: Column(
                            children: labs
                                .map((s) => _radioTile(section: s))
                                .toList(),
                          ),
                        ),

                        const SizedBox(height: 16),
                      ],

                      // No section types found
                      if (!requiresLecture && !requiresTutorial && !requiresLab)
                        const Padding(
                          padding: EdgeInsets.only(top: 24),
                          child: Center(
                            child: Text("No selectable schedule types found."),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Enroll button
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: ElevatedButton.icon(
                    onPressed: _isSaving
                        ? null
                        : () async {
                            // Validate required selections
                            final missing = <String>[];
                            if (requiresLecture && _selectedLectureId == null) {
                              missing.add("Lecture");
                            }

                            if (requiresTutorial &&
                                _selectedTutorialId == null) {
                              missing.add("Tutorial");
                            }

                            if (requiresLab && _selectedLabId == null) {
                              missing.add("Lab");
                            }

                            if (missing.isNotEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Please select: ${missing.join(', ')}",
                                  ),
                                ),
                              );
                              return;
                            }

                            // Collect selected section ids
                            final selectedIds = <int>[
                              if (_selectedLectureId != null)
                                _selectedLectureId!,
                              if (_selectedTutorialId != null)
                                _selectedTutorialId!,
                              if (_selectedLabId != null) _selectedLabId!,
                            ];

                            setState(() => _isSaving = true);

                            try {
                              // Use enrollement provider
                              await ref
                                  .read(enrollInSectionsProvider)
                                  .enrollSections(
                                    courseId: widget.course.id,
                                    sectionIds: selectedIds,
                                  );

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Enrolled successfully."),
                                  ),
                                );
                                Navigator.pop(context);
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Enroll failed: $e")),
                                );
                              }
                            } finally {
                              if (mounted) setState(() => _isSaving = false);
                            }
                          },
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add),
                    label: Text(
                      _isSaving ? "Adding..." : "Add Selected Schedule",
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text("Failed to load sections: $e")),
        ),
      ),
    );
  }

  // ============== UI Helpers ==============

  // Section header for text
  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }

  // Radio tile for selecting a section
  Widget _radioTile({required CourseSection section}) {
    final instructor = section.primaryInstructorName?.trim();

    final instructorLine = (instructor == null || instructor.isEmpty)
        ? "Instructor: TBA"
        : "Instructor: $instructor";

    return RadioListTile<int>(
      value: section.id,
      title: Text("Section ${section.section} • CRN ${section.crn}"),
      subtitle: Text("$instructorLine\n${_formatMeetings(section.meetings)}"),
      isThreeLine: true,
      contentPadding: EdgeInsets.zero,
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

  // Convert full weekday to short
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

  // Normalize schedule type for comparisons
  String _normType(String t) => t.trim().toLowerCase();
}
