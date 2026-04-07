// OntarioTechPlus - course_section_model.dart

// This is the model which gets the full details for a provided course section

class CourseSection {
  final int id;
  final String crn;
  final String section; // ex. "001"
  final String scheduleType; // Lecture/Tutorial/Lab
  final String campus; // Where the course is
  final DateTime startDate; // When it starts
  final DateTime endDate; // When it ends
  final String? primaryInstructorName; // primary prof names
  final List<String> allInstructorNames; // All prof names for course section
  final List<SectionInstructor> instructors; // Rich instructor details
  final List<SectionMeeting>
  meetings; // Course meetings (Lectures, Labs, Tutorials)

  const CourseSection({
    required this.id, // Primary key for section row
    required this.crn, // Course Registration num
    required this.section, // Section number (ex. 001)
    required this.scheduleType, // Lecture/Tutorial/Lab
    required this.campus, // Location (North/DT/Sync(online))
    required this.startDate, // Course start date
    required this.endDate, // Course end date
    required this.meetings, // Meeting times (Lec, lab, tut)
    required this.primaryInstructorName, // main Instructors name
    required this.allInstructorNames, // All instructors assositated with section
    required this.instructors, // Instructors with role/contact/office hour data
  });

  // Create a base courseselection. Meetings empty, instructors null
  factory CourseSection.baseFromRow(Map<String, dynamic> row) {
    return CourseSection(
      id: row['id'] as int,
      crn: (row['crn'] as String?) ?? '',
      section: (row['section'] as String?) ?? '',
      scheduleType: (row['schedule_type'] as String?) ?? '',
      campus: (row['campus'] as String?) ?? '',
      startDate: DateTime.parse(row['start_date'] as String),
      endDate: DateTime.parse(row['end_date'] as String),
      meetings: <SectionMeeting>[],
      primaryInstructorName: null,
      allInstructorNames: const [],
      instructors: const [],
    );
  }

  // Fully populated course section
  // course schedule is meeting objects
  // section instructors include all instructors for course (able to handle more than one if needed
  factory CourseSection.fromMap(Map<String, dynamic> map) {
    final meetingsRaw = (map['course_schedule'] as List?) ?? const [];
    final secInstructRaw = (map['section_instructors'] as List?) ?? const [];
    final instructors = secInstructRaw
        .map((x) => (x as Map).cast<String, dynamic>())
        .map(SectionInstructor.fromMap)
        .where((r) => r.name.isNotEmpty)
        .toList();

    // Detrmine primary instructor for display
    String? primary;
    final primaryRow = instructors.where((r) => r.role == 'Primary').toList();
    if (primaryRow.isNotEmpty) {
      primary = primaryRow.first.name;
    } else if (instructors.isNotEmpty) {
      primary = instructors.first.name;
    }

    // Build sorted list of all instructors (if multiple)
    final allNames = instructors.map((r) => r.name).toSet().toList()
      ..sort((a, b) => a.compareTo(b));

    // Construct the CourseSection with meetings parsed
    return CourseSection(
      id: map['id'] as int,
      crn: (map['crn'] as String?) ?? '',
      section: (map['section'] as String?) ?? '',
      scheduleType: (map['schedule_type'] as String?) ?? '',
      campus: (map['campus'] as String?) ?? '',
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
      meetings: meetingsRaw
          .map(
            (m) => SectionMeeting.fromMap((m as Map).cast<String, dynamic>()),
          )
          .toList(),
      primaryInstructorName: primary,
      allInstructorNames: allNames,
      instructors: instructors,
    );
  }

  /// Instructor to display for course
  String get displayinstructor {
    return primaryInstructorName?.trim().isNotEmpty == true
        ? primaryInstructorName! // Show name if not null
        : 'TBA'; // Otherwise but TBA
  }
}

class SectionInstructor {
  final int? sectionInstructorId;
  final int? instructorId;
  final String name;
  final String role;
  final String type;
  final String email;
  final String faculty;
  final String office;
  final List<InstructorOfficeHour> officeHours;

  const SectionInstructor({
    required this.sectionInstructorId,
    required this.instructorId,
    required this.name,
    required this.role,
    required this.type,
    required this.email,
    required this.faculty,
    required this.office,
    required this.officeHours,
  });

