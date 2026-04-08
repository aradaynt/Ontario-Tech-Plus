import "package:flutter/material.dart";
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../profile/profile_model.dart';

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
  final Profile profile;
  const MyAppointmentsPage({super.key, required this.profile});

  @override
  State<MyAppointmentsPage> createState() => _MyAppointmentsPageState();
}

class _MyAppointmentsPageState extends State<MyAppointmentsPage> {
  bool _isLoading = true;
  List<appointments> myAdvisorAppointments = [];
  List<appointments> myCourseAppointments = [];
  late Profile profile = widget.profile;
  Set<appointments> selectedAppointments = {};

  @override
  void initState() {
    super.initState();
    fetchAdvisorAppointments();
    fetchCourseAppointments();
  }

  Future<void> fetchAdvisorAppointments() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('advisor_booked')
          .select('id,date, start, end, advisors(name)')
          .eq('student_id', int.parse(profile.studentNumber));

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
          instructor:prof_id (
            name
          )
        ''')
          .eq('student_id', int.parse(profile.studentNumber));

      final List<appointments> fetched = (response as List).map((row) {
        final instructorData = row['instructor'];
        final instructorName = instructorData != null
            ? instructorData['name']
            : null;

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

  Future<void> _deleteSelected() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Multiple"),
        content: Text(
          "Are you sure you want to cancel ${selectedAppointments.length} appointments?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("DELETE", style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("CANCEL"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final toDelete = selectedAppointments.toList();

    setState(() {
      myAdvisorAppointments.removeWhere((a) => toDelete.contains(a));
      myCourseAppointments.removeWhere((a) => toDelete.contains(a));
      selectedAppointments.clear();
    });

    try {
      for (var appt in toDelete) {
        await Supabase.instance.client
            .from(appt.tableName)
            .delete()
            .eq('id', appt.id);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Appointments cancelled successfully.")),
        );
      }
    } catch (e) {
      print("Batch delete failed: $e");
      fetchAdvisorAppointments();
      fetchCourseAppointments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to cancel some appointments.")),
        );
      }
    }
  }

  void _toggleSelection(appointments appt) {
    setState(() {
      if (selectedAppointments.contains(appt)) {
        selectedAppointments.remove(appt);
      } else {
        selectedAppointments.add(appt);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final allAppointments = [...myAdvisorAppointments, ...myCourseAppointments];
    final colorScheme = Theme.of(context).colorScheme;
    final isMultiSelectMode = selectedAppointments.isNotEmpty;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("My Appointments")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: isMultiSelectMode
          ? AppBar(
              backgroundColor: colorScheme.primaryContainer,
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => selectedAppointments.clear()),
              ),
              title: Text("${selectedAppointments.length} Selected"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: _deleteSelected,
                ),
              ],
            )
          : AppBar(title: const Text("My Appointments")),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            if (!isMultiSelectMode)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 175,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
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
                      final isSelected = selectedAppointments.contains(
                        appointment,
                      );

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Dismissible(
                          key: Key(
                            '${appointment.tableName}_${appointment.id}',
                          ),
                          direction: isMultiSelectMode
                              ? DismissDirection.none
                              : DismissDirection.endToStart,
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
                                myAdvisorAppointments.remove(appointment);
                              } else {
                                myCourseAppointments.remove(appointment);
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
                          child: GestureDetector(
                            onLongPress: () {
                              if (!isMultiSelectMode)
                                _toggleSelection(appointment);
                            },
                            onTap: () {
                              if (isMultiSelectMode)
                                _toggleSelection(appointment);
                            },
                            child: SizedBox(
                              width: double.infinity,
                              child: Card(
                                color: isSelected
                                    ? colorScheme.secondaryContainer
                                    : null,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: isSelected
                                      ? BorderSide(
                                          color: colorScheme.primary,
                                          width: 2,
                                        )
                                      : BorderSide.none,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          appointment.toString(),
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (isMultiSelectMode)
                                        Icon(
                                          isSelected
                                              ? Icons.check_circle
                                              : Icons.radio_button_unchecked,
                                          color: isSelected
                                              ? colorScheme.primary
                                              : Colors.grey,
                                        ),
                                    ],
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
