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
                              await _showMessageDialog(
                                title: "Selection Required",
                                message: "Please select: ${missing.join(', ')}",
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
                                await _showMessageDialog(
                                  title: "Unable to Enroll",
                                  message: _formatEnrollError(e),
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

  // Shows the enrollment popup dialog for missing selections or schedule conflicts
  Future<void> _showMessageDialog({
    required String title,
    required String message,
  }) {
    // Use the current theme so the dialog matches page styling
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // Convert raw errors into a cleaner dialog layout
    final details = _buildDialogDetails(title: title, message: message);

    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 8),
          contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          title: Row(
            children: [
              Icon(Icons.remove_circle_outline, color: scheme.error, size: 30),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  details.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (details.intro != null) ...[
                Text(
                  details.intro!,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                ),
                const SizedBox(height: 14),
              ],
              ...details.reasons.map(
                (reason) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Icon(
                          Icons.circle,
                          size: 7,
                          color: scheme.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          reason,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // Display error when course enrollement issue
  String _formatEnrollError(Object error) {
    final message = error.toString();
    const exceptionPrefix = 'Exception: ';

    // Remove the generic exception prefix before showing the message
    if (message.startsWith(exceptionPrefix)) {
      return message.substring(exceptionPrefix.length);
    }

    return message;
  }

  // Builds the dialog title, intro, and bullet points for enrollment messages
  _DialogDetails _buildDialogDetails({
    required String title,
    required String message,
  }) {
    // Missing selection case
    if (title == "Selection Required") {
      final missingPart = message.replaceFirst("Please select:", "").trim();
      final missingItems = missingPart
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();

      return _DialogDetails(
        title: title,
        intro: "Please choose the required schedule sections before enrolling.",
        reasons: missingItems.isEmpty ? [message] : missingItems,
      );
    }

    // Conflict inside the sections chosen on this page
    if (message.startsWith("Selected sections overlap:")) {
      final reasons = _extractReasonLines(message);
      return _DialogDetails(
        title: "Schedule Conflict",
        intro: "The sections you selected for this course overlap.",
        reasons: reasons.isEmpty
            ? [_cleanConflictReason(message, "Selected sections overlap:")]
            : reasons,
      );
    }

    // Conflict against courses that are already enrolled
    if (message.startsWith("Schedule conflict:")) {
      final reasons = _extractReasonLines(message);
      return _DialogDetails(
        title: "Schedule Conflict",
        intro:
            "The schedule you selected overlaps with a course already in your timetable.",
        reasons: reasons.isEmpty
            ? [_cleanConflictReason(message, "Schedule conflict:")]
            : reasons,
      );
    }

    // Duplicate enrollment for the same course error
    if (message.startsWith("Already enrolled in this course:")) {
      final reasons = _extractReasonLines(message);
      return _DialogDetails(
        title: "Enrollment Conflict",
        intro: "You are already enrolled in this course.",
        reasons: reasons.isEmpty
            ? [
                _cleanConflictReason(
                  message,
                  "Already enrolled in this course:",
                ),
              ]
            : reasons,
      );
    }

    // Fallback message for any other enrollment error
    return _DialogDetails(
      title: title,
      intro: "We couldn't finish your enrollment request.",
      reasons: [message],
    );
  }

  // Remove the error prefix and trailing period for cleaner bullets
  String _cleanConflictReason(String message, String prefix) {
    return message
        .replaceFirst(prefix, "")
        .trim()
        .replaceAll(RegExp(r'\.$'), '');
  }

  List<String> _extractReasonLines(String message) {
    // Pull bullet lines out of multi line conflicts
    return message
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.startsWith('- '))
        .map((line) => line.substring(2).trim())
        .where((line) => line.isNotEmpty)
        .toList();
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

// Simple container for dialog title, intro text, and bullet items
class _DialogDetails {
  final String title;
  final String? intro;
  final List<String> reasons;

  const _DialogDetails({
    required this.title,
    required this.intro,
    required this.reasons,
  });
}
