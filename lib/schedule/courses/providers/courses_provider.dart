// OntarioTechPlus - courses_provider.dart

// This is the provider for anything related to courses
// Courses, times, etc

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ontario_tech_plus/core/global_providers/supabase_provider.dart';
import 'package:ontario_tech_plus/core/global_providers/user_provider.dart';

import 'package:ontario_tech_plus/schedule/courses/models/course_section_model.dart';
import 'package:ontario_tech_plus/schedule/courses/models/enrolled_courses_model.dart';
import 'package:ontario_tech_plus/schedule/courses/models/course_model.dart';

// Stores currently selectedsubject filter for all courses
final courseSubjectFilterProvider =
    NotifierProvider<CourseSubjectFilterNotifier, String?>(
      CourseSubjectFilterNotifier.new,
    );

class CourseSubjectFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null; // null = All
  void setFilter(String? value) => state = value;
  void clear() => state = null;
}

// =============== Fetch all courses ===============
// Fetch ALL courses and their their subject
final allCoursesProvider = FutureProvider<List<Course>>((ref) async {
  final supabase = ref.read(supabaseProvider);

  final rows = await supabase
      .from('courses')
      .select(
        'id, course_code, course_name, term, subject_id, course_subjects(code, name)',
      )
      .order('term', ascending: false)
      .order('course_code', ascending: true);

  return (rows as List)
      .map((e) => Course.fromMap((e as Map).cast<String, dynamic>()))
      .toList();
});

/// Filtered list for UI
final filteredCoursesProvider = Provider<AsyncValue<List<Course>>>((ref) {
  final filter = ref.watch(courseSubjectFilterProvider);
  final coursesAsync = ref.watch(allCoursesProvider);

  return coursesAsync.whenData((courses) {
    if (filter == null) return courses;
    return courses.where((c) => c.subjectCode == filter).toList();
  });
});

/// Dropdown options for the loaded all courses
final courseSubjectOptionsProvider =
    Provider<AsyncValue<List<Map<String, String>>>>((ref) {
      final coursesAsync = ref.watch(allCoursesProvider);

      return coursesAsync.whenData((courses) {
        final map = <String, String>{};

        for (final c in courses) {
          if (c.subjectCode.isNotEmpty) {
            map[c.subjectCode] = c.subjectName.isNotEmpty
                ? c.subjectName
                : c.subjectCode;
          }
        }

        final entries = map.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));

        return entries.map((e) => {'code': e.key, 'name': e.value}).toList();
      });
    });

// =============== Fetch all course sections ===============

/// Fetch sections for a given course_id (includes meetings, room/building and instructor(s))
final courseSectionsProvider = FutureProvider.family<List<CourseSection>, int>((
  ref,
  courseId,
) async {
  final supabase = ref.read(supabaseProvider);

  final rows = await supabase
      .from('course_sections')
      .select('''
        id, crn, section, schedule_type, campus, start_date, end_date,
        section_instructors (
          role,
          instructor ( name )
        ),

        course_schedule (
          day, start_time, end_time,
          rooms (
            room_code,
            building ( shortname )
          )
        )
      ''')
      .eq('course_id', courseId)
      .order('schedule_type', ascending: true)
      .order('section', ascending: true);

  return (rows as List)
      .map((e) => CourseSection.fromMap((e as Map).cast<String, dynamic>()))
      .toList();
});

// =============== Provider to allow student to enroll in course  ===============

/// Enroll student into course with chosen sections
final enrollInSectionsProvider = Provider<SectionEnrollmentService>((ref) {
  return SectionEnrollmentService(ref);
});

class SectionEnrollmentService {
  final Ref ref;
  SectionEnrollmentService(this.ref);

  Future<void> enrollSections({
    required int courseId,
    required List<int> sectionIds,
  }) async {
    // Supabase and user
    final supabase = ref.read(supabaseProvider);
    final user = ref.read(currentUserProvider);

    // make sure user logged in
    if (user == null) throw Exception('Not logged in.');

    // Make sure sections are filled before reg
    if (sectionIds.isEmpty) {
      throw Exception('Select at least one section.');
    }

    // Get the current enrolled courses
    await supabase.from('student_enrolled_courses').upsert({
      'user_id': user.id,
      'course_id': courseId,
    }, onConflict: 'user_id,course_id');

    // Insert section enrollments
    final payload = sectionIds
        .map((secID) => {'user_id': user.id, 'section_id': secID})
        .toList();

    // Upsert prevents duplicates if user enrolls again
    await supabase
        .from('student_enrolled_sections')
        .upsert(payload, onConflict: 'user_id,section_id');

    // Invalidate the enrolled courses provider to cause my courses to refresh (and drop course)
    ref.invalidate(myEnrolledCoursesProvider);
  }
}

