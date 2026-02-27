// OntarioTechPlus - view_my_schedule_page.dart

// WIP PAGE, will contain a caldendar with the course times soon!

import 'package:flutter/material.dart';

class ViewMySchedulePage extends StatelessWidget {
  const ViewMySchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("View My Schedule")),
      body: const Center(
        child: Text(
          "View My Schedule Page",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
