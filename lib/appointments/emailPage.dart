import 'package:emailjs/emailjs.dart' as emailjs;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../student.dart';
import 'appointment.dart';

class EmailPage extends StatefulWidget {
  final Instructor instructor;
  final Student student;
  final Dates date;
  final String? week;
  const EmailPage({
    super.key,
    required this.instructor,
    required this.student,
    required this.date,
    required this.week,
  });
  @override
  State<EmailPage> createState() => _EmailPageState();
}

class _EmailPageState extends State<EmailPage> {
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();
  String subject = '';
  String body = '';
  late String instructorEmail = widget.instructor.email;
  Future<void> loadFile() async {
    await dotenv.load(fileName: ".env");
  }

  @override
  Widget build(BuildContext context) {
    //final colorScheme = Theme.of(context).colorScheme;
    loadFile();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text("Reason for Appointment")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsetsGeometry.only(left: 30),
            child: Text(
              "Please explain the purpose of your appointment.",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: EdgeInsetsGeometry.only(left: 16, right: 16, bottom: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: TextFormField(
                  controller: _subjectController,
                  decoration: InputDecoration(
                    hintText: "Subject",
                    hintStyle: TextStyle(
                      color: Colors.black.withValues(alpha: 0.4),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.grey, width: 2.0),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      subject = value;
                    });
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsetsGeometry.all(16),
            child: Card(
              child: SizedBox(
                height: 500,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: TextFormField(
                    minLines: 20,
                    maxLines: null,
                    controller: _bodyController,
                    decoration: InputDecoration(
                      hintText: "Body",
                      hintStyle: TextStyle(
                        color: Colors.black.withValues(alpha: 0.4),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.grey, width: 2.0),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        body = value;
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
          if (subject.isNotEmpty && body.isNotEmpty)
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () async {
                  print("Sending to: $instructorEmail");
                  print(
                    "Student Email: ${widget.student.name.toLowerCase().replaceAll(' ', '.')}@gmail.com",
                  );
                  try {
                    await emailjs.send(
                      'service_6znzzht',
                      'template_89bpfms',
                      {
                        'email': instructorEmail,
                        'subject': subject,
                        'message':
                            "Appointment for: \n${widget.week}\n${widget.date.toString()}\nReason for this appointment is: \n$body",
                        'user_email':
                            "${widget.student.name.toLowerCase().replaceAll(' ', '.')}@ontariotechu.net",
                        'name': widget.student.name,
                      },
                      emailjs.Options(
                        publicKey: '3NwU3xKGeU3nLblXw',
                        privateKey: dotenv.env['MY_PRIVATE_KEY'],
                      ),
                    );

                    _subjectController.clear();
                    _bodyController.clear();
                    subject = '';
                    body = '';

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Email sent successfully!')),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AppointmentPage(),
                        ),
                      );
                    }
                  } catch (error) {
                    if (error is emailjs.EmailJSResponseStatus) {
                      print('Status: ${error.status}');
                      print('Error Text: ${error.text}');
                    }
                  }
                },
                child: Text("Send"),
              ),
            ),
        ],
      ),
    );
  }
}
