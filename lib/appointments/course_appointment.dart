import 'package:flutter/material.dart';
import 'package:ontario_tech_plus/appointments/week_selector.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../student.dart';

class CourseAppointmentPage extends StatefulWidget {
  const CourseAppointmentPage({super.key});

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

  // Placeholder student
  late Student student1 = Student(
    name: "Arad Ayntabli",
    studentid: 100845722,
    email: "arad.ayntabli@ontariotechu.net",
    program: "Computer Science",
    faculty: "science",
    year: 4,
    courses: [],
  );

  @override
  void initState() {
    super.initState();
    _fetchMyCourses();
  }

  Future<void> _fetchMyCourses() async {
    try {
      final supabase = Supabase.instance.client;
      // For now, grabbing all courses. Once Auth is hooked up,
      // will join this with student_enrolled_courses where student_id = logged-in UUID.
      final coursesResponse = await supabase.from('courses').select();

      if (mounted) {
        setState(() {
          myCourses = List<Map<String, dynamic>>.from(coursesResponse);
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching courses: $e");
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
          .from('course_instructors')
          .select('''
        role,
        instructor (id, name, email, type, faculty, office),
        office_hours (id, day, start, end)
      ''')
          .eq('course_id', courseId); // 2. CHANGE THIS to search by course_id!

      List<Instructor> fetchedInstructors = [];

      for (var row in response) {
        final instructorData = row['instructor'];
        final officeHoursData = row['office_hours'] as List<dynamic>? ?? [];
        final role = row['role'] ?? 'Instructor';

        List<Dates> parsedHours = [];
        for (var oh in officeHoursData) {
          if (oh['start'] == null || oh['end'] == null) continue;
          final startParts = oh['start'].toString().split(':');
          final endParts = oh['end'].toString().split(':');

          parsedHours.add(
            Dates(
              oh['day'],
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

        fetchedInstructors.add(
          Instructor(
            id: int.parse(instructorData['id'].toString()),
            name: instructorData['name'],
            email: instructorData['email'],
            type: instructorData['type'] ?? role.toString().toLowerCase(),
            faculty: instructorData['faculty'] ?? '',
            office: instructorData['office'] ?? '',
            officehours: parsedHours,
          ),
        );
      }

      if (mounted) {
        setState(() {
          courseInstructors = fetchedInstructors;
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
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
