// OntarioTechPlus - booking_page.dart
// Sample booking page

import 'package:flutter/material.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  List<String> buildings = [
    'Shawenjigewining',
    'Science Building',
    'Business and IT Building',
    'Energy Research Center',
    'Library',
  ];
  int selectedBuilding = -1;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text("Booking")),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
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
              Divider(),
              SizedBox(
                height: 400,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    itemCount: buildings.length,
                    itemBuilder: (context, index) {
                      final isSelected = selectedBuilding == index;

                      return GestureDetector(
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
                      );
                    },
                  ),
                ),
              ),
              Divider(),
              if (selectedBuilding != -1)
                Text("Selected Building: ${buildings[selectedBuilding]}"),
            ],
          ),
        ),
      ),
    );
  }
}
