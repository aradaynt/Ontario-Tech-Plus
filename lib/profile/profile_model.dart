// OntarioTechPlus - profile_model.dart

// This is the model for all profile data

class Profile {
  final String firstname;
  final String lastname;
  final String email;
  final String studentNumber;
  final String program;
  final String faculty;
  final String year;

  const Profile({
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.studentNumber,
    required this.program,
    required this.faculty,
    required this.year,
  });

  String get fullName => "$firstname $lastname";

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      firstname: map['firstname'] as String,
      lastname: map['lastname'] as String,
      email: map['email'] as String,
      studentNumber: map['student_number'] as String,
      program: map['program'] as String,
      faculty: map['faculty'] as String,
      year: map['year'] as String,
    );
  }
}