  factory SectionInstructor.fromMap(Map<String, dynamic> map) {
    final instructor =
        (map['instructor'] as Map?)?.cast<String, dynamic>() ?? {};
    final officeHoursRaw = (map['office_hours'] as List?) ?? const [];

    return SectionInstructor(
      sectionInstructorId: (map['id'] as num?)?.toInt(),
      instructorId: (instructor['id'] as num?)?.toInt(),
      name: (instructor['name'] as String?)?.trim() ?? '',
      role: (map['role'] as String?)?.trim() ?? '',
      type: (instructor['type'] as String?)?.trim() ?? '',
      email: (instructor['email'] as String?)?.trim() ?? '',
      faculty: (instructor['faculty'] as String?)?.trim() ?? '',
      office: (instructor['office'] as String?)?.trim() ?? '',
      officeHours: officeHoursRaw
          .map((row) => InstructorOfficeHour.fromMap((row as Map).cast<String, dynamic>()))
          .toList(),
    );
  }

  String get displayRole {
    final normalizedType = type.toLowerCase();
    if (normalizedType == 'ta') return 'TA';
    if (normalizedType == 'professor') return 'Professor';
    if (normalizedType == 'instructor') return 'Instructor';

    final normalizedRole = role.toLowerCase();
    if (normalizedRole == 'primary') return 'Professor';
    if (normalizedRole == 'ta') return 'TA';

    if (role.isNotEmpty) return role;
    if (type.isNotEmpty) return type;
    return 'Instructor';
  }
}

class InstructorOfficeHour {
  final String day;
  final String start;
  final String end;

  const InstructorOfficeHour({
    required this.day,
    required this.start,
    required this.end,
  });

  factory InstructorOfficeHour.fromMap(Map<String, dynamic> map) {
    return InstructorOfficeHour(
      day: (map['day'] as String?)?.trim() ?? '',
      start: (map['start'] as String?)?.trim() ?? '',
      end: (map['end'] as String?)?.trim() ?? '',
    );
  }

  String get displayRange {
    final startText = start.length >= 5 ? start.substring(0, 5) : start;
    final endText = end.length >= 5 ? end.substring(0, 5) : end;
    if (day.isEmpty && startText.isEmpty && endText.isEmpty) return 'TBA';
    if (day.isEmpty) return '$startText-$endText';
    return '$day $startText-$endText';
  }
}

// One schedueld meeting occurance for a section
class SectionMeeting {
  final String day; // enum value as string ex. "Monday"
  final String startTime; // 14:10:00
  final String endTime; // 15:30:00
  final String? buildingShort; // SCI
  final String? roomCode; // 2230

  const SectionMeeting({
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.buildingShort,
    required this.roomCode,
  });

  // Parse the nested meeting object including rooms/building related
  factory SectionMeeting.fromMap(Map<String, dynamic> map) {
    final room = (map['rooms'] as Map?)?.cast<String, dynamic>();
    final building = (room?['building'] as Map?)?.cast<String, dynamic>();

    return SectionMeeting(
      day: (map['day'] as String?) ?? '',
      startTime: (map['start_time'] as String?) ?? '',
      endTime: (map['end_time'] as String?) ?? '',
      buildingShort: building?['shortname'] as String?,
      roomCode: room?['room_code'] as String?,
    );
  }

  // Parse a flat row where bulding/room may be reutrned as sep cols
  factory SectionMeeting.fromFlatRow(Map<String, dynamic> row) {
    final buildingShort =
        (row['building_shortname'] as String?) ??
        (row['building_short'] as String?) ??
        (row['building'] as String?) ??
        (row['buildingShort'] as String?);

    // Room code
    final roomCode =
        (row['room_code'] as String?) ?? (row['roomCode'] as String?);

    // Return the sec meeting
    return SectionMeeting(
      day: (row['day'] as String?) ?? '',
      startTime: (row['start_time'] as String?) ?? '',
      endTime: (row['end_time'] as String?) ?? '',
      buildingShort: buildingShort,
      roomCode: roomCode,
    );
  }

  // Helpers to display location and time range nicely

  String get displayLocation {
    if (buildingShort == null || roomCode == null) return "TBA";
    return "$buildingShort$roomCode";
  }

  String get displayTimeRange {
    final start = startTime.length >= 5 ? startTime.substring(0, 5) : startTime;
    final end = endTime.length >= 5 ? endTime.substring(0, 5) : endTime;
    return "$start-$end";
  }
}
