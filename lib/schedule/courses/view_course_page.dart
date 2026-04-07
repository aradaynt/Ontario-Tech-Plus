// OntarioTechPlus - view_course_page.dart

// This page allows you to view a specific courses details, and open it on canvas

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'models/enrolled_courses_model.dart';
import 'providers/courses_provider.dart';
import 'view_course_enrolled_sections_page.dart';

// Main page for viewing an enrolled course and related actions
class ViewCoursePage extends ConsumerWidget {
  static final Uri _canvasHomeUri = Uri.parse('https://learn.ontariotechu.ca/');

  // The enrolled course
  final EnrolledCourse course;

  const ViewCoursePage({super.key, required this.course});

  @override
  // Build the course details page
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Reload enrolled courses so the page reflects any updates made
    final enrolledAsync = ref.watch(myEnrolledCoursesProvider);

    // use the refreshed enrolled course
    final currentCourse = enrolledAsync.maybeWhen(
      data: (courses) {
        for (final enrolledCourse in courses) {
          if (enrolledCourse.courseId == course.courseId) {
            return enrolledCourse;
          }
        }
        return course;
      },
      orElse: () => course,
    );

    // Build staff cards and missing staff actions for course
    final courseStaff = _buildCourseStaff(currentCourse);
    final missingStaffActions = _buildMissingStaffActions(currentCourse);
    // Load the saved Canvas routing number for this enrolled course
    final canvasCourseIdAsync = ref.watch(
      enrolledCourseCanvasIdProvider(currentCourse.courseId),
    );
    final canvasCourseId = canvasCourseIdAsync.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );
    final canvasCourseLink = ref.watch(
      canvasCourseLinkProvider(canvasCourseId),
    );

    return Scaffold(
      appBar: AppBar(title: Text(currentCourse.courseCode)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          children: [
            // Course summary card
            Card(
              elevation: 2,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentCourse.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Instructor: ${_courseInstructorLabel(currentCourse)}",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${currentCourse.term} • ${currentCourse.subjectCode} (${currentCourse.subjectName})",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Canvas and course route options button
            SizedBox(
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final routingNumber = canvasCourseId?.trim() ?? '';

                        if (routingNumber.isEmpty) {
                          await _showCanvasCourseIdDialog(
                            context,
                            ref,
                            currentCourse.courseId,
                          );
                          return;
                        }

                        await _openCanvasCourse(context, canvasCourseLink);
                      },
                      icon: const Icon(Icons.open_in_new),
                      label: const Text("View Course on Canvas"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  if ((canvasCourseId ?? '').trim().isNotEmpty) ...[
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () => _showCanvasCourseIdDialog(
                        context,
                        ref,
                        currentCourse.courseId,
                        initialValue: canvasCourseId,
                      ),
                      icon: const Icon(Icons.settings_outlined),
                      tooltip: "Edit Canvas routing number",
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Button for course selected sections page
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ViewCourseEnrolledSectionsPage(course: currentCourse),
                    ),
                  );
                },
                icon: const Icon(Icons.view_list_outlined),
                label: const Text("View Enrolled Sections"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Professor and TA section
            Text(
              "Professor and TA Information",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            if (courseStaff.isEmpty && missingStaffActions.isEmpty)
              Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("No professor or TA information available yet."),
                ),
              )
            else
              // professor and TA cards
              ...courseStaff.map(
                (staff) => Padding(
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
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  staff.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () =>
                                    _showEditStaffDialog(context, ref, staff),
                                icon: const Icon(Icons.edit_outlined),
                                tooltip: "Edit ${staff.name}",
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _detailRow(
                            context,
                            "Role",
                            _displayValue(staff.role),
                          ),
                          _detailRow(
                            context,
                            "Email",
                            _displayValue(staff.email),
                          ),
                          _detailRow(
                            context,
                            "Office",
                            _displayOfficeValue(staff.office),
                          ),
                          _detailListRow(
                            context,
                            "Office Hour",
                            staff.officeHours.isEmpty
                                ? const ["Not Available"]
                                : staff.officeHours,
                          ),
                          _detailRow(
                            context,
                            "Sections",
                            staff.sections.isEmpty
                                ? "Not Available"
                                : staff.sections.join(", "),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ...missingStaffActions.map(
              // Add button cards for sections that are missing staff info
              (_MissingStaffAction action) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          action.label,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Selected section does not have ${action.role.toUpperCase()} details yet.",
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade700,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Center(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _showAddStaffDialog(context, ref, action),
                            icon: const Icon(Icons.add),
                            label: Text(action.buttonLabel),
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

  // Reusable labeled detail row
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

  // Detail row for course staff data like office hours or section lists
  Widget _detailListRow(
    BuildContext context,
    String label,
    List<String> values,
  ) {
    // Labeled row that shows a bulleted list of values
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label:",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          ...values.map(
            (value) => Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("• "),
                  Expanded(
                    child: Text(
                      value,
                      style: theme.textTheme.bodyMedium?.copyWith(
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
    );
  }

  // Build course instructor label
  String _courseInstructorLabel(EnrolledCourse course) {
    final lectureProfessorNames =
        course.sections
            .where(
              (section) =>
                  section.scheduleType.trim().toLowerCase() == 'lecture',
            )
            .expand((section) => section.instructors)
            .where(
              (instructor) =>
                  instructor.type.trim().toLowerCase() == 'professor',
            )
            .map((instructor) => instructor.name.trim())
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    if (lectureProfessorNames.isNotEmpty) {
      return lectureProfessorNames.join(', ');
    }

    final professorNames =
        course.sections
            .expand((section) => section.instructors)
            .where(
              (instructor) =>
                  instructor.type.trim().toLowerCase() == 'professor',
            )
            .map((instructor) => instructor.name.trim())
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    if (professorNames.isEmpty) return 'TBA';
    return professorNames.join(', ');
  }

  // Show fallback text when a staff field is missing
  String _displayValue(String value) {
    return value.trim().isEmpty ? 'Not Available' : value;
  }

  // Format the office field for cleaner display
  String _displayOfficeValue(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Not Available';

    final compactOffice = RegExp(r'^([A-Za-z]+)\s*(\d+[A-Za-z]?)$');
    final match = compactOffice.firstMatch(trimmed);
    if (match == null) return trimmed;

    final building = match.group(1) ?? '';
    final room = match.group(2) ?? '';
    return '$building $room'.trim();
  }

  List<_CourseStaffInfo> _buildCourseStaff(EnrolledCourse course) {
    // Group instructors together across sections so each person shows once
    final byKey = <String, _CourseStaffBuilder>{};

    for (final section in course.sections) {
      for (final instructor in section.instructors) {
        if (instructor.name.trim().isEmpty) continue;

        final key =
            '${instructor.name.trim().toLowerCase()}|${instructor.email.trim().toLowerCase()}|${instructor.displayRole.toLowerCase()}';
        final existing = byKey.putIfAbsent(
          key,
          () => _CourseStaffBuilder(
            instructorId: instructor.instructorId ?? -1,
            name: instructor.name.trim(),
            role: instructor.displayRole,
            email: instructor.email.trim(),
            office: instructor.office.trim(),
            faculty: instructor.faculty.trim(),
          ),
        );

        if (existing.instructorId == -1 && instructor.instructorId != null) {
          existing.instructorId = instructor.instructorId!;
        }
        if (existing.email.isEmpty && instructor.email.trim().isNotEmpty) {
          existing.email = instructor.email.trim();
        }
        if (existing.office.isEmpty && instructor.office.trim().isNotEmpty) {
          existing.office = instructor.office.trim();
        }
        if (existing.faculty.isEmpty && instructor.faculty.trim().isNotEmpty) {
          existing.faculty = instructor.faculty.trim();
        }

        if (instructor.sectionInstructorId != null) {
          existing.sectionInstructorIds.add(instructor.sectionInstructorId!);
        }
        existing.sections.add('${section.scheduleType} ${section.section}');
        existing.officeHours.addAll(
          instructor.officeHours
              .map((officeHour) => officeHour.displayRange)
              .where((value) => value != 'TBA'),
        );
      }
    }

    final staff = byKey.values.map((builder) => builder.build()).toList()
      ..sort((a, b) {
        final roleCompare = _staffRoleRank(
          a.role,
        ).compareTo(_staffRoleRank(b.role));
        if (roleCompare != 0) return roleCompare;
        return a.name.compareTo(b.name);
      });

    return staff;
  }

  // Rank staff roles so professor cards appear before TA cards
  int _staffRoleRank(String role) {
    final normalized = role.toLowerCase();
    if (normalized == 'professor') return 0;
    if (normalized == 'ta') return 1;
    return 2;
  }

  List<_MissingStaffAction> _buildMissingStaffActions(EnrolledCourse course) {
    // Create add buttons for sections that are missing the expected staff role
    final actions = <_MissingStaffAction>[];

    for (final section in course.sections) {
      final expectedRole = _expectedStaffRole(section.scheduleType);
      if (expectedRole == null) continue;

      final hasStaffInfo = section.instructors.any((instructor) {
        return instructor.name.trim().isNotEmpty &&
            instructor.displayRole.toLowerCase() == expectedRole.toLowerCase();
      });

      if (!hasStaffInfo) {
        actions.add(
          _MissingStaffAction(
            sectionId: section.id,
            role: expectedRole,
            sectionTypeLabel: _sectionTypeLabel(section.scheduleType),
            sectionCode: section.section,
            label:
                'Add $expectedRole for ${_sectionTypeLabel(section.scheduleType)} - Section ${section.section}',
            buttonLabel:
                'Add $expectedRole for ${_sectionTypeLabel(section.scheduleType)}',
          ),
        );
      }
    }

    return actions;
  }

  // Determine which role a section type should have
  String? _expectedStaffRole(String scheduleType) {
    switch (scheduleType.trim().toLowerCase()) {
      case 'lecture':
        return 'Professor';
      case 'lab':
      case 'laboratory':
      case 'tutorial':
        return 'TA';
      default:
        return null;
    }
  }

  // Normalize section type text for buttons and dialog labels
  String _sectionTypeLabel(String scheduleType) {
    switch (scheduleType.trim().toLowerCase()) {
      case 'laboratory':
      case 'lab':
        return 'Lab';
      case 'lecture':
        return 'Lecture';
      case 'tutorial':
        return 'Tutorial';
      default:
        return scheduleType;
    }
  }

  // Open the add-staff popup for a missing professor or TA
  Future<void> _showAddStaffDialog(
    BuildContext context,
    WidgetRef ref,
    _MissingStaffAction action,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return _AddStaffDialog(
          action: action,
          onSave:
              ({
                required String name,
                required String email,
                required String faculty,
                required String office,
                required List<StaffOfficeHourInput> officeHours,
              }) async {
                await ref
                    .read(sectionStaffProvider)
                    .addStaffToSection(
                      sectionId: action.sectionId,
                      role: action.role,
                      name: name,
                      email: email,
                      faculty: faculty,
                      office: office,
                      officeHours: officeHours,
                    );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "${action.role} information added for ${action.sectionTypeLabel} ${action.sectionCode}.",
                      ),
                    ),
                  );
                }
              },
          formatErrorMessage: _formatErrorMessage,
        );
      },
    );
  }

  // Open the edit popup with the current staff info prefilled
  Future<void> _showEditStaffDialog(
    BuildContext context,
    WidgetRef ref,
    _CourseStaffInfo staff,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return _AddStaffDialog(
          action: _MissingStaffAction(
            sectionId: staff.sectionInstructorIds.isEmpty
                ? -1
                : staff.sectionInstructorIds.first,
            role: staff.role,
            sectionTypeLabel: '',
            sectionCode: '',
            label: "Edit ${staff.role}",
            buttonLabel: "Edit ${staff.role}",
          ),
          initialName: staff.name,
          initialEmail: staff.email,
          initialFaculty: staff.faculty,
          initialOffice: staff.office,
          initialOfficeHours: staff.officeHours,
          onSave:
              ({
                required String name,
                required String email,
                required String faculty,
                required String office,
                required List<StaffOfficeHourInput> officeHours,
              }) async {
                await ref
                    .read(sectionStaffProvider)
                    .updateStaffForSections(
                      instructorId: staff.instructorId,
                      sectionInstructorIds: staff.sectionInstructorIds,
                      role: staff.role,
                      name: name,
                      email: email,
                      faculty: faculty,
                      office: office,
                      officeHours: officeHours,
                    );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("${staff.role} information updated."),
                    ),
                  );
                }
              },
          formatErrorMessage: _formatErrorMessage,
        );
      },
    );
  }

  // Open the Canvas routing dialog for the selected course
  Future<void> _showCanvasCourseIdDialog(
    BuildContext context,
    WidgetRef ref,
    int courseId, {
    String? initialValue,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return _CanvasCourseIdDialog(
          initialValue: initialValue,
          onSave: (value) async {
            await ref
                .read(courseCanvasLinkProvider)
                .saveCanvasCourseId(courseId: courseId, canvasCourseId: value);
          },
          onProceedWithoutRoute: initialValue?.trim().isEmpty ?? true
              ? () => _openCanvasCourse(context, _canvasHomeUri.toString())
              : null,
          onDelete: initialValue?.trim().isNotEmpty == true
              ? () async {
                  await ref
                      .read(courseCanvasLinkProvider)
                      .deleteCanvasCourseId(courseId: courseId);
                }
              : null,
          formatErrorMessage: _formatErrorMessage,
        );
      },
    );
  }

  // Open Canvas using the saved course route or fallback URL
  Future<void> _openCanvasCourse(BuildContext context, String? url) async {
    if (url == null || url.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Canvas link is not set yet.")),
      );
      return;
    }

    final uri = Uri.parse(url);
    var launched = false;

    try {
      launched = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    } catch (_) {
      try {
        launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (_) {
        launched = false;
      }
    }

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to open Canvas right now.")),
      );
    }
  }

  // Clean provider errors before showing them in snackbars
  String _formatErrorMessage(Object error) {
    final message = error.toString();
    const prefix = 'Exception: ';

    if (message.startsWith(prefix)) {
      return message.substring(prefix.length);
    }

    return message;
  }
}

