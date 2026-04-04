import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ontario_tech_plus/booking/room_page.dart';
import 'package:ontario_tech_plus/booking/my_room_bookings.dart';
import '../student.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;

  bool _isLoading = true;
  late Student currentStudent;

  List<String> buildings = [];
  int selectedBuilding = -1;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) throw Exception("User is not logged in!");

      final profileResponse = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      int safeYear =
          int.tryParse(
            profileResponse['year'].toString().replaceAll('+', ''),
          ) ??
          0;

      currentStudent = Student(
        name: "${profileResponse['firstname']} ${profileResponse['lastname']}",
        studentid: int.parse(profileResponse['student_number'].toString()),
        email: profileResponse['email'],
        program: profileResponse['program'],
        faculty: profileResponse['faculty'],
        year: safeYear,
        courses: [],
      );

      final List<Map<String, dynamic>> data = await supabase
          .from('building')
          .select('name');
      final fetchedBuildings = data
          .map((item) => item['name'] as String)
          .toList();
      fetchedBuildings.remove("Synchronous (Online)");

      if (mounted) {
        setState(() {
          buildings = fetchedBuildings;
          _isLoading = false;
        });
        _animationController.forward();
      }
    } catch (error) {
      print('Error fetching initial data: $error');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load user data.")),
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Book a Room")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Book a Room"),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmarks),
            tooltip: 'My Bookings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MyRoomBookingsPage(student: currentStudent),
                ),
              ).then((_) {
                _animationController.reset();
                _animationController.forward();
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Please Select a Building",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const Divider(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  thickness: 12,
                  radius: const Radius.circular(10),
                  child: ListView.builder(
                    controller: _scrollController,
                    primary: false,
                    itemCount: buildings.length,
                    itemBuilder: (context, index) {
                      final isSelected = selectedBuilding == index;
                      const double slideDuration = 0.4;
                      const double staggerSpace = 1.0 - slideDuration;
                      final int totalItems = buildings.length;
                      final double step = totalItems > 1
                          ? staggerSpace / (totalItems - 1)
                          : 0.0;
                      final double delay = index * step;
                      final double end = delay + slideDuration;

                      final slideAnimation =
                          Tween<Offset>(
                            begin: const Offset(-1.5, 0.0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: Interval(
                                delay,
                                end,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                          );

                      return SlideTransition(
                        position: slideAnimation,
                        child: GestureDetector(
                          onTap: () => setState(
                            () => selectedBuilding = isSelected ? -1 : index,
                          ),
                          child: Center(
                            child: Card(
                              color: isSelected
                                  ? colorScheme.primary
                                  : Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  buildings[index],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isSelected
                                        ? colorScheme.onPrimary
                                        : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            if (selectedBuilding != -1)
              Column(
                children: [
                  const Divider(),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RoomPage(
                            buildingName: buildings[selectedBuilding],
                            student: currentStudent,
                          ),
                        ),
                      ).then((_) {
                        _animationController.reset();
                        _animationController.forward();
                      });
                    },
                    child: const Text("Next"),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
