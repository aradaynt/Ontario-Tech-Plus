import 'package:flutter/material.dart';

import '../student.dart';
import 'emailPage.dart';

class SpecificTime extends StatefulWidget {
  final Instructor instructor;
  final Student student;
  final Dates date;
  final String? weekLabel;
  const SpecificTime({
    super.key,
    required this.instructor,
    required this.student,
    required this.date,
    this.weekLabel,
  });
  @override
  State<SpecificTime> createState() => _SpecificTimeState();
}

class _SpecificTimeState extends State<SpecificTime> {
  List<Dates> timeslots = [];
  List<Dates> generateTimeslots() {
    late int startMinutes =
        widget.date.start.hour * 60 + widget.date.start.minute;
    late int endMinutes = widget.date.end.hour * 60 + widget.date.end.minute;
    late int currentMinutes = startMinutes;
    while (currentMinutes + 10 <= endMinutes) {
      int nextMinutes = currentMinutes + 10;
      TimeOfDay slotStart = TimeOfDay(
        hour: currentMinutes ~/ 60,
        minute: currentMinutes % 60,
      );
      TimeOfDay slotEnd = TimeOfDay(
        hour: nextMinutes ~/ 60,
        minute: nextMinutes % 60,
      );

      timeslots.add(Dates(widget.date.day, slotStart, slotEnd));

      currentMinutes = nextMinutes;
    }
    return timeslots;
  }

  int selectedTime = -1;

  //TODO Make it so users cant book already booked dates via supabase
  //TODO Learn how to use Supabase

  List<Dates> booked = [];

  @override
  void initState() {
    super.initState();
    generateTimeslots();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text("Select a Time Slot")),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsetsGeometry.only(top: 8, right: 8),
                child: Scrollbar(
                  thumbVisibility: true,
                  thickness: 12,
                  radius: const Radius.circular(10),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 8,
                      bottom: 50,
                    ),
                    itemCount: timeslots.length,
                    itemBuilder: (context, index) {
                      final time = timeslots[index];
                      final isSelected = selectedTime == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (!booked.contains(time)) {
                              if (isSelected) {
                                selectedTime = -1;
                              } else {
                                selectedTime = index;
                              }
                            }
                          });
                        },
                        child: Container(
                          width: 160,
                          margin: const EdgeInsets.only(right: 12),
                          child: Card(
                            color: isSelected
                                ? colorScheme.primary
                                : booked.contains(time)
                                ? Colors.grey
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
                                    "${widget.weekLabel!}: $time",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: isSelected
                                          ? colorScheme.onPrimary
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      decoration: booked.contains(time)
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                      decorationThickness: 3.0,
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
            ),
            Stack(
              children: [
                SizedBox(height: 50),
                if (selectedTime != -1)
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          booked.add(timeslots[selectedTime]);
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EmailPage(
                              instructor: widget.instructor,
                              student: widget.student,
                              date: timeslots[selectedTime],
                              week: widget.weekLabel,
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
