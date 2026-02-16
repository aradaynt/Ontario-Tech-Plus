import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'booking.dart';
import 'student.dart';

class appointmentpage extends StatefulWidget {
  const appointmentpage({super.key});
  @override
  State<appointmentpage> createState() => _appointmentPageState();
}

class _appointmentPageState extends State<appointmentpage> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text("Booking")),
      body: Column(
        children: [
          SizedBox(height: 20),
          Card(
            margin: EdgeInsets.only(left: 10, right: 10),
            color: colorScheme.primary,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Would you like to Book a Room ",
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "or",
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    " Schedule an Appointment",
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 60),
          ElevatedButton(
            onPressed: (() => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => bookingpage()),
            )),
            child: Text("Book Room"),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: (() => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => appointmentbookingpage()),
            )),
            child: Text("Schedule Appointment"),
          ),
        ],
      ),
    );
  }
}

class appointmentbookingpage extends StatefulWidget {
  const appointmentbookingpage({super.key});
  @override
  State<appointmentbookingpage> createState() => _appointmentbookingPageState();
}

class _appointmentbookingPageState extends State<appointmentbookingpage> {
  Dates date1 = Dates(
    "Monday",
    TimeOfDay(hour: 10, minute: 0),
    TimeOfDay(hour: 12, minute: 0),
  );
  Dates date2 = Dates(
    "Tuesday",
    TimeOfDay(hour: 10, minute: 0),
    TimeOfDay(hour: 12, minute: 0),
  );
  Dates date3 = Dates(
    "Wednesday",
    TimeOfDay(hour: 14, minute: 0),
    TimeOfDay(hour: 16, minute: 0),
  );
  Dates date4 = Dates(
    "Thursday",
    TimeOfDay(hour: 14, minute: 0),
    TimeOfDay(hour: 16, minute: 0),
  );
  Dates date5 = Dates(
    "Wednesday",
    TimeOfDay(hour: 15, minute: 40),
    TimeOfDay(hour: 17, minute: 0),
  );
  Dates date6 = Dates(
    "Friday",
    TimeOfDay(hour: 15, minute: 40),
    TimeOfDay(hour: 17, minute: 0),
  );
  Dates date7 = Dates(
    "Tuesday",
    TimeOfDay(hour: 9, minute: 40),
    TimeOfDay(hour: 11, minute: 0),
  );
  Dates date8 = Dates(
    "Thursday",
    TimeOfDay(hour: 9, minute: 40),
    TimeOfDay(hour: 11, minute: 0),
  );
  late Instructor instructor1 = Instructor(
    name: "Ali Neshati",
    email: "ali.neshati@gmail.com",
    office: "UA4051",
    officehours: [date1, date2],
  );
  late Instructor instructor2 = Instructor(
    name: "Ken Pu",
    email: "ken.pu@gmail.com",
    office: "UA4052",
    officehours: [date3, date4],
  );
  late Instructor instructor3 = Instructor(
    name: "Cristiano Politowsky",
    email: "cristiano.politowsky@gmail.com",
    office: "UA2065",
    officehours: [date4, date5],
  );
  late Instructor advisor1 = Instructor(
    name: "Advisor - Jenna Golazzo",
    email: "jenna.golazzo@gmail.com",
    office: "UA2045",
    officehours: [date1, date2, date3, date4],
  );
  late Instructor advisor2 = Instructor(
    name: "Advisor - Other one",
    email: "other.one@gmail.com",
    office: "UA2044",
    officehours: [date1, date2, date3, date4],
  );
  late Course course1 = Course(
    name: "Advance Mobile Devices",
    code: "CSCI 4101U",
    when: [date5, date6],
    location: "SHA247",
    instructor: instructor1,
    sessiontype: SessionType.lecture,
  );
  late Course course2 = Course(
    name: "Machine Learning 2",
    code: "CSCI 4052U",
    when: [date7, date8],
    location: "SHA248",
    instructor: instructor2,
    sessiontype: SessionType.lecture,
  );
  late Course course3 = Course(
    name: "Interactive Media",
    code: "CSCI 4160U",
    when: [date1],
    location: "UB2054",
    instructor: instructor3,
    sessiontype: SessionType.lecture,
  );
  late Course course4 = Course(
    name: "Software Quality Assurance",
    code: "CSCI 3060U",
    when: [date2],
    location: "UA 1140",
    instructor: instructor3,
    sessiontype: SessionType.lecture,
  );
  late Student student1 = Student(
    name: "Arad Ayntabli",
    studentid: 100845722,
    program: "Computer Science",
    faculty: "Science",
    year: 4,
    courses: [course1, course2, course3, course4],
  );
  late List<Instructor> uniqueProfessors;
  int selectedIndex = -1;
  late List<Instructor> scienceAdvisors = [advisor1, advisor2];
  late List<Instructor> fullList;

  @override
  void initState() {
    super.initState();
    uniqueProfessors = student1.courses
        .map((course) => course.instructor)
        .toSet()
        .toList();
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
                selectedIndex = index;
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
    if (student1.faculty == "Science") {
      fullList = [...scienceAdvisors, ...uniqueProfessors];
    } else {
      fullList = uniqueProfessors;
    }
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text("Booking")),
      body: Column(
        children: [
          SizedBox(height: 20),
          Card(
            color: colorScheme.primary,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                student1.name,
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          buildlistview(colorScheme, fullList),
          SizedBox(height: 20),
          Card(
            color: colorScheme.primary,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Select a Time",
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (selectedIndex != -1)
            for (var i in fullList[selectedIndex].officehours)
              Card(
                color: colorScheme.primary,
                child: Padding(
                  padding: EdgeInsetsGeometry.all(18),
                  child: Text(i.toString()),
                ),
              ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
