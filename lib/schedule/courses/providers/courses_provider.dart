// OntarioTechPlus - courses_provider.dart

// This is the provider for anything related to courses
// Courses, times, etc

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ontario_tech_plus/core/global_providers/supabase_provider.dart';
import 'package:ontario_tech_plus/core/global_providers/user_provider.dart';

import 'package:ontario_tech_plus/schedule/courses/models/course_section_model.dart';
import 'package:ontario_tech_plus/schedule/courses/models/enrolled_courses_model.dart';
import 'package:ontario_tech_plus/schedule/courses/models/course_model.dart';
import 'package:ontario_tech_plus/core/widget_manager.dart';

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

// Stores currently selected term filter for all courses (null = All)
final courseTermFilterProvider =
    NotifierProvider<CourseTermFilterNotifier, String?>(
      CourseTermFilterNotifier.new,
    );

class CourseTermFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null; // null = All
  void setTerm(String? value) => state = value;
  void clear() => state = null;
}

// Term dropdown options from loaded all courses
final courseTermOptionsProvider = Provider<AsyncValue<List<String>>>((ref) {
  final coursesAsync = ref.watch(allCoursesProvider);

  return coursesAsync.whenData((courses) {
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

/// Filtered list for UI
final filteredCoursesProvider = Provider<AsyncValue<List<Course>>>((ref) {
  final subjectFilter = ref.watch(courseSubjectFilterProvider);
  final termFilter = ref.watch(courseTermFilterProvider);
  final coursesAsync = ref.watch(allCoursesProvider);

  return coursesAsync.whenData((courses) {
    var filtered = courses;

    if (subjectFilter != null) {
      filtered = filtered.where((c) => c.subjectCode == subjectFilter).toList();
    }

    if (termFilter != null) {
      filtered = filtered
          .where((c) => c.term.trim() == termFilter.trim())
          .toList();
    }

    return filtered;
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

    // Replace any previously saved section choices for this course so
    // "My Courses" reflects only the selections made in the current enroll flow.
    final sectionRows = await supabase
        .from('course_sections')
        .select('id')
        .eq('course_id', courseId);

    final courseSectionIds = (sectionRows as List)
        .map((e) => (e as Map)['id'])
        .whereType<int>()
        .toList();

    if (courseSectionIds.isNotEmpty) {
      await supabase
          .from('student_enrolled_sections')
          .delete()
          .eq('user_id', user.id)
          .inFilter('section_id', courseSectionIds);
    }

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

    // Update the home widget
    await WidgetManager.updateNextClassWidget();
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

  // Query the user's enrolled section rows directly so we only return the
  // exact lecture/lab/tutorial selections they chose.
  final rows = await supabase
      .from('student_enrolled_sections')
      .select('''
      section_id,
      course_sections!inner (
        id, crn, section, schedule_type, campus, start_date, end_date,
        courses!inner (
          id, course_code, course_name, term,
          course_subjects (
            code, name
          )
        ),
        section_instructors (
          role,
          instructor (
            name
          )
        ),
        course_schedule (
          day, start_time, end_time,
          rooms (
            room_code,
            building (
              shortname
            )
          )
        )
      )
    ''')
      .eq('user_id', user.id)
      .order('created_at', ascending: true);

  // Group selected sections by course for the UI.
  final Map<int, _CourseAgg> courseAgg = {};

  for (final row in (rows as List)) {
    final enrolledRow = (row as Map).cast<String, dynamic>();
    final sectionMap =
        (enrolledRow['course_sections'] as Map?)?.cast<String, dynamic>();
    if (sectionMap == null) continue;

    final courseMap = (sectionMap['courses'] as Map?)?.cast<String, dynamic>();
    if (courseMap == null) continue;

    final subjectMap =
        (courseMap['course_subjects'] as Map?)?.cast<String, dynamic>() ?? {};

    final courseId = (courseMap['id'] as num).toInt();
    courseAgg.putIfAbsent(courseId, () {
      return _CourseAgg(
        courseId: courseId,
        courseCode: (courseMap['course_code'] as String?) ?? '',
        courseName: (courseMap['course_name'] as String?) ?? '',
        term: (courseMap['term'] as String?) ?? '',
        subjectCode: (subjectMap['code'] as String?) ?? '',
        subjectName: (subjectMap['name'] as String?) ?? '',
      );
    });

    // Null check for section id (shouldnt happen)
    final sectionId = sectionMap['id'];
    if (sectionId == null) continue;

    final secID = (sectionId as num).toInt();
    courseAgg[courseId]!.sections.putIfAbsent(
      secID,
      () => CourseSection.fromMap(sectionMap),
    );
  }

  // Convert aggregated struct into enrolledCourse list
  final courses = courseAgg.values.map((c) {
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

  courses.sort((a, b) {
    final termCompare = b.term.compareTo(a.term);
    if (termCompare != 0) return termCompare;
    return a.courseCode.compareTo(b.courseCode);
  });

  return courses;
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

    // Update the home widget
    await WidgetManager.updateNextClassWidget();
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
