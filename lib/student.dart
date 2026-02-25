import 'package:flutter/material.dart';

class Student {
  String name = '';
  int studentid = 0;
  String program = '';
  String faculty = '';
  int year = 0;
  List<Course> courses = [];
  Student({
    required this.name,
    required this.studentid,
    required this.program,
    required this.faculty,
    required this.year,
    required List<Course> this.courses,
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
  Dates(this.day, this.start, this.end);
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

class Instructor {
  String name = '';
  String email = '';
  String office = '';
  List<Dates> officehours;
  Instructor({
    required this.name,
    required this.email,
    required this.office,
    required this.officehours,
  });
}
