// OntarioTechPlus - view_course_enrolled_sections_page.dart

// This page allows you to see the enrolled sections for that course

import 'package:flutter/material.dart';
import 'models/enrolled_courses_model.dart';

class ViewCourseEnrolledSectionsPage extends StatelessWidget {
  // The enrolled course
  final EnrolledCourse course;

  const ViewCourseEnrolledSectionsPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text("${course.courseCode} Sections")),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          children: [
            Text(
              "Selected Sections",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "View the lecture, lab, and tutorial sections currently attached to this course.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            // Empty state if the course has no selected sections (should never happen)
            if (course.sections.isEmpty)
              Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("No sections selected yet."),
                ),
              )
            else
              // Show each selected lecture, lab, or tutorial in its own card
              ...course.sections.map(
                (section) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${section.scheduleType} • Section ${section.section}",
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _detailRow(context, "CRN", section.crn),
                          _detailRow(
                            context,
                            "Instructor",
                            section.displayinstructor,
                          ),
                          _detailRow(
                            context,
                            "Campus",
                            section.campus.isEmpty ? "TBA" : section.campus,
                          ),
                          _detailRow(
                            context,
                            "Dates",
                            "${_formatDate(section.startDate)} - ${_formatDate(section.endDate)}",
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Meetings",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (section.meetings.isEmpty)
                            Text(
                              "Meeting times: TBA",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey.shade700,
                              ),
                            )
                          else
                            ...section.meetings.map(
                              (meeting) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
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
                                        "${_shortDay(meeting.day)} ${meeting.displayTimeRange} @ ${meeting.displayLocation}",
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: Colors.grey.shade800,
                                              height: 1.35,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Reusable labeled row for section details
  Widget _detailRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade800,
            height: 1.35,
          ),
          children: [
            TextSpan(
              text: "$label: ",
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  // Convert a full date into a shorter readable format
  String _formatDate(DateTime value) {
    final month = _monthName(value.month);
    return "$month ${value.day}, ${value.year}";
  }

  // Convert a month number into a short month label
  String _monthName(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }

  // Convert full weekday names into shorter labels
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