// Helper class that combines the same professor or TA across multiple selected sections
class _CourseStaffBuilder {
  int instructorId;
  final String name;
  final String role;
  String email;
  String office;
  String faculty;
  final Set<int> sectionInstructorIds = {};
  final Set<String> sections = {};
  final Set<String> officeHours = {};

  _CourseStaffBuilder({
    required this.instructorId,
    required this.name,
    required this.role,
    required this.email,
    required this.office,
    required this.faculty,
  });

  // Convert grouped staff data into the final UI model
  _CourseStaffInfo build() {
    final sectionList = sections.toList()..sort();
    final officeHourList = officeHours.toList()..sort();

    return _CourseStaffInfo(
      instructorId: instructorId,
      sectionInstructorIds: sectionInstructorIds.toList()..sort(),
      name: name,
      role: role,
      email: email,
      office: office,
      faculty: faculty,
      sections: sectionList,
      officeHours: officeHourList,
    );
  }
}

// Final display model for one professor or TA card
class _CourseStaffInfo {
  final int instructorId;
  final List<int> sectionInstructorIds;
  final String name;
  final String role;
  final String email;
  final String office;
  final String faculty;
  final List<String> sections;
  final List<String> officeHours;

  const _CourseStaffInfo({
    required this.instructorId,
    required this.sectionInstructorIds,
    required this.name,
    required this.role,
    required this.email,
    required this.office,
    required this.faculty,
    required this.sections,
    required this.officeHours,
  });
}

