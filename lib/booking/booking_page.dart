import 'package:flutter/material.dart';
import 'package:ontario_tech_plus/booking/room_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  List<String> buildings = [];
  int selectedBuilding = -1;

  Future<List<String>> getBuildingNames() async {
    try {
      final List<Map<String, dynamic>> data = await Supabase.instance.client
          .from('building')
          .select('name');
      return data.map((item) => item['name'] as String).toList();
    } catch (error) {
      print('Error fetching building names: $error');
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    getBuildingNames().then((names) {
      setState(() {
        buildings = names;
        buildings.remove("Synchronous (Online)");
      });
      _animationController.forward();
    });
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
    return Scaffold(
      appBar: AppBar(title: const Text("Book a Room")),
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
                      final double slideDuration = 0.4;

                      final double staggerSpace = 1.0 - slideDuration;

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
                          builder: (context) => const RoomPage(),
                        ),
                      );
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
