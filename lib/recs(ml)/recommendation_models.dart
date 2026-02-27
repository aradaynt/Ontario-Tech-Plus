// OntarioTechPlus - recommendation_models.dart

//What the ML algorithm receives
class StudentPreferences {
  final Set<String> interests;
  final double extroversionLevel;
  final bool wantsClubs;
  final bool wantsElectives;

  StudentPreferences({
    required this.interests,
    required this.extroversionLevel,
    required this.wantsClubs,
    required this.wantsElectives,
  });
}

//Club Recommendations
class ClubModel {
  final String name;
  final String description;
  final List<String> tags; 
  final double extroversionScore; // 1.0 to 10.0 scale for ML matching

  ClubModel({
    required this.name,
    required this.description,
    required this.tags,
    required this.extroversionScore,
  });
}

///Elective Recommendations
class ElectiveModel {
  final String courseCode;
  final String name;
  final String description;
  final List<String> tags;
  final double extroversionScore;

  ElectiveModel({
    required this.courseCode,
    required this.name,
    required this.description,
    required this.tags,
    required this.extroversionScore,
  });
}

// --- Dummy Data for UI Testing ---
// These lists are there to test the ui before the ML algorithm is connected.

final List<ClubModel> dummyClubs = [
  ClubModel(
    name: 'Ontario Tech Racing',
    description: 'Design, build, and race a formula-style electric vehicle.',
    tags: ['Science', 'Programming', 'Business'],
    extroversionScore: 7.0, 
  ),
  ClubModel(
    name: 'BITSOC (Business and IT Society)',
    description: 'Empowering FBIT students through networking and professional development.',
    tags: ['Business', 'Networking'],
    extroversionScore: 8.5, 
  ), //slkd
  ClubModel(
    name: 'Game Art Club',
    description: 'A community for students passionate about game design and digital art.',
    tags: ['Gaming', 'Art & Design'],
    extroversionScore: 4.0, // Great for introverted creatives
  ),
  ClubModel(
    name: 'Ontario Tech Psychology Association',
    description: 'Broadening the psychology community through mental health advocacy and networking.',
    tags: ['Volunteering', 'Science', 'Networking'],
    extroversionScore: 6.5,
  ),
];

final List<ElectiveModel> dummyElectives = [
  ElectiveModel(
    courseCode: 'INFR 1335U',
    name: 'Digital Media',
    description: 'An introduction to digital media creation, perfect for creative minds.',
    tags: ['Art & Design', 'Gaming'],
    extroversionScore: 3.0, 
  ),
  ElectiveModel(
    courseCode: 'BUSI 1520U',
    name: 'Business Computer Applications',
    description: 'Learn essential business software and networking skills.',
    tags: ['Business', 'Programming'],
    extroversionScore: 6.0,
  ),
];