// UI info for a section that is missing staff details
class _MissingStaffAction {
  final int sectionId;
  final String role;
  final String sectionTypeLabel;
  final String sectionCode;
  final String label;
  final String buttonLabel;

  const _MissingStaffAction({
    required this.sectionId,
    required this.role,
    required this.sectionTypeLabel,
    required this.sectionCode,
    required this.label,
    required this.buttonLabel,
  });
}

// Dialog used to add or edit professor and TA details
class _AddStaffDialog extends ConsumerStatefulWidget {
  final _MissingStaffAction action;
  final String? initialName;
  final String? initialEmail;
  final String? initialFaculty;
  final String? initialOffice;
  final List<String>? initialOfficeHours;
  final Future<void> Function({
    required String name,
    required String email,
    required String faculty,
    required String office,
    required List<StaffOfficeHourInput> officeHours,
  })
  onSave;
  final String Function(Object error) formatErrorMessage;

  const _AddStaffDialog({
    required this.action,
    this.initialName,
    this.initialEmail,
    this.initialFaculty,
    this.initialOffice,
    this.initialOfficeHours,
    required this.onSave,
    required this.formatErrorMessage,
  });

  @override
  ConsumerState<_AddStaffDialog> createState() => _AddStaffDialogState();
}

// Add staff
class _AddStaffDialogState extends ConsumerState<_AddStaffDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _facultyController = TextEditingController();

  bool _isSaving = false;
  OfficeBuilding? _selectedBuilding;
  OfficeRoom? _selectedRoom;
  bool _didPrefill = false;
  final List<_OfficeHourDraft> _officeHours = [];

  @override
  // Prefill dialog fields when editing existing staff data
  void initState() {
    super.initState();
    _nameController.text = widget.initialName ?? '';
    _emailController.text = widget.initialEmail ?? '';
    _facultyController.text = widget.initialFaculty ?? '';

    // Prefill any existing office hours when editing staff info
    final initialOfficeHours = widget.initialOfficeHours ?? const [];
    for (final officeHour in initialOfficeHours) {
      final draft = _parseOfficeHourDraft(officeHour);
      if (draft != null) {
        _officeHours.add(draft);
      }
    }
  }

  @override
  // Dispose dialog controllers when the popup closes
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _facultyController.dispose();
    super.dispose();
  }

  @override
  // Build the add/edit staff dialog
  Widget build(BuildContext context) {
    // Load buildings and rooms for office selection
    final buildingsAsync = ref.watch(officeBuildingsProvider);
    final roomsAsync = _selectedBuilding == null
        ? null
        : ref.watch(officeRoomsByBuildingProvider(_selectedBuilding!.id));

    // Prefill the saved office building on first load
    buildingsAsync.whenData((buildings) {
      if (_didPrefill) return;

      final office = (widget.initialOffice ?? '').trim();
      if (office.isEmpty || office == 'Not Available') {
        _didPrefill = true;
        return;
      }

      final match = RegExp(r'^([A-Za-z]+)\s*(.+)$').firstMatch(office);
      if (match == null) {
        _didPrefill = true;
        return;
      }

      final shortname = match.group(1)?.trim() ?? '';
      OfficeBuilding? building;
      for (final item in buildings) {
        if (item.shortname == shortname) {
          building = item;
          break;
        }
      }

      if (building != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() {
            _selectedBuilding = building;
          });
        });
      }

      _didPrefill = true;
    });

    if (_selectedBuilding != null && roomsAsync != null) {
      // Prefill the saved office room once the room list has loaded
      roomsAsync.whenData((rooms) {
        if (_selectedRoom != null) return;

        final office = (widget.initialOffice ?? '').trim();
        if (office.isEmpty || office == 'Not Available') return;

        final match = RegExp(r'^([A-Za-z]+)\s*(.+)$').firstMatch(office);
        final roomCode = match?.group(2)?.trim() ?? '';
        OfficeRoom? room;
        for (final item in rooms) {
          if (item.roomCode == roomCode) {
            room = item;
            break;
          }
        }

        if (room != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() {
              _selectedRoom = room;
            });
          });
        }
      });
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(widget.action.label),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic staff details
              Text(
                "Enter the available ${widget.action.role.toLowerCase()} details below.",
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return "Name is required";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              const SizedBox(height: 16),
              // Office location and office hours
              Text(
                "Office Hours",
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              buildingsAsync.when(
                data: (buildings) {
                  return DropdownButtonFormField<OfficeBuilding>(
                    initialValue: _selectedBuilding,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: "Office Building",
                      border: OutlineInputBorder(),
                    ),
                    items: buildings
                        .map(
                          (building) => DropdownMenuItem<OfficeBuilding>(
                            value: building,
                            child: Text(
                              building.shortname.isEmpty
                                  ? building.name
                                  : "${building.shortname} - ${building.name}",
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    selectedItemBuilder: (context) {
                      return buildings.map((building) {
                        final label = building.shortname.isEmpty
                            ? building.name
                            : "${building.shortname} - ${building.name}";
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            label,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        );
                      }).toList();
                    },
                    onChanged: _isSaving
                        ? null
                        : (value) {
                            setState(() {
                              _selectedBuilding = value;
                              _selectedRoom = null;
                            });
                          },
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (error, _) => Text("Failed to load buildings: $error"),
              ),
              const SizedBox(height: 12),
              if (_selectedBuilding != null)
                roomsAsync!.when(
                  data: (rooms) {
                    return DropdownButtonFormField<OfficeRoom>(
                      initialValue: _selectedRoom,
                      decoration: const InputDecoration(
                        labelText: "Office Room",
                        border: OutlineInputBorder(),
                      ),
                      items: rooms
                          .map(
                            (room) => DropdownMenuItem<OfficeRoom>(
                              value: room,
                              child: Text(room.roomCode),
                            ),
                          )
                          .toList(),
                      onChanged: _isSaving
                          ? null
                          : (value) {
                              setState(() => _selectedRoom = value);
                            },
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (error, _) => Text("Failed to load rooms: $error"),
                )
              else
                const Text("Select an office building to choose a room."),
              const SizedBox(height: 12),
              ..._buildOfficeHourEditors(),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _isSaving
                    ? null
                    : () {
                        setState(() {
                          _officeHours.add(_OfficeHourDraft.empty());
                        });
                      },
                icon: const Icon(Icons.add),
                label: Text(
                  _hasAnyOfficeHourValue
                      ? "Add Another Office Hour"
                      : "Add Office Hour",
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: Text(_isSaving ? "Saving..." : "Save"),
        ),
      ],
    );
  }

  // Validate and save the entered staff information
  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);

    try {
      await widget.onSave(
        name: _nameController.text,
        email: _emailController.text,
        faculty: _facultyController.text,
        office: _selectedRoom == null || _selectedBuilding == null
            ? ''
            : "${_selectedBuilding!.shortname} ${_selectedRoom!.roomCode}",
        officeHours: _officeHours
            .where((draft) => draft.hasAnyValue)
            .map(
              (draft) => StaffOfficeHourInput(
                day: draft.day ?? '',
                start: draft.start == null ? '' : _toDbTime(draft.start!),
                end: draft.end == null ? '' : _toDbTime(draft.end!),
              ),
            )
            .toList(),
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(widget.formatErrorMessage(e))));
        setState(() => _isSaving = false);
      }
    }
  }

  // Build editable cards for each office hour row
  List<Widget> _buildOfficeHourEditors() {
    final widgets = <Widget>[];

    for (var i = 0; i < _officeHours.length; i++) {
      final draft = _officeHours[i];

      widgets.add(
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Office Hour ${i + 1}",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _isSaving
                        ? null
                        : () {
                            setState(() {
                              _officeHours.removeAt(i);
                            });
                          },
                    icon: const Icon(Icons.delete_outline),
                    tooltip: "Remove office hour",
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: draft.day,
                decoration: const InputDecoration(
                  labelText: "Day",
                  border: OutlineInputBorder(),
                ),
                items: _weekdays
                    .map(
                      (day) => DropdownMenuItem<String>(
                        value: day,
                        child: Text(day),
                      ),
                    )
                    .toList(),
                onChanged: _isSaving
                    ? null
                    : (value) {
                        setState(() {
                          draft.day = value;
                        });
                      },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _isSaving
                    ? null
                    : () => _pickTime(index: i, isStart: true),
                icon: const Icon(Icons.access_time),
                label: Text(
                  draft.start == null
                      ? "Select Start Time"
                      : "Start Time: ${_formatTimeOfDay(draft.start!)}",
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _isSaving
                    ? null
                    : () => _pickTime(index: i, isStart: false),
                icon: const Icon(Icons.access_time),
                label: Text(
                  draft.end == null
                      ? "Select End Time"
                      : "End Time: ${_formatTimeOfDay(draft.end!)}",
                ),
              ),
            ],
          ),
        ),
      );
    }

    return widgets;
  }

  // Check whether any office hour row currently has data
  bool get _hasAnyOfficeHourValue {
    return _officeHours.any((draft) => draft.hasAnyValue);
  }

  // Pick a start or end time for one office hour row
  Future<void> _pickTime({required int index, required bool isStart}) async {
    final draft = _officeHours[index];
    final initialTime = isStart
        ? (draft.start ?? const TimeOfDay(hour: 9, minute: 0))
        : (draft.end ?? const TimeOfDay(hour: 10, minute: 0));

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked == null || !mounted) return;

    setState(() {
      if (isStart) {
        draft.start = picked;
      } else {
        draft.end = picked;
      }
    });
  }

  // Format a picked time for display in the dialog
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  // Convert a picked time into database time format
  String _toDbTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  // Parse a database time string into a Flutter time value
  TimeOfDay? _parseTimeOfDay(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    final parts = trimmed.split(':');
    if (parts.length < 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;

    return TimeOfDay(hour: hour, minute: minute);
  }

  // Parse a saved office-hour string back into editable draft data
  _OfficeHourDraft? _parseOfficeHourDraft(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed == 'Not Available') return null;

    final parts = trimmed.split(' ');
    if (parts.length < 2) return null;

    final day = parts.first;
    final times = parts.sublist(1).join(' ').split('-');
    if (times.length != 2) return null;

    return _OfficeHourDraft(
      day: day,
      start: _parseTimeOfDay(times[0]),
      end: _parseTimeOfDay(times[1]),
    );
  }
}

