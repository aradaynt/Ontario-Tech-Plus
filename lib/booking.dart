import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ontario_tech_plus/student.dart';

class bookingpage extends StatefulWidget {
  const bookingpage({super.key});
  @override
  State<bookingpage> createState() => _bookingPageState();
}

class _bookingPageState extends State<bookingpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Booking")),
      body: Column(children: [SizedBox(height: 20)]),
    );
  }
}
