// OntarioTechPlus - enrolled_courses_model.dart

// This is the model for a student enrolled course. Uses the CourseSection model aswell to construct.
// It represents a single course that a student is enrolled in.

import 'package:ontario_tech_plus/schedule/courses/models/course_section_model.dart';

class EnrolledCourse {
  final int courseId; // Prim key for courses table
  final String courseCode; // ex. CSCI 2010U
  final String courseName; // ex. Data Structures
  final String term; // ex. Fall 2025

  final String subjectCode; // ex. CSCI
  final String subjectName; // ex. Computer Science

  // List all sections student is enrolled in for this course
  final List<CourseSection> sections;

  const EnrolledCourse({
    required this.courseId,
    required this.courseCode,
    required this.courseName,
    required this.term,
    required this.subjectCode,
    required this.subjectName,
    required this.sections,
  });

  // Display getter for UI to display course title
  // ex. CSCI 2010U - Data Structures
  String get title => "$courseCode — $courseName";

  // Factory constructor to build Enrolled Course from nested supabase response map
  factory EnrolledCourse.fromMap(Map<String, dynamic> map) {
    final course = (map['courses'] as Map?)?.cast<String, dynamic>() ?? {};
    final subject =
        (course['course_subjects'] as Map?)?.cast<String, dynamic>() ?? {};
    final sectionsRaw = (map['student_enrolled_sections'] as List?) ?? const [];

    final sections = sectionsRaw
        .map((e) => (e as Map).cast<String, dynamic>())
        .map(
          (e) => CourseSection.fromMap(
            (e['course_sections'] as Map).cast<String, dynamic>(),
          ),
        )
        .toList();

    // Sort sections based on schedule type (lec, lab, tut, and section code 001, 002)
    sections.sort((a, b) {
      final t = a.scheduleType.compareTo(b.scheduleType);
      if (t != 0) return t;
      return a.section.compareTo(b.section);
    });

    return EnrolledCourse(
      courseId: course['id'] as int,
      courseCode: (course['course_code'] as String?) ?? '',
      courseName: (course['course_name'] as String?) ?? '',
      term: (course['term'] as String?) ?? '',
      subjectCode: (subject['code'] as String?) ?? '',
      subjectName: (subject['name'] as String?) ?? '',
      sections: sections,
    );
  }
}
