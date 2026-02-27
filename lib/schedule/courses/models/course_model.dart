// OntarioTechPlus - course_model.dart

// This is a model for basic course information. The course section model covers things specific to the section:
// Ex. The instructor, the times, etc.

class Course {
  final int id;
  final String courseCode;
  final String courseName;
  final String term;

  final String subjectCode; // ex. APBS
  final String subjectName; // ex. Applied Bioscience

  const Course({
    required this.id,
    required this.courseCode,
    required this.courseName,
    required this.term,
    required this.subjectCode,
    required this.subjectName,
  });

  factory Course.fromMap(Map<String, dynamic> map) {
    final subject =
        (map['course_subjects'] as Map?)?.cast<String, dynamic>() ?? {};

    return Course(
      id: map['id'] as int,
      courseCode: (map['course_code'] as String?) ?? '',
      courseName: (map['course_name'] as String?) ?? '',
      term: (map['term'] as String?) ?? '',
      subjectCode: (subject['code'] as String?) ?? '',
      subjectName: (subject['name'] as String?) ?? '',
    );
  }
}