// Weekday options used by the office-hour day dropdown
const List<String> _weekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

// Stores the editable day and time values for one office hour entry
class _OfficeHourDraft {
  String? day;
  TimeOfDay? start;
  TimeOfDay? end;

  _OfficeHourDraft({required this.day, required this.start, required this.end});

  // Create an empty office hour draft row
  factory _OfficeHourDraft.empty() {
    return _OfficeHourDraft(day: null, start: null, end: null);
  }

  // Check whether this office hour row contains any data
  bool get hasAnyValue => day != null || start != null || end != null;
}

// Dialog for adding, editing, or deleting a Canvas routing number
class _CanvasCourseIdDialog extends StatefulWidget {
  final String? initialValue;
  final Future<void> Function(String value) onSave;
  final Future<void> Function()? onProceedWithoutRoute;
  final Future<void> Function()? onDelete;
  final String Function(Object error) formatErrorMessage;

  const _CanvasCourseIdDialog({
    required this.initialValue,
    required this.onSave,
    required this.onProceedWithoutRoute,
    required this.onDelete,
    required this.formatErrorMessage,
  });

  @override
  State<_CanvasCourseIdDialog> createState() => _CanvasCourseIdDialogState();
}

class _CanvasCourseIdDialogState extends State<_CanvasCourseIdDialog> {
  late final TextEditingController _controller;
  bool _isSaving = false;
  bool _isDeleting = false;

