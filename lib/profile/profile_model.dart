// OntarioTechPlus - profile_model.dart

// This is the model for all profile data

class Profile {
  final String firstname;
  final String lastname;
  final String email;
  final String studentNumber;

  const Profile({
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.studentNumber,
  });

  String get fullName => "$firstname $lastname";

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      firstname: map['firstname'] as String,
      lastname: map['lastname'] as String,
      email: map['email'] as String,
      studentNumber: map['student_number'] as String,
    );
  }
}
