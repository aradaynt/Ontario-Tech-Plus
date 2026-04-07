import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ontario_tech_plus/booking/room_page.dart';
import 'package:ontario_tech_plus/booking/my_room_bookings.dart';
import '../profile/profile_provider.dart';

class BookingPage extends ConsumerStatefulWidget {
  const BookingPage({super.key});

  @override
  ConsumerState<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends ConsumerState<BookingPage>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;

  bool _isLoadingBuildings = true;
  List<String> buildings = [];
  int selectedBuilding = -1;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _fetchBuildings();
  }

  Future<void> _fetchBuildings() async {
    try {
      final supabase = Supabase.instance.client;
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
          _isLoadingBuildings = false;
        });
        _animationController.forward();
      }
    } catch (error) {
      print('Error fetching buildings: $error');
      if (mounted) {
        setState(() => _isLoadingBuildings = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load buildings.")),
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
    final profileAsyncValue = ref.watch(profileProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return profileAsyncValue.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text("Error: $err"))),
      data: (profile) {
        if (profile == null) {
          return const Scaffold(body: Center(child: Text("Profile not found")));
        }

        if (_isLoadingBuildings) {
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
                          MyRoomBookingsPage(profile: profile),
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
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
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
                                () =>
                                    selectedBuilding = isSelected ? -1 : index,
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
                                profile: profile,
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
      },
    );
  }
}
