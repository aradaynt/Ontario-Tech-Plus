import 'package:flutter/material.dart';

import '../profile/profile_model.dart';
import '../student.dart';
import 'time_selector.dart';

class WeekSelection extends StatefulWidget {
  final Instructor? instructor;
  final Advisor? advisor;
  final Profile profile;
  final Dates date;
  const WeekSelection({
    super.key,
    this.instructor,
    this.advisor,
    required this.profile,
    required this.date,
  });
  @override
  State<WeekSelection> createState() => _WeekSelectionState();
}

class _WeekSelectionState extends State<WeekSelection> {
  final year = DateTime.now().year;

  List<DateTime> getFutureWeekMondays(String dayOfWeek) {
    final DateTime today = DateTime.now();
    DateTime semesterStart;
    if (today.month >= 1 && today.month <= 5) {
      semesterStart = DateTime(today.year, 1, 5);
    } else {
      semesterStart = DateTime(today.year, 9, 7);
    }

    Map<String, int> dayMap = {
      'Monday': 1,
      'Tuesday': 2,
      'Wednesday': 3,
      'Thursday': 4,
      'Friday': 5,
      'Saturday': 6,
      'Sunday': 7,
    };

    int targetDay = dayMap[dayOfWeek] ?? 1;

    int initialOffset = (targetDay - semesterStart.weekday + 7) % 7;
    DateTime firstOccurrence = semesterStart.add(Duration(days: initialOffset));

    List<DateTime> futureDates = [];

    for (int i = 0; i < 18; i++) {
      DateTime currentWeekDate = firstOccurrence.add(Duration(days: i * 7));

      DateTime todayMidnight = DateTime(today.year, today.month, today.day);
      if (currentWeekDate.isAfter(todayMidnight) ||
          currentWeekDate.isAtSameMomentAs(todayMidnight)) {
        futureDates.add(currentWeekDate);
      }
    }
    return futureDates;
  }

  late final List<DateTime> weeks;
  List<String> months = [
    '',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  int selectedWeek = -1;
  String selectedWeekString = '';
  @override
  void initState() {
    super.initState();
    weeks = getFutureWeekMondays(widget.date.day);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text("Select a Week")),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsetsGeometry.all(8),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: weeks.length,
                  itemBuilder: (context, index) {
                    final weekDate = weeks[index];
                    final isReadingWeek = index == 6;
                    final isSelected = selectedWeek == index;
                    String weekString =
                        "${months[weekDate.month]}, ${weekDate.day}";

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedWeek = -1;
                            selectedWeekString = '';
                          } else {
                            selectedWeek = index;
                            selectedWeekString =
                                "${months[weekDate.month]}, ${weekDate.day}";
                          }
                        });
                      },
                      child: SizedBox(
                        width: 160,
                        height: 75,
                        child: Card(
                          color: isSelected
                              ? colorScheme.primary
                              : Colors.white,
                          elevation: isSelected ? 4 : 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected
                                  ? colorScheme.primary
                                  : Colors.transparent,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isReadingWeek ? "Reading Week" : weekString,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isSelected
                                        ? colorScheme.onPrimary
                                        : Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                const SizedBox(height: 4),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Stack(
              children: [
                SizedBox(height: 50),
                if (selectedWeek != -1)
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SpecificTime(
                              instructor: widget.instructor,
                              advisor: widget.advisor,
                              profile: widget.profile,
                              date: widget.date,
                              weekLabel:
                                  "$selectedWeekString, ${year.toString()}",
                            ),
                          ),
                        );
                      },
                      child: Text("Next"),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
