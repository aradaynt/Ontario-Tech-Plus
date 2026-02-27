// --- The Local "ML" Algorithm ---
//will not be in use currently only skeleton of later algorithm(most likely done in pytorch)
  
  // 1. Helper function to calculate the match score
  double _calculateMatchScore(StudentPreferences prefs, List<String> itemTags, double itemExtroversion) {
    // Score Part A: Interests Overlap
    int tagMatches = 0;
    for (String interest in prefs.interests) {
      if (itemTags.contains(interest)) {
        tagMatches++;
      }
    }
    
    // Score Part B: Personality Match
    // Calculate the difference between the user's extroversion and the item's.
    // A smaller difference means a better match. Max difference is 9.0.
    double extroversionDifference = (prefs.extroversionLevel - itemExtroversion).abs();
    
    // Convert the difference into a positive score out of 10.
    double personalityScore = 10.0 - extroversionDifference; 

    // Final Score: Weight the tags heavily (e.g., 10 points per matching tag) 
    // and add the personality score.
    return (tagMatches * 10.0) + personalityScore;
  }

  // 2. Updated fetching function
  void _getRecommendations() async {
    if (_selectedInterests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one interest!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _recommendations.clear();
    });

    final studentData = StudentPreferences(
      interests: _selectedInterests,
      extroversionLevel: _extroversionLevel,
      wantsClubs: _searchClubs,
      wantsElectives: _searchElectives,
    );

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1500));

    // Create a temporary list to hold items and their calculated scores
    List<Map<String, dynamic>> scoredItems = [];

    // Score all the clubs if the user wants them
    if (studentData.wantsClubs) {
      for (var club in dummyClubs) {
        double score = _calculateMatchScore(studentData, club.tags, club.extroversionScore);
        // Only consider it a match if they have at least *some* overlapping interest (score > 10)
        if (score >= 10.0) { 
          scoredItems.add({'item': club, 'score': score});
        }
      }
    }

    // Score all the electives if the user wants them
    if (studentData.wantsElectives) {
      for (var elective in dummyElectives) {
        double score = _calculateMatchScore(studentData, elective.tags, elective.extroversionScore);
        if (score >= 10.0) {
          scoredItems.add({'item': elective, 'score': score});
        }
      }
    }

    // Sort the list from highest score to lowest score
    scoredItems.sort((a, b) => b['score'].compareTo(a['score']));

    setState(() {
      _isLoading = false;
      // Extract just the item objects from the sorted map, taking the top 3 results
      _recommendations = scoredItems.take(3).map((e) => e['item'] as Object).toList();
      
      // Fallback if no exact matches were found
      if (_recommendations.isEmpty) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No exact matches found. Try selecting more interests!')),
        );
      }
    });
  }