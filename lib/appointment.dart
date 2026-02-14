import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'booking.dart';

class appointmentpage extends StatefulWidget {
  const appointmentpage({super.key});
  @override
  State<appointmentpage> createState() => _appointmentPageState();
}

class _appointmentPageState extends State<appointmentpage> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text("Booking")),
      body: Column(
        children: [
          SizedBox(height: 20),
          Card(
            margin: EdgeInsets.only(left: 10, right: 10),
            color: colorScheme.primary,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Would you like to Book a Room ",
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "or",
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    " Schedule an Appointment",
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 60),
          ElevatedButton(
            onPressed: (() => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => bookingpage()),
            )),
            child: Text("Book Room"),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: (() => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => appointmentbookingpage()),
            )),
            child: Text("Schedule Appointment"),
          ),
        ],
      ),
    );
  }
}

class appointmentbookingpage extends StatefulWidget {
  const appointmentbookingpage({super.key});
  @override
  State<appointmentbookingpage> createState() => _appointmentbookingPageState();
}

class _appointmentbookingPageState extends State<appointmentbookingpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Booking")),
      body: Column(children: [SizedBox(height: 20)]),
    );
  }
}
