class MLService {
  // This MUST match the exact alphabetical order output by Python's LabelEncoder!
  final List<String> _clubs = [
    'Accounting & Finance Association',
    'Anime & Manga Club',
    'Astronomy Club',
    'Board Game Club',
    'Campus Community Garden',
    'Campus Radio & Journalism',
    'Computer Science Society',
    'Debate Society',
    'Esports Club',
    'Game Development Society',
    'Model United Nations (MUN)',
    'Music / Acapella Group',
    'Nursing Students Association',
    'Ontario Tech Racing (FSAE)',
    'Photography Club',
    'Powerlifting / Barbell Club',
    'Pre-Medical Society',
    'Robotics & AI Club',
    'Sustainability & Environmental Society',
    'Women in Engineering (WiE)'
  ];

  bool _isInitialized = false;

  Future<void> initialize() async {
    // Simulate model loading time
    await Future.delayed(const Duration(milliseconds: 500));
    _isInitialized = true;
    print('ML Service initialized successfully.');
  }

  String predictClub(List<double> userTraits) {
    if (!_isInitialized) {
      return "Service not ready";
    }

    if (userTraits.length != 5) {
      return "Invalid input";
    }

    // Extract Big 5 personality traits
    final openness = userTraits[0];
    final conscientiousness = userTraits[1];
    final extraversion = userTraits[2];
    final agreeableness = userTraits[3];
    final neuroticism = userTraits[4];

    // Simple rule-based recommendation system
    return _recommendClubBasedOnTraits(
      openness: openness,
      conscientiousness: conscientiousness,
      extraversion: extraversion,
      agreeableness: agreeableness,
      neuroticism: neuroticism,
    );
  }

  String _recommendClubBasedOnTraits({
    required double openness,
    required double conscientiousness,
    required double extraversion,
    required double agreeableness,
    required double neuroticism,
  }) {
    // High openness (creative, curious) + High extraversion (social)
    if (openness > 7 && extraversion > 7) {
      return 'Anime & Manga Club'; // Creative and social
    }

    // High openness + Low extraversion (independent thinkers)
    if (openness > 7 && extraversion < 4) {
      return 'Astronomy Club'; // Intellectual and solitary pursuits
    }

    // High conscientiousness + High agreeableness (organized, helpful)
    if (conscientiousness > 7 && agreeableness > 7) {
      return 'Campus Community Garden'; // Structured community service
    }

    // High extraversion + High agreeableness (social, cooperative)
    if (extraversion > 7 && agreeableness > 7) {
      return 'Model United Nations (MUN)'; // Social and diplomatic
    }

    // High conscientiousness + Low neuroticism (reliable, calm)
    if (conscientiousness > 7 && neuroticism < 4) {
      return 'Computer Science Society'; // Technical and methodical
    }

    // High extraversion + Low conscientiousness (spontaneous, social)
    if (extraversion > 7 && conscientiousness < 4) {
      return 'Esports Club'; // Competitive and social gaming
    }

    // High openness + High conscientiousness (creative, organized)
    if (openness > 7 && conscientiousness > 7) {
      return 'Photography Club'; // Artistic and technical
    }

    // High agreeableness + High extraversion (friendly, outgoing)
    if (agreeableness > 7 && extraversion > 7) {
      return 'Music / Acapella Group'; // Collaborative performance
    }

    // High conscientiousness + Low agreeableness (focused, independent)
    if (conscientiousness > 7 && agreeableness < 4) {
      return 'Ontario Tech Racing (FSAE)'; // Technical engineering challenge
    }

    // Moderate traits - default recommendations
    if (openness > 5 && conscientiousness > 5) {
      return 'Robotics & AI Club'; // Technical and innovative
    }

    if (extraversion > 5 && agreeableness > 5) {
      return 'Debate Society'; // Social and intellectual
    }

    if (conscientiousness > 5 && extraversion < 6) {
      return 'Women in Engineering (WiE)'; // Supportive technical community
    }

    // Fallback based on highest trait
    final traits = [openness, conscientiousness, extraversion, agreeableness, neuroticism];
    final maxTraitIndex = traits.indexOf(traits.reduce((a, b) => a > b ? a : b));

    switch (maxTraitIndex) {
      case 0: return 'Game Development Society'; // Creative
      case 1: return 'Pre-Medical Society'; // Structured
      case 2: return 'Board Game Club'; // Social
      case 3: return 'Sustainability & Environmental Society'; // Cooperative
      case 4: return 'Powerlifting / Barbell Club'; // Stress-relieving
      default: return 'Campus Radio & Journalism'; // General interest
    }
  }

  void dispose() {
    _isInitialized = false;
    print('ML Service disposed.');
  }
}