  @override
  // Prefill the saved routing number when editing
  void initState() {
    super.initState();
    // Prefill the saved routing number when editing
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  // Dispose the text controller when the dialog closes
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  // Build the Canvas routing dialog
  Widget build(BuildContext context) {
    // Edit mode is enabled when a delete action is available
    final isEditing = widget.onDelete != null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text("Canvas Routing Number"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing
                  ? "Edit or delete your current Canvas course routing number."
                  : "Enter the Canvas course routing number for this enrolled course for course personalized routing.",
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              enabled: !_isSaving,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Canvas Course ID",
                hintText: "Example: 38674",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton(
                onPressed: (_isSaving || _isDeleting) ? null : _save,
                child: Text(_isSaving ? "Saving..." : "Save"),
              ),
              if (widget.onProceedWithoutRoute != null) ...[
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: (_isSaving || _isDeleting)
                      ? null
                      : _proceedWithoutRoute,
                  child: const Text("Open Canvas Without Course Code"),
                ),
              ],
              if (widget.onDelete != null) ...[
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: (_isSaving || _isDeleting) ? null : _delete,
                  child: Text(_isDeleting ? "Deleting..." : "Delete"),
                ),
              ],
              const SizedBox(height: 8),
              TextButton(
                onPressed: (_isSaving || _isDeleting)
                    ? null
                    : () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Save the entered Canvas routing number
  Future<void> _save() async {
    final value = _controller.text.trim();
    if (value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter the Canvas routing number.")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await widget.onSave(value);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(widget.formatErrorMessage(e))));
        setState(() => _isSaving = false);
      }
    }
  }

  // Delete the saved Canvas routing number
  Future<void> _delete() async {
    final onDelete = widget.onDelete;
    if (onDelete == null) return;

    setState(() => _isDeleting = true);

    try {
      await onDelete();
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(widget.formatErrorMessage(e))));
        setState(() => _isDeleting = false);
      }
    }
  }

  // Open the general Canvas page without a course-specific route
  Future<void> _proceedWithoutRoute() async {
    final proceed = widget.onProceedWithoutRoute;
    if (proceed == null) return;

    try {
      await proceed();
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(widget.formatErrorMessage(e))));
      }
    }
  }
}
