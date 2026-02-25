import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ontario_tech_plus/appointments/weekSelector.dart';
import '../student.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});
  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  bool _isLoading = true;
  List<Instructor> scienceAdvisors = [];
  List<Instructor> uniqueProfessors = [];
  late List<Instructor> fullList;
  int selectedIndex = -1;
  int selectedDate = -1;

  // Keeping student data for UI logic, but with empty courses
  late Student student1 = Student(
    name: "Arad Ayntabli",
    studentid: 100845722,
    program: "Computer Science",
    faculty: "science",
    year: 4,
    courses: [],
  );

  @override
  void initState() {
    super.initState();
    _fetchInstructorData();
  }

  Future<void> _fetchInstructorData() async {
    try {
      final supabase = Supabase.instance.client;
      final instructorResponse = await supabase.from('instructor').select();

      final officeHoursResponse = await supabase.from('office_hours').select('''
        id, start, end, day,
        course_instructors!inner (
          instructor_id
        )
      ''');

      final Map<int, List<Dates>> officeHoursByProfId = {};

      for (var oh in officeHoursResponse) {
        final profId = int.parse(
          oh['course_instructors']['instructor_id'].toString(),
        );

        if (oh['start'] == null || oh['end'] == null) continue;

        final timePartsStart = (oh['start'] as String).split(':');
        final timePartsEnd = (oh['end'] as String).split(':');

        final officeHour = Dates(
          oh['day'],
          TimeOfDay(
            hour: int.parse(timePartsStart[0]),
            minute: int.parse(timePartsStart[1]),
          ),
          TimeOfDay(
            hour: int.parse(timePartsEnd[0]),
            minute: int.parse(timePartsEnd[1]),
          ),
        );

        officeHoursByProfId.putIfAbsent(profId, () => []).add(officeHour);
      }

      final List<Instructor> fetchedScienceAdvisors = [];
      final List<Instructor> fetchedUniqueProfessors = [];

      for (var data in instructorResponse) {
        final id = int.parse(data['id'].toString());
        final type = (data['type'] ?? '').toString().toLowerCase();
        final faculty = (data['faculty'] ?? '').toString().toLowerCase();
        final office = (data['office'] ?? '').toString();

        final instructor = Instructor(
          id: id,
          name: data['name'] ?? 'Unknown',
          email: data['email'] ?? '',
          type: type,
          faculty: faculty,
          office: office,
          officehours: officeHoursByProfId[id] ?? [],
        );

        if (type == 'advisor' && faculty == 'science') {
          fetchedScienceAdvisors.add(instructor);
        } else if (type == 'professor') {
          fetchedUniqueProfessors.add(instructor);
        }
      }

      if (mounted) {
        setState(() {
          scienceAdvisors = fetchedScienceAdvisors;
          uniqueProfessors = fetchedUniqueProfessors;
          _isLoading = false;
        });
      }
    } catch (e, stacktrace) {
      print('CRITICAL ERROR: $e');
      print('STACKTRACE: $stacktrace');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget buildlistview(ColorScheme colorScheme, List<Instructor> instructors) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: instructors.length,
        itemBuilder: (context, index) {
          final instructor = instructors[index];
          final isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  selectedIndex = -1;
                } else {
                  selectedIndex = index;
                }
                selectedDate = -1;
              });
              print("Selected: ${instructor.name}");
            },
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(right: 12),
              child: Card(
                color: isSelected ? colorScheme.primary : Colors.white,
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
                        instructor.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected
                              ? colorScheme.onPrimary
                              : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        instructor.office,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? colorScheme.onPrimary
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("Schedule an Appointment")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (student1.faculty == "science") {
      fullList = [...scienceAdvisors, ...uniqueProfessors];
    } else {
      fullList = uniqueProfessors;
    }
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text("Schedule an Appointment")),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 10),
            Card(
              color: colorScheme.primary,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Select an Instructor:",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            SizedBox(height: 10),
            if (fullList.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('No instructors available.'),
              )
            else
              buildlistview(colorScheme, fullList),
            SizedBox(height: 10),
            if (selectedIndex != -1) ...[
              Card(
                color: colorScheme.primary,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Select a Time",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: fullList[selectedIndex].officehours.isEmpty
                    ? Center(
                        child: Text(
                          'No office hours available for this instructor.',
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: fullList[selectedIndex].officehours.length,
                        itemBuilder: (context, index) {
                          final time =
                              fullList[selectedIndex].officehours[index];
                          final isSelected = selectedDate == index;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  selectedDate = -1;
                                } else {
                                  selectedDate = index;
                                }
                              });
                              print("Selected: ${time.toString()}");
                            },
                            child: Center(
                              child: Container(
                                width: 300,
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                child: Card(
                                  color: isSelected
                                      ? colorScheme.secondary
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          time.toString(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: isSelected
                                                ? colorScheme.onPrimary
                                                : Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
            if (selectedDate != -1) ...[
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: (() => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WeekSelection(
                      instructor: fullList[selectedIndex],
                      student: student1,
                      date: fullList[selectedIndex].officehours[selectedDate],
                    ),
                  ),
                )),
                child: Text("Next"),
              ),
            ],
            SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
