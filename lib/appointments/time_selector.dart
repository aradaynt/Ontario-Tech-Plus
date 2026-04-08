import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../profile/profile_model.dart';
import '../student.dart';
import 'email_page.dart';

class SpecificTime extends StatefulWidget {
  final Instructor? instructor;
  final Advisor? advisor;
  final Profile profile;
  final Dates date;
  final String? weekLabel; // Month, Day, Year. Like America

  const SpecificTime({
    super.key,
    this.instructor,
    this.advisor,
    required this.profile,
    required this.date,
    this.weekLabel,
  });

  @override
  State<SpecificTime> createState() => _SpecificTimeState();
}

class _SpecificTimeState extends State<SpecificTime> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  List<Dates> timeslots = [];
  int selectedTime = -1;
  Set<String> bookedStartTimes = {};

  @override
  void initState() {
    super.initState();
    generateTimeslots();
    _fetchBookedDates();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void generateTimeslots() {
    int startMinutes = widget.date.start.hour * 60 + widget.date.start.minute;
    int endMinutes = widget.date.end.hour * 60 + widget.date.end.minute;
    int currentMinutes = startMinutes;

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

      timeslots.add(
        Dates(widget.date.day, slotStart, slotEnd, widget.date.courseCode),
      );
      currentMinutes = nextMinutes;
    }
  }

  String _formatDateForSupabase(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';

    try {
      final cleanStr = dateStr.replaceAll(',', '');
      final parts = cleanStr.split(' ');

      if (parts.length < 3) return dateStr;

      const months = {
        'January': '01',
        'February': '02',
        'March': '03',
        'April': '04',
        'May': '05',
        'June': '06',
        'July': '07',
        'August': '08',
        'September': '09',
        'October': '10',
        'November': '11',
        'December': '12',
      };

      final month = months[parts[0]] ?? '01';
      final day = parts[1].padLeft(2, '0');
      final year = parts[2];

      return '$year-$month-$day';
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> _fetchBookedDates() async {
    if (widget.weekLabel == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final supabase = Supabase.instance.client;

      final isAdvisor = widget.advisor != null;
      final targetTable = isAdvisor ? 'advisor_booked' : 'booked';
      final targetColumn = isAdvisor ? 'advisor_id' : 'prof_id';
      final targetId = isAdvisor ? widget.advisor!.id : widget.instructor!.id;

      final formattedDate = _formatDateForSupabase(widget.weekLabel);

      final response = await supabase
          .from(targetTable)
          .select('start')
          .eq(targetColumn, targetId)
          .eq('date', formattedDate);

      final Set<String> fetchedBookedTimes = {};

      for (var booking in response) {
        if (booking['start'] != null) {
          final startString = booking['start'].toString().substring(0, 5);
          fetchedBookedTimes.add(startString);
        }
      }

      if (mounted) {
        setState(() {
          bookedStartTimes = fetchedBookedTimes;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching booked dates: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("Select a Time Slot")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Select a Time Slot")),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, right: 8),
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  thickness: 12,
                  radius: const Radius.circular(10),
                  child: ListView.builder(
                    primary: false,
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 8,
                      bottom: 50,
                    ),
                    itemCount: timeslots.length,
                    itemBuilder: (context, index) {
                      final time = timeslots[index];
                      final isSelected = selectedTime == index;

                      final formattedStart =
                          '${time.start.hour.toString().padLeft(2, '0')}:${time.start.minute.toString().padLeft(2, '0')}';

                      final isBooked = bookedStartTimes.contains(
                        formattedStart,
                      );

                      return GestureDetector(
                        onTap: isBooked
                            ? null
                            : () {
                                setState(() {
                                  if (isSelected) {
                                    selectedTime = -1;
                                  } else {
                                    selectedTime = index;
                                  }
                                });
                              },
                        child: Container(
                          width: 160,
                          margin: const EdgeInsets.only(right: 12),
                          child: Card(
                            color: isBooked
                                ? Colors.grey[300]
                                : (isSelected
                                      ? colorScheme.primary
                                      : Colors.white),
                            elevation: isBooked ? 0 : (isSelected ? 4 : 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected && !isBooked
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
                                    "${widget.weekLabel ?? ''}: \n$time",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: isBooked
                                          ? Colors.grey[600]
                                          : (isSelected
                                                ? colorScheme.onPrimary
                                                : Colors.black),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      decoration: isBooked
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
                const SizedBox(height: 50),
                if (selectedTime != -1)
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EmailPage(
                              instructor: widget.instructor,
                              advisor: widget.advisor,
                              profile: widget.profile,
                              date: timeslots[selectedTime],
                              week: widget.weekLabel,
                            ),
                          ),
                        );
                      },
                      child: const Text("Next"),
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
