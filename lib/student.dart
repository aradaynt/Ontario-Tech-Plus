class Student {
  String name = '';
  int studentid = 0;
  String program = '';
  String faculty = '';
  int year = 0;
  List<Course> courses = [];
  Student(this.name, this.studentid, this.program, this.faculty, this.year);
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
  DateTime? whattime;
  List<DateTime>? whatdays;
  String location = '';
  Instructor? instructor;
  SessionType sessiontype = SessionType.lecture;
  Course(
    this.name,
    this.code,
    this.whattime,
    this.whatdays,
    this.location,
    this.instructor,
    this.sessiontype,
  );
}

class Instructor {
  String name = '';
  String email = '';
  String office = '';
  DateTime? officehours;
  Instructor(this.name, this.email, this.office, this.officehours);
}