// =============== Provider to get students enrolled courses  ===============
// Loads the current users entrolled courses, sections, meetings
final myEnrolledCoursesProvider = FutureProvider<List<EnrolledCourse>>((
  ref,
) async {
  // Get supabase and user and ensure logged in
  final supabase = ref.read(supabaseProvider);
  final user = ref.read(currentUserProvider);
  if (user == null) return [];

  // Query the view which returns the flattend results
  final rows = await supabase
      .from('v_my_course_sections')
      .select('''
      user_id,
      course_id, course_code, course_name, term, subject_code, subject_name,
      section_id, crn, section, schedule_type, campus, start_date, end_date,
      day, start_time, end_time, building_shortname, room_code,
      primary_instructor_name
    ''')
      .eq('user_id', user.id)
      .order('term', ascending: false)
      .order('course_code', ascending: true);

  // Normalize rows into a list
  final list = (rows as List)
      .map((e) => (e as Map).cast<String, dynamic>())
      .toList();

  // Group by course
  final Map<int, _CourseAgg> courseAgg = {};

  // Interate every flat row and place it into correct course and section
  for (final r in list) {
    final courseId = r['course_id'] as int;
    courseAgg.putIfAbsent(courseId, () {
      return _CourseAgg(
        courseId: courseId,
        courseCode: (r['course_code'] as String?) ?? '',
        courseName: (r['course_name'] as String?) ?? '',
        term: (r['term'] as String?) ?? '',
        subjectCode: (r['subject_code'] as String?) ?? '',
        subjectName: (r['subject_name'] as String?) ?? '',
      );
    });

    // Null check for section id (shouldnt happen)
    final sectionId = r['section_id'];
    if (sectionId == null) continue;

    final secID = sectionId as int;

    // Retrieve/create the section object
    final section = courseAgg[courseId]!.sections.putIfAbsent(secID, () {
      final primaryName = (r['primary_instructor_name'] as String?)?.trim();

      return CourseSection(
        id: secID,
        crn: (r['crn'] as String?) ?? '',
        section: (r['section'] as String?) ?? '',
        scheduleType: (r['schedule_type'] as String?) ?? '',
        campus: (r['campus'] as String?) ?? '',
        startDate: DateTime.parse(r['start_date'] as String),
        endDate: DateTime.parse(r['end_date'] as String),
        meetings: <SectionMeeting>[],
        primaryInstructorName: (primaryName != null && primaryName.isNotEmpty)
            ? primaryName
            : null,
        allInstructorNames: (primaryName != null && primaryName.isNotEmpty)
            ? <String>[primaryName]
            : <String>[],
      );
    });

    // Meetng fields might be null if sec has no scheduled meetings yet
    final day = r['day'];
    final start = r['start_time'];
    final end = r['end_time'];

    // Only add meeting if all time components exist
    if (day != null && start != null && end != null) {
      section.meetings.add(
        SectionMeeting(
          day: day as String,
          startTime: start as String,
          endTime: end as String,
          buildingShort: r['building_shortname'] as String?,
          roomCode: r['room_code'] as String?,
        ),
      );
    }
  }

  // Convert aggregated struct into enrolledCourse list
  return courseAgg.values.map((c) {
    final sections = c.sections.values.toList();
    sections.sort((a, b) {
      final t = a.scheduleType.compareTo(b.scheduleType);
      if (t != 0) return t;
      return a.section.compareTo(b.section);
    });

    return EnrolledCourse(
      courseId: c.courseId,
      courseCode: c.courseCode,
      courseName: c.courseName,
      term: c.term,
      subjectCode: c.subjectCode,
      subjectName: c.subjectName,
      sections: sections,
    );
  }).toList();
});

// Internal aggregation holder used by MyEnrolledCoursesProvider
class _CourseAgg {
  final int courseId;
  final String courseCode;
  final String courseName;
  final String term;
  final String subjectCode;
  final String subjectName;

  final Map<int, CourseSection> sections = {};

  _CourseAgg({
    required this.courseId,
    required this.courseCode,
    required this.courseName,
    required this.term,
    required this.subjectCode,
    required this.subjectName,
  });
}

// =============== Provider to allow student to drop a course  ===============

final dropCourseProvider = Provider<DropCourseService>((ref) {
  return DropCourseService(ref);
});

class DropCourseService {
  final Ref ref;
  DropCourseService(this.ref);

  // Drops the course for the current user:
  // 1) Deletes enrolled sections that belong to this course
  // 2) Deletes the enrolled course row
  Future<void> dropCourse(int courseId) async {
    final supabase = ref.read(supabaseProvider);
    final user = ref.read(currentUserProvider);
    if (user == null) throw Exception('Not logged in.');

    // 1) delete section enrollments for sections in this course
    // Get all section ids for the course
    final sectionRows = await supabase
        .from('course_sections')
        .select('id')
        .eq('course_id', courseId);

    final sectionIds = (sectionRows as List)
        .map((e) => (e as Map)['id'])
        .whereType<int>()
        .toList();

    if (sectionIds.isNotEmpty) {
      await supabase
          .from('student_enrolled_sections')
          .delete()
          .eq('user_id', user.id)
          .inFilter('section_id', sectionIds);
    }

    // 2) delete course enrollment
    await supabase
        .from('student_enrolled_courses')
        .delete()
        .eq('user_id', user.id)
        .eq('course_id', courseId);

    // invalidate the only enrolled courses
    ref.invalidate(myEnrolledCoursesProvider);
  }
}

// =============== Term filter for my courses ===============
final myCoursesTermFilterProvider =
    NotifierProvider<MyCoursesTermFilterNotifier, String?>(
      MyCoursesTermFilterNotifier.new,
    );

class MyCoursesTermFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null; // null = All terms
  void setTerm(String? term) => state = term;
  void clear() => state = null;
}

/// Term dropdown options from enrolled courses
final myEnrolledTermOptionsProvider = Provider<AsyncValue<List<String>>>((ref) {
  final enrolledAsync = ref.watch(myEnrolledCoursesProvider);

  return enrolledAsync.whenData((courses) {
    final terms =
        courses
            .map((c) => c.term.trim())
            .where((t) => t.isNotEmpty)
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a)); // newest first

    return terms;
  });
});

/// Filtered enrolled courses for UI
final filteredMyEnrolledCoursesProvider =
    Provider<AsyncValue<List<EnrolledCourse>>>((ref) {
      final termFilter = ref.watch(myCoursesTermFilterProvider);
      final enrolledAsync = ref.watch(myEnrolledCoursesProvider);

      return enrolledAsync.whenData((courses) {
        if (termFilter == null) return courses;
        return courses.where((c) => c.term.trim() == termFilter).toList();
      });
    });
