import "package:flutter/material.dart";
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../student.dart';

class appointments {
  final dynamic id;
  final String tableName;
  final String date;
  final String start;
  final String end;
  final String who;

  appointments({
    required this.id,
    required this.tableName,
    required this.date,
    required this.start,
    required this.end,
    required this.who,
  });
  @override
  String toString() {
    DateFormat inputFormat = DateFormat("HH:mm:ss");
    DateFormat outputFormat = DateFormat("h:mm a");
    String formatTime(String timeString) {
      try {
        DateTime dateTime = inputFormat.parse(timeString);
        return outputFormat.format(dateTime);
      } catch (e) {
        return timeString;
      }
    }

    return '$date: \n${formatTime(start)} - ${formatTime(end)} \nwith $who';
  }
}

class MyAppointmentsPage extends StatefulWidget {
  final Student student;
  const MyAppointmentsPage({super.key, required this.student});

  @override
  State<MyAppointmentsPage> createState() => _MyAppointmentsPageState();
}

class _MyAppointmentsPageState extends State<MyAppointmentsPage> {
  bool _isLoading = true;
  List<appointments> myAdvisorAppointments = [];
  List<appointments> myCourseAppointments = [];
  late Student student1 = widget.student;

  Future<void> fetchAdvisorAppointments() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('advisor_booked')
          .select('id,date, start, end, advisors(name)')
          .eq('student_id', student1.studentid);

      final List<appointments> fetched = (response as List).map((row) {
        return appointments(
          id: row['id'],
          tableName: 'advisor_booked',
          date: row['date'],
          start: row['start'],
          end: row['end'],
          who: row['advisors']['name'],
        );
      }).toList();

      if (mounted) {
        setState(() {
          myAdvisorAppointments = fetched;
        });
      }
    } catch (e) {
      print('Advisor Fetch Error: $e');
    }
  }

  Future<void> fetchCourseAppointments() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('booked')
          .select('''
          id,
          date, 
          start, 
          end, 
          office_hours (
            section_instructors (
              instructor (
                name
              )
            )
          )
        ''')
          .eq('student_id', student1.studentid);

      final List<appointments> fetched = (response as List).map((row) {
        final instructorName =
            row['office_hours']['section_instructors']['instructor']['name'];

        return appointments(
          id: row['id'],
          tableName: 'booked',
          date: row['date'],
          start: row['start'],
          end: row['end'],
          who: instructorName ?? "Unknown Instructor",
        );
      }).toList();

      if (mounted) {
        setState(() {
          myCourseAppointments = fetched;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Course Fetch Error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAdvisorAppointments();
    fetchCourseAppointments();
  }

  @override
  Widget build(BuildContext context) {
    final allAppointments = [...myAdvisorAppointments, ...myCourseAppointments];
    final colorScheme = Theme.of(context).colorScheme;
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("Select a Time Slot")),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text("My Appointments")),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 175,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Swipe to Cancel",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.arrow_back),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, right: 8),
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
                    itemCount: allAppointments.length,
                    itemBuilder: (context, index) {
                      final appointment = allAppointments[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Dismissible(
                          key: UniqueKey(),
                          direction: DismissDirection.endToStart,
                          resizeDuration: null,
                          background: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            return await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Confirm"),
                                  content: const Text(
                                    "Are you sure you want to cancel this appointment?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text("DELETE"),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text("CANCEL"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          onDismissed: (direction) async {
                            setState(() {
                              if (appointment.tableName == 'advisor_booked') {
                                myAdvisorAppointments.removeAt(index);
                              } else {
                                myCourseAppointments.removeAt(index);
                              }
                            });

                            try {
                              await Supabase.instance.client
                                  .from(appointment.tableName)
                                  .delete()
                                  .eq('id', appointment.id);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Appointment with ${appointment.who} cancelled",
                                  ),
                                ),
                              );
                            } catch (e) {
                              print("Delete failed: $e");
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Failed to cancel appointment. Please try again.",
                                  ),
                                ),
                              );
                            }
                          },
                          child: SizedBox(
                            width: double.infinity,
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  appointment.toString(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
          ],
        ),
      ),
    );
  }
}
