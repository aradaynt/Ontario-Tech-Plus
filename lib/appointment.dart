import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class appointmentpage extends StatefulWidget {
  const appointmentpage({super.key});
  @override
  State<appointmentpage> createState() => _appointmentPageState();
}

class _appointmentPageState extends State<appointmentpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Booking")),
      body: Column(
        children: [
          Text("Would you like to Book a room, or schedule an appointment"),
        ],
      ),
    );
  }
}
