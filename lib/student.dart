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
  Instructor? instructor;
  SessionType sessiontype = SessionType.lecture;
  Course({
    required this.name,
    required this.code,
    required this.when,
    required this.location,
    this.instructor,
    required this.sessiontype,
  });
}

class Dates {
  String day;
  TimeOfDay start;
  TimeOfDay end;
  Dates(this.day, this.start, this.end);
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
