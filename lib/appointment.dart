import 'package:emailjs/emailjs.dart' as emailjs;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'booking.dart';
import 'student.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});
  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
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
    email: "aradaynt14@gmail.com",
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
  int selectedDate = -1;

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
    if (student1.faculty == "Science") {
      fullList = [...scienceAdvisors, ...uniqueProfessors];
    } else {
      fullList = uniqueProfessors;
    }
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text("Schedule an Appointment")),
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
          if (selectedIndex != -1)
            Column(
              children: [
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
                ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: fullList[selectedIndex].officehours.length,
                  itemBuilder: (context, index) {
                    final time = fullList[selectedIndex].officehours[index];
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
                      child: Container(
                        width: 160,
                        margin: const EdgeInsets.only(right: 12),
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
                                const SizedBox(height: 4),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          Spacer(),
          if (selectedDate != -1)
            ElevatedButton(
              onPressed: (() => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SpecificTime(
                    instructor: fullList[selectedIndex],
                    student: student1,
                    date: fullList[selectedIndex].officehours[selectedDate],
                  ),
                ),
              )),
              child: Text("Next"),
            ),
          SizedBox(height: 60),
        ],
      ),
    );
  }
}

class SpecificTime extends StatefulWidget {
  final Instructor instructor;
  final Student student;
  final Dates date;
  const SpecificTime({
    super.key,
    required this.instructor,
    required this.student,
    required this.date,
  });
  @override
  State<SpecificTime> createState() => _SpecificTimeState();
}

class _SpecificTimeState extends State<SpecificTime> {
  List<Dates> generateTimeslots() {
    List<Dates> timeslots = [];
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

      // Add the new 10-minute slot to the list
      timeslots.add(Dates(widget.date.day, slotStart, slotEnd));

      // Move to the next slot
      currentMinutes = nextMinutes;
    }
    return timeslots;
  }

  int selectedTime = -1;
  //TODO add a list of all booked timeslots, check if the selected time is in the list
  //If it is in the list, don't allow selection, gray it out

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
                    itemCount: generateTimeslots().length,
                    itemBuilder: (context, index) {
                      final time = generateTimeslots()[index];
                      final isSelected = selectedTime == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedTime = -1;
                            } else {
                              selectedTime = index;
                            }
                          });
                          print("Selected: ${time.toString()}");
                        },
                        child: Container(
                          width: 160,
                          margin: const EdgeInsets.only(right: 12),
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
                      onPressed: (() => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EmailPage(
                            instructor: widget.instructor,
                            student: widget.student,
                            date: generateTimeslots()[selectedTime],
                          ),
                        ),
                      )),
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

class EmailPage extends StatefulWidget {
  final Instructor instructor;
  final Student student;
  final Dates date;
  const EmailPage({
    super.key,
    required this.instructor,
    required this.student,
    required this.date,
  });
  @override
  State<EmailPage> createState() => _EmailPageState();
}

class _EmailPageState extends State<EmailPage> {
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();
  String subject = '';
  String body = '';
  late String instructorEmail = widget.instructor.email;
  Future<void> loadFile() async {
    await dotenv.load(fileName: ".env");
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text("Reason for Appointment")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsetsGeometry.only(left: 30),
            child: Text(
              "Please explain the purpose of your appointment.",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: EdgeInsetsGeometry.only(left: 16, right: 16, bottom: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: TextFormField(
                  controller: _subjectController,
                  decoration: InputDecoration(
                    hintText: "Subject",
                    hintStyle: TextStyle(
                      color: Colors.black.withValues(alpha: 0.4),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.grey, width: 2.0),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      subject = value;
                    });
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsetsGeometry.all(16),
            child: Card(
              child: SizedBox(
                height: 500,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: TextFormField(
                    minLines: 20,
                    maxLines: null,
                    controller: _bodyController,
                    decoration: InputDecoration(
                      hintText: "Body",
                      hintStyle: TextStyle(
                        color: Colors.black.withValues(alpha: 0.4),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.grey, width: 2.0),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        body = value;
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
          if (subject.isNotEmpty && body.isNotEmpty)
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () async {
                  print("Sending to: $instructorEmail");
                  print(
                    "Student Email: ${widget.student.name.toLowerCase().replaceAll(' ', '.')}@gmail.com",
                  );
                  try {
                    await emailjs.send(
                      'service_6znzzht',
                      'template_89bpfms',
                      {
                        'email': instructorEmail,
                        'subject': subject,
                        'message':
                            "Appointment for: \n${widget.date.toString()}\nReason for this appointment is: \n$body",
                        'user_email':
                            "${widget.student.name.toLowerCase().replaceAll(' ', '.')}@ontariotechu.net",
                        'name': widget.student.name,
                      },
                      emailjs.Options(
                        publicKey: '3NwU3xKGeU3nLblXw',
                        privateKey: dotenv.env['MY_PRIVATE_KEY'],
                      ),
                    );

                    _subjectController.clear();
                    _bodyController.clear();
                    subject = '';
                    body = '';

                    if (mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AppointmentPage(),
                        ),
                      );
                    }
                  } catch (error) {
                    if (error is emailjs.EmailJSResponseStatus) {
                      // This will print the actual reason (e.g., "The 'to_email' parameter is required")
                      print('Status: ${error.status}');
                      print('Error Text: ${error.text}');
                    }
                  }
                },
                child: Text("Send"),
              ),
            ),
        ],
      ),
    );
  }
}
