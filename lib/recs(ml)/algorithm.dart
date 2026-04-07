// lib/recs(ml)/algorithm.dart

class RecommendationEngine {
  // Traits order: [Openness, Conscientiousness, Extraversion, Agreeableness, Neuroticism]
  // Scores range from 0.0 to 10.0

  static const List<String> clubs = [
    'Adventure Club',
    'Art & Design Society',
    'Book Club',
    'General Social Club',
    'Wellness & Meditation Group',
    'Debate Team',
    'Coding & Tech Club',
    'Volunteer Society',
    'Music Ensemble',
    'Esports Association'
  ];

  static const List<String> electives = [
    'Introduction to Psychology',
    'Business & Data Analytics',
    'Creative Writing',
    'Public Speaking',
    'Outdoor Education',
    'Digital Media Production',
    'Sociology of Human Rights'
  ];

  // Synthesized Linear Model Coefficients (Weights) for Clubs
  static const List<List<double>> _clubWeights = [
    [0.8, -0.2, 0.9, 0.1, -0.6],  // Adventure Club (High O, High E, Low N)
    [0.9, -0.4, 0.2, 0.3, 0.1],   // Art & Design (High O, Low C)
    [0.2, 0.8, -0.7, 0.6, 0.0],   // Book Club (High C, Low E)
    [0.5, 0.5, 0.5, 0.5, 0.0],    // General Social Club (Balanced)
    [0.3, 0.2, -0.3, 0.8, 0.9],   // Wellness Group (High A, High N)
    [-0.2, 0.7, 0.8, -0.6, 0.1],  // Debate Team (High C, High E, Low A)
    [0.4, 0.9, -0.5, 0.1, 0.2],   // Coding & Tech (High C, Low E)
    [0.2, 0.4, 0.7, 0.9, -0.2],   // Volunteer Society (High E, High A)
    [0.7, 0.4, 0.6, 0.3, 0.1],    // Music Ensemble (High O, High E)
    [-0.3, -0.2, 0.5, 0.1, 0.4],  // Esports (Low O, Mid E)
  ];

  // Synthesized Linear Model Coefficients (Weights) for Electives
  static const List<List<double>> _electiveWeights = [
    [0.7, 0.1, 0.3, 0.8, 0.2],    // Psychology (High O, High A)
    [0.1, 0.9, 0.2, -0.2, -0.4],  // Business Analytics (High C, Low N)
    [0.9, 0.2, -0.4, 0.3, 0.5],   // Creative Writing (High O, Low E)
    [0.2, 0.4, 0.9, 0.1, -0.5],   // Public Speaking (High E, Low N)
    [0.6, 0.2, 0.8, 0.4, -0.6],   // Outdoor Education (High O, High E)
    [0.8, 0.3, 0.5, 0.2, 0.1],    // Digital Media (High O, Mid E)
    [0.5, 0.6, 0.4, 0.7, 0.2],    // Sociology (High A, High C)
  ];

  /// Predicts the best item from a list based on user personality scores using a linear decision function.
  static String _predictBestMatch(List<double> userScores, List<String> names, List<List<double>> weights) {
    if (userScores.length != 5) throw ArgumentError('Must provide exactly 5 trait scores.');

    double maxScore = -double.infinity;
    int bestIndex = 0;

    for (int i = 0; i < weights.length; i++) {
      double currentScore = 0.0;
      // Calculate dot product (Linear prediction)
      for (int j = 0; j < 5; j++) {
        currentScore += weights[i][j] * userScores[j];
      }

      if (currentScore > maxScore) {
        maxScore = currentScore;
        bestIndex = i;
      }
    }
    return names[bestIndex];
  }

  /// Returns the recommended Club based on Big 5 traits
  static String getRecommendedClub(List<double> traits) {
    return _predictBestMatch(traits, clubs, _clubWeights);
  }

  /// Returns the recommended Elective based on Big 5 traits
  static String getRecommendedElective(List<double> traits) {
    return _predictBestMatch(traits, electives, _electiveWeights);
  }
}