import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ontario_tech_plus/appointments/week_selector.dart'; // Update path if needed
import '../student.dart';

class AdvisorAppointmentPage extends StatefulWidget {
  const AdvisorAppointmentPage({super.key});

  @override
  State<AdvisorAppointmentPage> createState() => _AdvisorAppointmentPageState();
}

class _AdvisorAppointmentPageState extends State<AdvisorAppointmentPage> {
  bool _isLoading = true;
  List<Advisor> advisors = [];
  int selectedIndex = -1;
  int selectedDate = -1;

  // Placeholder student object
  late Student student1 = Student(
    name: "Arad Ayntabli",
    studentid: 100845722,
    program: "Computer Science",
    faculty: "science",
    year: 4,
    courses: [],
  );

  @override
  void initState() {
    super.initState();
    _fetchAdvisorData();
  }

  Future<void> _fetchAdvisorData() async {
    try {
      final supabase = Supabase.instance.client;

      final advisorResponse = await supabase
          .from('advisors')
          .select('''
            id, name, email, faculty, office,
            advisor_office_hours (id, day, start, end)
          ''')
          .eq('faculty', student1.faculty.toLowerCase());

      final List<Advisor> fetchedAdvisors = [];

      for (var row in advisorResponse) {
        final officeHoursData =
            row['advisor_office_hours'] as List<dynamic>? ?? [];

        List<Dates> parsedHours = [];
        for (var oh in officeHoursData) {
          if (oh['start'] == null || oh['end'] == null) continue;

          final startParts = oh['start'].toString().split(':');
          final endParts = oh['end'].toString().split(':');

          parsedHours.add(
            Dates(
              oh['day'],
              TimeOfDay(
                hour: int.parse(startParts[0]),
                minute: int.parse(startParts[1]),
              ),
              TimeOfDay(
                hour: int.parse(endParts[0]),
                minute: int.parse(endParts[1]),
              ),
            ),
          );
        }

        fetchedAdvisors.add(
          Advisor(
            id: int.parse(row['id'].toString()),
            name: row['name'],
            email: row['email'],
            faculty: row['faculty'],
            office: row['office'],
            officehours: parsedHours,
          ),
        );
      }

      if (mounted) {
        setState(() {
          advisors = fetchedAdvisors;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching advisors: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Meet with an Advisor")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Meet with an Advisor")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // --- HORIZONTAL LIST: ADVISORS ---
            const Text(
              "Select an Advisor:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            if (advisors.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No advisors available for your faculty.'),
              )
            else
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(16),
                  itemCount: advisors.length,
                  itemBuilder: (context, index) {
                    final advisor = advisors[index];
                    final isSelected = selectedIndex == index;

                    return GestureDetector(
                      onTap: () => setState(() {
                        selectedIndex = isSelected ? -1 : index;
                        selectedDate = -1; // Reset time when advisor changes
                      }),
                      child: Container(
                        width: 160,
                        margin: const EdgeInsets.only(right: 12),
                        child: Card(
                          color: isSelected
                              ? colorScheme.primary
                              : Colors.white,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                advisor.name,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelected
                                      ? colorScheme.onPrimary
                                      : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Office: ${advisor.office}",
                                style: TextStyle(
                                  color: isSelected
                                      ? colorScheme.onPrimary
                                      : Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            // --- VERTICAL LIST: OFFICE HOURS ---
            if (selectedIndex != -1) ...[
              const Divider(),
              const SizedBox(height: 10),
              const Text(
                "Select a Time:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              if (advisors[selectedIndex].officehours.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("No office hours scheduled for this advisor."),
                ),

              ListView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(), // Prevents scrolling conflicts
                itemCount: advisors[selectedIndex].officehours.length,
                itemBuilder: (context, index) {
                  final time = advisors[selectedIndex].officehours[index];
                  final isSelected = selectedDate == index;

                  return GestureDetector(
                    onTap: () =>
                        setState(() => selectedDate = isSelected ? -1 : index),
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      color: isSelected
                          ? colorScheme.primaryContainer
                          : Colors.white,
                      child: ListTile(
                        title: Text(
                          "${time.day}s",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(time.toString()),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                            : null,
                      ),
                    ),
                  );
                },
              ),

              // --- NEXT BUTTON ---
              if (selectedDate != -1)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WeekSelection(
                            advisor:
                                advisors[selectedIndex], // Passing the selected Advisor
                            student: student1,
                            date: advisors[selectedIndex]
                                .officehours[selectedDate],
                          ),
                        ),
                      );
                    },
                    child: const Text("Next"),
                  ),
                ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
