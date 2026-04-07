import 'package:home_widget/home_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:ontario_tech_plus/schedule/courses/models/enrolled_courses_model.dart';
import 'package:ontario_tech_plus/schedule/courses/models/course_section_model.dart';

class WidgetManager {
  static final supabase = Supabase.instance.client;

  static Future<void> updateNextClassWidget() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final rows = await supabase
          .from('v_my_course_sections')
          .select('''
            course_code, course_name, 
            day, start_time, end_time, building_shortname, room_code
          ''')
          .eq('user_id', userId);

      if (rows.isEmpty) {
        await _updateWidget("No Classes", "Enjoy your day!");
        return;
      }

      final now = DateTime.now();
      final currentDay = DateFormat('EEEE').format(now);

      Map<String, dynamic>? nextClass;
      DateTime? nextClassDateTime;

      for (final row in rows) {
        final day = row['day'] as String?;
        final startTimeStr = row['start_time'] as String?;
        if (day == null || startTimeStr == null) continue;

        final classTime = _getNextOccurrence(day, startTimeStr);

        if (nextClassDateTime == null ||
            classTime.isBefore(nextClassDateTime)) {
          nextClassDateTime = classTime;
          nextClass = row;
        }
      }

      if (nextClass != null && nextClassDateTime != null) {
        final courseCode = nextClass['course_code'] ?? 'Unknown';
        final building = nextClass['building_shortname'] ?? '';
        final room = nextClass['room_code'] ?? '';
        final startTimeStr = nextClass['start_time'] as String;

        final timeDisplay = _formatTime(startTimeStr);
        final dayDisplay = _isToday(nextClassDateTime)
            ? "Today"
            : nextClass['day'];

        await _updateWidget(
          "Next: $courseCode",
          "$building $room at $timeDisplay ($dayDisplay)",
        );
      }
    } catch (e) {
      print('Error updating widget: $e');
    }
  }

  static Future<void> _updateWidget(String title, String description) async {
    await HomeWidget.saveWidgetData<String>('title', title);
    await HomeWidget.saveWidgetData<String>('description', description);
    await HomeWidget.updateWidget(name: 'AppWidget', androidName: 'AppWidget');
  }

  static DateTime _getNextOccurrence(String day, String startTimeStr) {
    final now = DateTime.now();
    final parts = startTimeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final daysOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    int targetDayIndex = daysOfWeek.indexOf(day) + 1; // 1 = Monday
    int currentDayIndex = now.weekday;

    int daysUntil = (targetDayIndex - currentDayIndex) % 7;
    if (daysUntil == 0) {
      final todayClassTime = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );
      if (todayClassTime.isBefore(now)) {
        daysUntil = 7;
      }
    }
    if (daysUntil < 0) daysUntil += 7;

    final nextDate = now.add(Duration(days: daysUntil));
    return DateTime(nextDate.year, nextDate.month, nextDate.day, hour, minute);
  }

  static String _formatTime(String timeStr) {
    try {
      final tod = TimeOfDay(
        hour: int.parse(timeStr.split(':')[0]),
        minute: int.parse(timeStr.split(':')[1]),
      );
      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
      return DateFormat.jm().format(dt);
    } catch (e) {
      return timeStr;
    }
  }

  static bool _isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }
}

class TimeOfDay {
  final int hour;
  final int minute;
  TimeOfDay({required this.hour, required this.minute});
}
