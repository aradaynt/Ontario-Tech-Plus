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

// Office building option loaded from the database
class OfficeBuilding {
  final int id;
  final String name;
  final String shortname;

  const OfficeBuilding({
    required this.id,
    required this.name,
    required this.shortname,
  });
}

// Office room option loaded from the database
class OfficeRoom {
  final int id;
  final int buildingId;
  final String roomCode;

  const OfficeRoom({
    required this.id,
    required this.buildingId,
    required this.roomCode,
  });
}

// Office hour input used when saving staff details
class StaffOfficeHourInput {
  final String day;
  final String start;
  final String end;

  const StaffOfficeHourInput({
    required this.day,
    required this.start,
    required this.end,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StaffOfficeHourInput &&
        other.day == day &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode => Object.hash(day, start, end);
}

// Compare office hour lists
bool _sameOfficeHourSet(
  List<StaffOfficeHourInput> a,
  List<StaffOfficeHourInput> b,
) {
  if (a.length != b.length) return false;

  final aSorted = [...a]
    ..sort(
      (first, second) => '${first.day}|${first.start}|${first.end}'.compareTo(
        '${second.day}|${second.start}|${second.end}',
      ),
    );
  final bSorted = [...b]
    ..sort(
      (first, second) => '${first.day}|${first.start}|${first.end}'.compareTo(
        '${second.day}|${second.start}|${second.end}',
      ),
    );

  for (var i = 0; i < aSorted.length; i++) {
    if (aSorted[i] != bSorted[i]) return false;
  }

  return true;
}

// Stores currently selectedsubject filter for all courses
final courseSubjectFilterProvider =
    NotifierProvider<CourseSubjectFilterNotifier, String?>(
      CourseSubjectFilterNotifier.new,
    );

class CourseSubjectFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null; // null = All

  // Set the selected subject filter
  void setFilter(String? value) => state = value;

  // Clear the selected subject filter
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

  // Set the selected term filter
  void setTerm(String? value) => state = value;

  // Clear the selected term filter
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

final officeBuildingsProvider = FutureProvider<List<OfficeBuilding>>((
  ref,
) async {
  final supabase = ref.read(supabaseProvider);

  final rows = await supabase
      .from('building')
      .select('building_id, name, shortname')
      .order('shortname', ascending: true);

  return (rows as List).map((row) {
    final map = (row as Map).cast<String, dynamic>();
    return OfficeBuilding(
      id: (map['building_id'] as num).toInt(),
      name: (map['name'] as String?)?.trim() ?? '',
      shortname: (map['shortname'] as String?)?.trim() ?? '',
    );
  }).toList();
});

final officeRoomsByBuildingProvider =
    FutureProvider.family<List<OfficeRoom>, int>((ref, buildingId) async {
      final supabase = ref.read(supabaseProvider);

      final rows = await supabase
          .from('rooms')
          .select('room_id, building_id, room_code')
          .eq('building_id', buildingId)
          .order('room_code', ascending: true);

      return (rows as List).map((row) {
        final map = (row as Map).cast<String, dynamic>();
        return OfficeRoom(
          id: (map['room_id'] as num).toInt(),
          buildingId: (map['building_id'] as num).toInt(),
          roomCode: (map['room_code'] as String?)?.trim() ?? '',
        );
      }).toList();
    });

final enrolledCourseCanvasIdProvider = FutureProvider.family<String?, int>((
  ref,
  courseId,
) async {
  final supabase = ref.read(supabaseProvider);
  final user = ref.read(currentUserProvider);
  if (user == null) return null;

  final rows = await supabase
      .from('student_enrolled_courses')
      .select('canvas_course_id')
      .eq('user_id', user.id)
      .eq('course_id', courseId)
      .limit(1);

  if ((rows as List).isEmpty) return null;

  final row = (rows.first as Map).cast<String, dynamic>();
  return (row['canvas_course_id'] as String?)?.trim();
});

final canvasCourseLinkProvider = Provider.family<String?, String?>((ref, id) {
  final trimmed = id?.trim() ?? '';
  if (trimmed.isEmpty) return null;
  return 'https://learn.ontariotechu.ca/courses/$trimmed';
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
          id,
          role,
          instructor ( id, name, email, type, faculty, office ),
          office_hours (
            day, start, end
          )
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

// Service for enrolling a student in a course and its sections
class SectionEnrollmentService {
  final Ref ref;
  SectionEnrollmentService(this.ref);

  // Enroll the current user in the selected course sections
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

    final availableSections = await ref.read(
      courseSectionsProvider(courseId).future,
    );
    final selectedSections = availableSections
        .where((section) => sectionIds.contains(section.id))
        .toList();

    if (selectedSections.length != sectionIds.length) {
      throw Exception('Some selected course sections could not be loaded.');
    }

    final enrolledCourses = await ref.read(myEnrolledCoursesProvider.future);

    // Prevent the student from enrolling in same course twice
    EnrolledCourse? alreadyEnrolledCourse;
    for (final course in enrolledCourses) {
      if (course.courseId == courseId) {
        alreadyEnrolledCourse = course;
        break;
      }
    }

    if (alreadyEnrolledCourse != null) {
      throw Exception(
        'Already enrolled in this course:\n'
        '- ${alreadyEnrolledCourse.courseCode} ${alreadyEnrolledCourse.courseName}\n'
        '- Term: ${alreadyEnrolledCourse.term}',
      );
    }

    final selectedConflict = _findFirstConflict(
      selectedSections,
      _sectionContextForNewCourse,
    );
    if (selectedConflict != null) {
      throw ScheduleConflictException(selectedConflict);
    }

    final existingConflict = _findConflictAgainstExisting(
      selectedSections: selectedSections,
      existingCourses: enrolledCourses
          .where((course) => course.courseId != courseId)
          .toList(),
    );
    if (existingConflict != null) {
      throw ScheduleConflictException(existingConflict);
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

// Find the first conflict between the selected sections
String? _findFirstConflict(
  List<CourseSection> sections,
  _SectionContext Function(CourseSection section) contextBuilder,
) {
  for (var i = 0; i < sections.length; i++) {
    for (var j = i + 1; j < sections.length; j++) {
      final overlap = _firstOverlapDetail(sections[i], sections[j]);
      if (overlap != null) {
        final first = contextBuilder(sections[i]);
        final second = contextBuilder(sections[j]);
        return [
          'Selected sections overlap:',
          '- ${first.label}',
          '- ${second.label}',
          '- Shared time: ${overlap.summary}',
        ].join('\n');
      }
    }
  }

  return null;
}

// Find the first conflict between new selections and existing enrolled courses
String? _findConflictAgainstExisting({
  required List<CourseSection> selectedSections,
  required List<EnrolledCourse> existingCourses,
}) {
  for (final selected in selectedSections) {
    for (final course in existingCourses) {
      for (final existing in course.sections) {
        final overlap = _firstOverlapDetail(selected, existing);
        if (overlap != null) {
          final newSection = _sectionContextForNewCourse(selected);
          final currentSection = _SectionContext(
            label:
                '${course.courseCode} ${existing.scheduleType} ${existing.section}',
          );
          return [
            'Schedule conflict:',
            '- ${newSection.label}',
            '- ${currentSection.label}',
            '- Shared time: ${overlap.summary}',
          ].join('\n');
        }
      }
    }
  }

  return null;
}

// Build the display label for a newly selected section
_SectionContext _sectionContextForNewCourse(CourseSection section) {
  return _SectionContext(
    label: 'This Course ${section.scheduleType} ${section.section}',
  );
}

// Find the first overlapping meeting detail between two sections
_OverlapDetail? _firstOverlapDetail(CourseSection a, CourseSection b) {
  if (!_dateRangesOverlap(a.startDate, a.endDate, b.startDate, b.endDate)) {
    return null;
  }

  for (final aMeeting in a.meetings) {
    final aDay = aMeeting.day.trim();
    final aStart = _parseMinutes(aMeeting.startTime);
    final aEnd = _parseMinutes(aMeeting.endTime);

    if (aDay.isEmpty || aStart == null || aEnd == null || aStart >= aEnd) {
      continue;
    }

    for (final bMeeting in b.meetings) {
      final bDay = bMeeting.day.trim();
      final bStart = _parseMinutes(bMeeting.startTime);
      final bEnd = _parseMinutes(bMeeting.endTime);

      if (bDay.isEmpty || bStart == null || bEnd == null || bStart >= bEnd) {
        continue;
      }

      if (aDay == bDay && aStart < bEnd && bStart < aEnd) {
        final overlapStart = aStart > bStart ? aStart : bStart;
        final overlapEnd = aEnd < bEnd ? aEnd : bEnd;
        return _OverlapDetail(
          day: aDay,
          startMinutes: overlapStart,
          endMinutes: overlapEnd,
        );
      }
    }
  }

  return null;
}

// Check whether two section date ranges overlap
bool _dateRangesOverlap(
  DateTime aStart,
  DateTime aEnd,
  DateTime bStart,
  DateTime bEnd,
) {
  final aStartDate = DateTime(aStart.year, aStart.month, aStart.day);
  final aEndDate = DateTime(aEnd.year, aEnd.month, aEnd.day);
  final bStartDate = DateTime(bStart.year, bStart.month, bStart.day);
  final bEndDate = DateTime(bEnd.year, bEnd.month, bEnd.day);

  return !aEndDate.isBefore(bStartDate) && !bEndDate.isBefore(aStartDate);
}

// Convert a database time string into total minutes
int? _parseMinutes(String raw) {
  final parts = raw.trim().split(':');
  if (parts.length < 2) return null;

  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;

  return (hour * 60) + minute;
}

// Simple section label holder used in conflict messages
class _SectionContext {
  final String label;

  const _SectionContext({required this.label});
}

// Overlap details used for schedule conflict messages
class _OverlapDetail {
  final String day;
  final int startMinutes;
  final int endMinutes;

  const _OverlapDetail({
    required this.day,
    required this.startMinutes,
    required this.endMinutes,
  });

  // Summary text for the overlapping day and time range
  String get summary {
    return '${_shortDay(day)} ${_formatMinutes(startMinutes)}-${_formatMinutes(endMinutes)}';
  }
}

// Exception used when a selected schedule overlaps another one
class ScheduleConflictException implements Exception {
  final String message;

  const ScheduleConflictException(this.message);

  @override
  // Return the conflict message text
  String toString() => message;
}

// Convert a full weekday name into a short label
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

// Convert total minutes into an HH:mm time string
String _formatMinutes(int totalMinutes) {
  final hour = (totalMinutes ~/ 60).toString().padLeft(2, '0');
  final minute = (totalMinutes % 60).toString().padLeft(2, '0');
  return '$hour:$minute';
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
          id,
          role,
          instructor (
            id, name, email, type, faculty, office
          ),
          office_hours (
            day, start, end
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
    final sectionMap = (enrolledRow['course_sections'] as Map?)
        ?.cast<String, dynamic>();
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
// Stores one enrolled course while selected sections are being grouped
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

// Service for dropping a course for the current student
class DropCourseService {
  final Ref ref;
  DropCourseService(this.ref);

  // Drop the course and all of its selected sections
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

final sectionStaffProvider = Provider<SectionStaffService>((ref) {
  return SectionStaffService(ref);
});

// Service for adding and editing professor or TA data
class SectionStaffService {
  final Ref ref;

  SectionStaffService(this.ref);

  // Add a professor or TA to one selected course section
  Future<void> addStaffToSection({
    required int sectionId,
    required String role,
    required String name,
    required String email,
    required String faculty,
    required String office,
    List<StaffOfficeHourInput> officeHours = const [],
  }) async {
    final supabase = ref.read(supabaseProvider);

    final normalizedRole = role.trim();
    final normalizedName = name.trim();
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedName.isEmpty) {
      throw Exception('Name is required.');
    }

    _validateOfficeHours(officeHours);

    // Save the shared instructor details first
    final instructorRows = await supabase
        .from('instructor')
        .upsert({
          'name': normalizedName,
          'email': normalizedEmail.isEmpty ? null : normalizedEmail,
          'type': normalizedRole,
          'faculty': faculty.trim().isEmpty ? null : faculty.trim(),
          'office': office.trim().isEmpty ? null : office.trim(),
        }, onConflict: 'name')
        .select('id')
        .limit(1);

    if ((instructorRows as List).isEmpty) {
      throw Exception('Unable to save instructor information.');
    }

    final instructorId = ((instructorRows.first as Map)['id'] as num).toInt();

    // If this instructor is already linked to the section, update that existing row
    final existingSectionInstructorRows = await supabase
        .from('section_instructors')
        .select('id')
        .eq('section_id', sectionId)
        .eq('instructor_id', instructorId)
        .limit(1);

    int sectionInstructorId;
    if ((existingSectionInstructorRows as List).isNotEmpty) {
      sectionInstructorId =
          (((existingSectionInstructorRows.first as Map)['id']) as num).toInt();

      await supabase
          .from('section_instructors')
          .update({'role': _dbRoleForStaffType(normalizedRole)})
          .eq('id', sectionInstructorId);
    } else {
      // Otherwise create the link between the section and the instructor
      final insertedSectionInstructorRows = await supabase
          .from('section_instructors')
          .insert({
            'section_id': sectionId,
            'instructor_id': instructorId,
            'role': _dbRoleForStaffType(normalizedRole),
          })
          .select('id')
          .limit(1);

      if ((insertedSectionInstructorRows as List).isEmpty) {
        throw Exception('Unable to link staff member to this section.');
      }

      sectionInstructorId =
          (((insertedSectionInstructorRows.first as Map)['id']) as num).toInt();
    }

    // Save any office hours that were entered for this section staff record
    for (final officeHour in officeHours) {
      await supabase.from('office_hours').insert({
        'day': officeHour.day.trim(),
        'start': officeHour.start.trim(),
        'end': officeHour.end.trim(),
        'section_instructor_id': sectionInstructorId,
      });
    }

    ref.invalidate(myEnrolledCoursesProvider);
  }

  // Update professor or TA info across linked section rows
  Future<void> updateStaffForSections({
    required int courseId,
    required int instructorId,
    required List<int> sectionInstructorIds,
    required String role,
    required String name,
    required String email,
    required String faculty,
    required String office,
    List<StaffOfficeHourInput> officeHours = const [],
  }) async {
    final supabase = ref.read(supabaseProvider);

    final normalizedName = name.trim();
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedName.isEmpty) {
      throw Exception('Name is required.');
    }

    if (sectionInstructorIds.isEmpty) {
      throw Exception('No linked section instructor rows were found.');
    }

    _validateOfficeHours(officeHours);

    await supabase
        .from('instructor')
        .update({
          'name': normalizedName,
          'email': normalizedEmail.isEmpty ? null : normalizedEmail,
          'type': role.trim(),
          'faculty': faculty.trim().isEmpty ? null : faculty.trim(),
          'office': office.trim().isEmpty ? null : office.trim(),
        })
        .eq('id', instructorId);

    final dbRole = _dbRoleForStaffType(role);
    // Remove duplicate section ids and office hour rows before saving
    final uniqueSectionInstructorIds = sectionInstructorIds.toSet().toList()
      ..sort();
    final normalizedOfficeHours = officeHours
        .map(
          (officeHour) => StaffOfficeHourInput(
            day: officeHour.day.trim(),
            start: officeHour.start.trim(),
            end: officeHour.end.trim(),
          ),
        )
        .where(
          (officeHour) =>
              officeHour.day.isNotEmpty &&
              officeHour.start.isNotEmpty &&
              officeHour.end.isNotEmpty,
        )
        .toSet()
        .toList();

    for (final sectionInstructorId in uniqueSectionInstructorIds) {
      await supabase
          .from('section_instructors')
          .update({'role': dbRole})
          .eq('id', sectionInstructorId);
    }

    // Load every section_instructor row for this staff member in the course
    final courseSectionInstructorRows = await supabase
        .from('section_instructors')
        .select('id, course_sections!inner(course_id)')
        .eq('instructor_id', instructorId)
        .eq('course_sections.course_id', courseId);

    final courseSectionInstructorIds =
        (courseSectionInstructorRows as List)
            .map((row) => ((row as Map)['id'] as num?)?.toInt())
            .whereType<int>()
            .toSet()
            .toList()
          ..sort();

    final targetSectionInstructorIds = courseSectionInstructorIds.isNotEmpty
        ? courseSectionInstructorIds
        : uniqueSectionInstructorIds;

    if (targetSectionInstructorIds.isNotEmpty) {
      // Read the currently saved office hours before deciding whether to replace them
      final existingOfficeHourRows = await supabase
          .from('office_hours')
          .select('id, day, start, end')
          .inFilter('section_instructor_id', targetSectionInstructorIds);

      final existingNormalizedOfficeHours = (existingOfficeHourRows as List)
          .map((row) => (row as Map).cast<String, dynamic>())
          .map(
            (row) => StaffOfficeHourInput(
              day: (row['day'] as String?)?.trim() ?? '',
              start: (row['start'] as String?)?.trim() ?? '',
              end: (row['end'] as String?)?.trim() ?? '',
            ),
          )
          .where(
            (officeHour) =>
                officeHour.day.isNotEmpty &&
                officeHour.start.isNotEmpty &&
                officeHour.end.isNotEmpty,
          )
          .toSet()
          .toList();

      if (_sameOfficeHourSet(
        existingNormalizedOfficeHours,
        normalizedOfficeHours,
      )) {
        // Staff info may still have changed, so refresh the course view
        ref.invalidate(myEnrolledCoursesProvider);
        return;
      }

      final existingOfficeHourIds = (existingOfficeHourRows as List)
          .map((row) => ((row as Map)['id'] as num?)?.toInt())
          .whereType<int>()
          .toList();

      if (existingOfficeHourIds.isNotEmpty) {
        await supabase
            .from('office_hours')
            .delete()
            .inFilter('id', existingOfficeHourIds);
      }

      // Save one shared set of office hours for this staff member in the course
      final canonicalSectionInstructorId = targetSectionInstructorIds.first;
      for (final officeHour in normalizedOfficeHours) {
        await supabase.from('office_hours').insert({
          'day': officeHour.day,
          'start': officeHour.start,
          'end': officeHour.end,
          'section_instructor_id': canonicalSectionInstructorId,
        });
      }
    }

    ref.invalidate(myEnrolledCoursesProvider);
  }

  // Convert the UI role into the database section role
  String _dbRoleForStaffType(String role) {
    if (role.trim().toLowerCase() == 'professor') {
      return 'Primary';
    }
    return 'TA';
  }

  // Validate that each office hour entry is complete
  void _validateOfficeHours(List<StaffOfficeHourInput> officeHours) {
    for (final officeHour in officeHours) {
      if (officeHour.day.trim().isEmpty ||
          officeHour.start.trim().isEmpty ||
          officeHour.end.trim().isEmpty) {
        throw Exception(
          'Each office hour entry requires a day, start time, and end time.',
        );
      }
    }
  }
}

final courseCanvasLinkProvider = Provider<CourseCanvasLinkService>((ref) {
  return CourseCanvasLinkService(ref);
});

// Service for saving and removing Canvas routing numbers
class CourseCanvasLinkService {
  final Ref ref;

  CourseCanvasLinkService(this.ref);

  // Save the Canvas routing number for an enrolled course
  Future<void> saveCanvasCourseId({
    required int courseId,
    required String canvasCourseId,
  }) async {
    final supabase = ref.read(supabaseProvider);
    final user = ref.read(currentUserProvider);
    if (user == null) throw Exception('Not logged in.');

    final normalizedId = canvasCourseId.trim();
    if (normalizedId.isEmpty) {
      throw Exception('Canvas routing number is required.');
    }

    await supabase
        .from('student_enrolled_courses')
        .update({'canvas_course_id': normalizedId})
        .eq('user_id', user.id)
        .eq('course_id', courseId);

    ref.invalidate(enrolledCourseCanvasIdProvider(courseId));
  }

  // Delete the saved Canvas routing number for an enrolled course
  Future<void> deleteCanvasCourseId({required int courseId}) async {
    final supabase = ref.read(supabaseProvider);
    final user = ref.read(currentUserProvider);
    if (user == null) throw Exception('Not logged in.');

    await supabase
        .from('student_enrolled_courses')
        .update({'canvas_course_id': null})
        .eq('user_id', user.id)
        .eq('course_id', courseId);

    ref.invalidate(enrolledCourseCanvasIdProvider(courseId));
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

  // Set the selected term for My Courses
  void setTerm(String? term) => state = term;

  // Clear the My Courses term filter
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

// =============== Term filter for drop course page ===============
final dropCoursesTermFilterProvider =
    NotifierProvider<DropCoursesTermFilterNotifier, String?>(
      DropCoursesTermFilterNotifier.new,
    );

class DropCoursesTermFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null; // null = All terms

  // Set the selected term for Drop Course
  void setTerm(String? term) => state = term;

  // Clear the Drop Course term filter
  void clear() => state = null;
}

/// Filtered enrolled courses for drop course UI
final filteredDropEnrolledCoursesProvider =
    Provider<AsyncValue<List<EnrolledCourse>>>((ref) {
      final termFilter = ref.watch(dropCoursesTermFilterProvider);
      final enrolledAsync = ref.watch(myEnrolledCoursesProvider);

      return enrolledAsync.whenData((courses) {
        if (termFilter == null) return courses;
        return courses.where((c) => c.term.trim() == termFilter).toList();
      });
    });
