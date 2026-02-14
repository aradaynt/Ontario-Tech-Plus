import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class bookingpage extends StatefulWidget {
  const bookingpage({super.key});
  @override
  State<bookingpage> createState() => _bookingPageState();
}

class _bookingPageState extends State<bookingpage> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text("Booking")),
      body: Column(
        children: [
          SizedBox(height: 20),
          Card(
            color: colorScheme.primary,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Booking",
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Divider(),
        ],
      ),
    );
  }
}
