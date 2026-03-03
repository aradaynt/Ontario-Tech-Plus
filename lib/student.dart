import 'package:flutter/material.dart';

class Student {
  String name = '';
  int studentid = 0;
  String email = '';
  String program = '';
  String faculty = '';
  int year = 0;
  List<Course> courses = [];
  Student({
    required this.name,
    required this.studentid,
    required this.email,
    required this.program,
    required this.faculty,
    required this.year,
    required this.courses,
  });
  void addCourse(Course course) {
    courses.add(course);
  }

  void removeCourse(Course course) {
    courses.remove(course);
  }

  void editCourse(Course course) {
    int index = courses.indexOf(course);
    if (index != -1) {
      courses[index] = course;
    }
  }
}

enum SessionType { lecture, lab, tutorial }

class Course {
  String name = '';
  String code = '';
  List<Dates> when;
  String location = '';
  Instructor instructor;
  SessionType sessiontype = SessionType.lecture;
  Course({
    required this.name,
    required this.code,
    required this.when,
    required this.location,
    required this.instructor,
    required this.sessiontype,
  });
}

class Dates {
  String day;
  TimeOfDay start;
  TimeOfDay end;
  String? courseCode;
  Dates(this.day, this.start, this.end, [this.courseCode]);
  @override
  String toString() {
    final startperiod = start.hour >= 12 ? 'PM' : 'AM';
    final starthour = start.hour == 0
        ? 12
        : (start.hour > 12 ? start.hour - 12 : start.hour);
    final startminute = start.minute.toString().padLeft(2, '0');

    final endperiod = end.hour >= 12 ? 'PM' : 'AM';
    final endhour = end.hour == 0
        ? 12
        : (end.hour > 12 ? end.hour - 12 : end.hour);
    final endminute = end.minute.toString().padLeft(2, '0');
    return '$day: \n$starthour:$startminute $startperiod - $endhour:$endminute $endperiod';
  }
}

class Advisor {
  int id;
  String name;
  String email;
  String faculty;
  String office;
  List<Dates> officehours;

  Advisor({
    required this.id,
    required this.name,
    required this.email,
    required this.faculty,
    required this.office,
    required this.officehours,
  });
}

class Instructor {
  final int id;
  String name;
  String email;
  String type;
  String faculty;
  String office;
  List<Dates> officehours;

  Instructor({
    required this.id,
    required this.name,
    required this.email,
    required this.type,
    required this.faculty,
    this.office = '',
    required this.officehours,
  });
}
