// OntarioTechPlus - view_my_schedule_page.dart
//
// Displays a calendar that shows the users enrolled course meetings
// (Lectures, Labs, Tutorials) using Syncfusion Calendar.
// obtained from myEnrolledCoursesProvider in course providr.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'package:ontario_tech_plus/schedule/courses/providers/courses_provider.dart';
import 'package:ontario_tech_plus/schedule/courses/models/enrolled_courses_model.dart';

class ViewMySchedulePage extends ConsumerWidget {
  const ViewMySchedulePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enrolledAsync = ref.watch(myEnrolledCoursesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("View My Schedule")),
      body: enrolledAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Failed to load schedule: $e")),
        data: (courses) {
          final appointments = _buildAppointments(courses);

          if (appointments.isEmpty) {
            return const Center(
              child: Text(
                "Enroll in courses to see schedule",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            );
          }

          return SfCalendar(
            view: CalendarView.week,
            firstDayOfWeek: 1, // Monday
            timeSlotViewSettings: const TimeSlotViewSettings(
              startHour: 8,
              endHour: 22,
              timeIntervalHeight: 60,
            ),
            dataSource: _ScheduleDataSource(appointments),
            appointmentTextStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            monthViewSettings: const MonthViewSettings(
              appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
            ),
            // Optional: tap appointment to show details
            onTap: (details) {
              final appt = details.appointments?.isNotEmpty == true
                  ? details.appointments!.first as Appointment
                  : null;

              if (appt == null) return;

              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(appt.subject),
                  content: Text(
                    [
                      "Time: ${_hhmm(appt.startTime)}–${_hhmm(appt.endTime)}",
                      if ((appt.location ?? '').isNotEmpty)
                        "Location: ${appt.location}",
                      if ((appt.notes ?? '').isNotEmpty) appt.notes!,
                    ].join("\n"),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close"),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Convert enrolled courses  to list of appointments for cal
  List<Appointment> _buildAppointments(List<EnrolledCourse> courses) {
    final out = <Appointment>[];

    for (final course in courses) {
      for (final section in course.sections) {
        // Each meeting becomes its own recurring appointment
        for (final meeting in section.meetings) {
          // If meeting is missing essentials, skip
          if (meeting.day.trim().isEmpty ||
              meeting.startTime.trim().isEmpty ||
              meeting.endTime.trim().isEmpty) {
            continue;
          }

          final weekday = _weekdayFromName(meeting.day);
          if (weekday == null) continue;

          final startTod = _parseTimeOfDay(meeting.startTime);
          final endTod = _parseTimeOfDay(meeting.endTime);
          if (startTod == null || endTod == null) continue;

          // Find the first date on/after section.startDate that matches meeting weekday
          final firstDate = _firstOccurrenceOnOrAfter(
            section.startDate,
            weekday,
          );

          final start = DateTime(
            firstDate.year,
            firstDate.month,
            firstDate.day,
            startTod.hour,
            startTod.minute,
          );

          final end = DateTime(
            firstDate.year,
            firstDate.month,
            firstDate.day,
            endTod.hour,
            endTod.minute,
          );

          // Build recurrence rule: weekly on given weekday, until section.endDate
          final byDay = _rruleDayToken(weekday); // MO/TU/WE/TH/FR/SA/SU
          if (byDay == null) continue;

          // UNTIL must be in UTC Z format for RRULE strings
          final untilUtc = DateTime(
            section.endDate.year,
            section.endDate.month,
            section.endDate.day,
            23,
            59,
            59,
          ).toUtc();

          final until =
              "${untilUtc.year.toString().padLeft(4, '0')}"
              "${untilUtc.month.toString().padLeft(2, '0')}"
              "${untilUtc.day.toString().padLeft(2, '0')}"
              "T"
              "${untilUtc.hour.toString().padLeft(2, '0')}"
              "${untilUtc.minute.toString().padLeft(2, '0')}"
              "${untilUtc.second.toString().padLeft(2, '0')}"
              "Z";

          final rrule = "FREQ=WEEKLY;INTERVAL=1;BYDAY=$byDay;UNTIL=$until";

          // Label text inside the calendar block
          final subject = "${course.courseCode} • ${section.scheduleType}";

          // Location like "SCI2230" or "TBA"
          final location = meeting.displayLocation == "TBA"
              ? ""
              : meeting.displayLocation;

          // Notes shown in dialog
          final notes = [
            course.courseName,
            "Section ${section.section} • CRN ${section.crn}",
            "Instructor: ${section.displayinstructor}",
          ].join("\n");

          out.add(
            Appointment(
              startTime: start,
              endTime: end,
              subject: subject,
              location: location,
              notes: notes,
              recurrenceRule: rrule,
            ),
          );
        }
      }
    }

    return out;
  }

  // --- Helpers ---

  // 14:10:00 or 14:10 = TimeOfDay(14,10)
  TimeOfDay? _parseTimeOfDay(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;

    final parts = s.split(':');
    if (parts.length < 2) return null;

    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;

    return TimeOfDay(hour: h, minute: m);
  }

  // Map "Monday" = DateTime.monday, etc.
  int? _weekdayFromName(String day) {
    switch (day.trim()) {
      case 'Monday':
        return DateTime.monday;
      case 'Tuesday':
        return DateTime.tuesday;
      case 'Wednesday':
        return DateTime.wednesday;
      case 'Thursday':
        return DateTime.thursday;
      case 'Friday':
        return DateTime.friday;
      case 'Saturday':
        return DateTime.saturday;
      case 'Sunday':
        return DateTime.sunday;
      default:
        return null;
    }
  }

  // Find first date >= startDate that matches weekday
  DateTime _firstOccurrenceOnOrAfter(DateTime startDate, int weekday) {
    final d = DateTime(startDate.year, startDate.month, startDate.day);
    final diff = (weekday - d.weekday) % 7;
    return d.add(Duration(days: diff));
  }

  // DateTime weekday = RRULE token
  String? _rruleDayToken(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return "MO";
      case DateTime.tuesday:
        return "TU";
      case DateTime.wednesday:
        return "WE";
      case DateTime.thursday:
        return "TH";
      case DateTime.friday:
        return "FR";
      case DateTime.saturday:
        return "SA";
      case DateTime.sunday:
        return "SU";
      default:
        return null;
    }
  }

  String _hhmm(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }
}

// Syncfusion data source wrapper
class _ScheduleDataSource extends CalendarDataSource {
  _ScheduleDataSource(List<Appointment> source) {
    appointments = source;
  }
}
