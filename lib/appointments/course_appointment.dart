import 'package:flutter/material.dart';
import 'package:ontario_tech_plus/appointments/week_selector.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../student.dart';

class CourseAppointmentPage extends StatefulWidget {
  final Student student;
  const CourseAppointmentPage({super.key, required this.student});

  @override
  State<CourseAppointmentPage> createState() => _CourseAppointmentPageState();
}

class _CourseAppointmentPageState extends State<CourseAppointmentPage> {
  bool _isLoading = true;

  List<Map<String, dynamic>> myCourses = [];
  List<Instructor> courseInstructors = [];

  int selectedCourseIndex = -1;
  int selectedInstructorIndex = -1;
  int selectedDateIndex = -1;

  late Student student1;

  @override
  void initState() {
    super.initState();
    student1 = widget.student;
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception("User is not logged in!");
      }

      final enrolledResponse = await supabase
          .from('student_enrolled_courses')
          .select('courses (*)')
          .eq('user_id', user.id);

      final fetchedCourses = enrolledResponse
          .map((e) => e['courses'] as Map<String, dynamic>)
          .toList();

      if (mounted) {
        setState(() {
          myCourses = fetchedCourses;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error initializing data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchInstructorsForCourse(
    int courseId,
    String courseCode,
  ) async {
    setState(() {
      _isLoading = true;
      selectedInstructorIndex = -1;
      selectedDateIndex = -1;
      courseInstructors = [];
    });

    try {
      final supabase = Supabase.instance.client;

      final response = await supabase
          .from('section_instructors')
          .select('''
            role,
            instructor (id, name, email, type, faculty, office),
            office_hours (id, day, start, end),
            course_sections!inner (course_id) 
          ''')
          .eq('course_sections.course_id', courseId);

      Map<int, Instructor> instructorMap = {};

      for (var row in response) {
        final instructorData = row['instructor'];
        if (instructorData == null) continue;
        final instructorId = int.parse(instructorData['id'].toString());
        final role = row['role'] ?? 'Instructor';
        final officeHoursData = row['office_hours'] as List<dynamic>? ?? [];

        List<Dates> parsedHours = [];
        for (var oh in officeHoursData) {
          if (oh['start'] == null || oh['end'] == null) continue;
          final startParts = oh['start'].toString().split(':');
          final endParts = oh['end'].toString().split(':');

          parsedHours.add(
            Dates(
              oh['day'] ?? "TBD",
              TimeOfDay(
                hour: int.parse(startParts[0]),
                minute: int.parse(startParts[1]),
              ),
              TimeOfDay(
                hour: int.parse(endParts[0]),
                minute: int.parse(endParts[1]),
              ),
              courseCode,
            ),
          );
        }

        if (instructorMap.containsKey(instructorId)) {
          instructorMap[instructorId]!.officehours.addAll(parsedHours);
        } else {
          instructorMap[instructorId] = Instructor(
            id: instructorId,
            name: instructorData['name'],
            email: instructorData['email'] ?? 'Unknown Email',
            type: instructorData['type'] ?? role.toString().toLowerCase(),
            faculty: instructorData['faculty'] ?? 'Unknown Faculty',
            office: instructorData['office'] ?? 'TBD',
            officehours: parsedHours,
          );
        }
      }

      if (mounted) {
        setState(() {
          courseInstructors = instructorMap.values.toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching instructors: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading && myCourses.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Course Office Hours")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Course Office Hours")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: const Text(
                  "Select a Course:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(16),
                itemCount: myCourses.length,
                itemBuilder: (context, index) {
                  final course = myCourses[index];
                  final isSelected = selectedCourseIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCourseIndex = index;
                      });
                      _fetchInstructorsForCourse(
                        course['id'],
                        course['course_code'],
                      );
                    },
                    child: Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: 12),
                      child: Card(
                        color: isSelected ? colorScheme.primary : Colors.white,
                        child: Center(
                          child: Text(
                            course['course_code'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected
                                  ? colorScheme.onPrimary
                                  : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            if (_isLoading && selectedCourseIndex != -1)
              const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),

            if (!_isLoading && selectedCourseIndex != -1) ...[
              const Divider(),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text(
                    "Select a Prof / TA:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              if (courseInstructors.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("No instructors or TAs found for this course."),
                ),

              if (courseInstructors.isNotEmpty)
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(16),
                    itemCount: courseInstructors.length,
                    itemBuilder: (context, index) {
                      final instructor = courseInstructors[index];
                      final isSelected = selectedInstructorIndex == index;

                      return GestureDetector(
                        onTap: () => setState(() {
                          selectedInstructorIndex = isSelected ? -1 : index;
                          selectedDateIndex = -1;
                        }),
                        child: Container(
                          width: 160,
                          margin: const EdgeInsets.only(right: 12),
                          child: Card(
                            color: isSelected
                                ? colorScheme.secondary
                                : Colors.white,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  instructor.name,
                                  style: TextStyle(
                                    color: isSelected
                                        ? colorScheme.onSecondary
                                        : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  instructor.type.toUpperCase(),
                                  style: TextStyle(
                                    color: isSelected
                                        ? colorScheme.onSecondary
                                        : Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],

            if (selectedInstructorIndex != -1) ...[
              const Divider(),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text(
                    "Select a Time:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              if (courseInstructors[selectedInstructorIndex]
                  .officehours
                  .isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("No office hours scheduled."),
                ),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: courseInstructors[selectedInstructorIndex]
                    .officehours
                    .length,
                itemBuilder: (context, index) {
                  final time = courseInstructors[selectedInstructorIndex]
                      .officehours[index];
                  final isSelected = selectedDateIndex == index;

                  return GestureDetector(
                    onTap: () => setState(
                      () => selectedDateIndex = isSelected ? -1 : index,
                    ),
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      color: isSelected
                          ? colorScheme.primaryContainer
                          : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          time.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              if (selectedDateIndex != -1)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WeekSelection(
                            instructor:
                                courseInstructors[selectedInstructorIndex],
                            student: student1,
                            date: courseInstructors[selectedInstructorIndex]
                                .officehours[selectedDateIndex],
                          ),
                        ),
                      );
                    },
                    child: const Text("Next"),
                  ),
                ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
