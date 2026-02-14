class Student {
  String name = '';
  int studentid = 0;
  String program = '';
  String faculty = '';
  int year = 0;
  List<Course> courses = [];
}

enum SessionType { lecture, lab, tutorial }

class Course {
  String name = '';
  String code = '';
  DateTime? whattime;
  List<DateTime>? whatdays;
  String location = '';
  Instructor? instructor;
  SessionType sessiontype = SessionType.lecture;
}

class Instructor {
  String name = '';
  String email = '';
  String office = '';
  DateTime? officehours;
}
