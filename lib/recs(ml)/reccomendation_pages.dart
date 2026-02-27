// OntarioTechPlus - recommendation_page.dart

import 'package:flutter/material.dart';
import 'recommendation_models.dart';
class RecommendationPage extends StatefulWidget {
  const RecommendationPage({super.key});

  @override
  State<RecommendationPage> createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<RecommendationPage> {
  // Form State Variables
  
  final List<String> _availableInterests = [
    'Programming', 'Gaming', 'Sports', 'Art & Design', 
    'Music', 'Business', 'Volunteering', 'Science', 'Networking'
  ];
  
  final Set<String> _selectedInterests = {};
  double _extroversionLevel = 5.0;
  bool _searchClubs = true;
  bool _searchElectives = true;

  // Mock ML Variables
  bool _isLoading = false;
  // Using Object so we can dynamically store both ClubModel and ElectiveModel in one list
  final List<Object> _recommendations = []; 

  // Function to simulate sending data to your ML algorithm
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

    // pakaging the data for the future ML algorithm
    final studentData = StudentPreferences(
      interests: _selectedInterests,
      extroversionLevel: _extroversionLevel,
      wantsClubs: _searchClubs,
      wantsElectives: _searchElectives,
    );


    //Mock ML response using our dummy data
    setState(() {
      _isLoading = false;
      
      // If the user wants clubs, add a couple of our dummy clubs for now, but this will be from the ML algorithm in the future
      if (studentData.wantsClubs) {
        _recommendations.addAll(dummyClubs.take(2));
      }
      
      // If the user wants electives, add a couple of our dummy electives(for now, but this will be from the ML algorithm in the future)
      if (studentData.wantsElectives) {
        _recommendations.addAll(dummyElectives.take(2));
      }
    });
  }//sdlk

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Clubs & Electives'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What are your interests?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: _availableInterests.map((interest) {
                final isSelected = _selectedInterests.contains(interest);
                return FilterChip(
                  label: Text(interest),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _selectedInterests.add(interest);
                      } else {
                        _selectedInterests.remove(interest);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const Divider(height: 32),

            //Personality Section
            const Text(
              'How do you recharge?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Introverted'),
                Text('Extroverted'),
              ],
            ),
            Slider(
              value: _extroversionLevel,
              min: 1.0,
              max: 10.0,
              divisions: 9,
              label: _extroversionLevel.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _extroversionLevel = value;
                });
              },
            ),
            const Divider(height: 32),

            //  Preferences Section 
            const Text(
              'What are you looking for?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SwitchListTile(
              title: const Text('Student Clubs & Societies'),
              value: _searchClubs,
              onChanged: (bool value) {
                setState(() {
                  _searchClubs = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Elective Courses'),
              value: _searchElectives,
              onChanged: (bool value) {
                setState(() {
                  _searchElectives = value;
                });
              },
            ),
            const SizedBox(height: 24),

            // Action Buttons 
            Center(
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _getRecommendations,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Find My Matches',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            //Recommendations Section 
            if (_recommendations.isNotEmpty) ...[
              const Text(
                'Your Top Matches',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true, 
                physics: const NeverScrollableScrollPhysics(), 
                itemCount: _recommendations.length,
                itemBuilder: (context, index) {
                  final rec = _recommendations[index];
                  
                  // Variables that will hold the extracted data
                  String title = '';
                  String subtitle = '';
                  IconData iconData = Icons.help;
                  Color avatarColor = Colors.grey.shade200;

                  // Type checking to extract the right data from our models
                  if (rec is ClubModel) {
                    title = rec.name;
                    subtitle = rec.description;
                    iconData = Icons.groups;
                    avatarColor = Colors.orange.shade200;
                  } else if (rec is ElectiveModel) {
                    title = '${rec.courseCode} - ${rec.name}';
                    subtitle = rec.description;
                    iconData = Icons.school;
                    avatarColor = Colors.blue.shade200;
                  }

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: avatarColor,
                        child: Icon(
                          iconData,
                          color: Colors.black87,
                        ),
                      ),
                      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(subtitle),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                      },
                    ),
                  );
                },
              ),
            ]
          ],
        ),
      ),
    );
  }
}