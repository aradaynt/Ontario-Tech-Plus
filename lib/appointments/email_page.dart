import 'package:emailjs/emailjs.dart' as emailjs;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../profile/profile_model.dart';
import '../student.dart';
import 'appointment_landing.dart';

class EmailPage extends StatefulWidget {
  final Instructor? instructor;
  final Advisor? advisor;
  final Profile profile;
  final Dates date;
  final String? week;

  const EmailPage({
    super.key,
    this.instructor,
    this.advisor,
    required this.profile,
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
  late String? instructorEmail = widget.instructor?.email;

  @override
  void initState() {
    super.initState();
    _loadFile();
  }

  Future<void> _loadFile() async {
    await dotenv.load(fileName: ".env");
    if (mounted) setState(() {});
  }

  String formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m:00';
  }

  String _formatDateForSupabase(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';

    try {
      final cleanStr = dateStr.replaceAll(',', '');
      final parts = cleanStr.split(' ');

      if (parts.length < 3) return dateStr;

      const months = {
        'January': '01',
        'February': '02',
        'March': '03',
        'April': '04',
        'May': '05',
        'June': '06',
        'July': '07',
        'August': '08',
        'September': '09',
        'October': '10',
        'November': '11',
        'December': '12',
      };

      final month = months[parts[0]] ?? '01';
      final day = parts[1].padLeft(2, '0');
      final year = parts[2];

      return '$year-$month-$day';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text("Reason for Appointment")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.only(left: 30),
            child: Text(
              "Please explain the purpose of your appointment.",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
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
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 2.0,
                      ),
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
            padding: const EdgeInsets.all(16),
            child: Card(
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
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 2.0,
                      ),
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
          if (subject.isNotEmpty && body.isNotEmpty)
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    final supabase = Supabase.instance.client;

                    final isAdvisor = widget.advisor != null;

                    final targetId = isAdvisor
                        ? widget.advisor!.id
                        : widget.instructor!.id;

                    final targetEmail = isAdvisor
                        ? widget.advisor!.email
                        : widget.instructor!.email == 'Unknown Email' ||
                              widget.instructor!.email == 'No Email Provided'
                        ? '${widget.instructor?.name.split(' ').first.toLowerCase()}@ontariotechu.net'
                        : widget.instructor!.email;

                    final targetTable = isAdvisor ? 'advisor_booked' : 'booked';
                    final targetColumn = isAdvisor ? 'advisor_id' : 'prof_id';

                    await supabase.from(targetTable).insert({
                      targetColumn: targetId,
                      'student_id': int.parse(widget.profile.studentNumber),
                      'start': formatTime(widget.date.start),
                      'end': formatTime(widget.date.end),
                      'date': _formatDateForSupabase(widget.week),
                    });

                    String courseLine = widget.date.courseCode != null
                        ? "Course: ${widget.date.courseCode}\n"
                        : "";

                    await emailjs.send(
                      'service_6znzzht',
                      'template_89bpfms',
                      {
                        'email': targetEmail,
                        'subject': subject,
                        'message':
                            "${courseLine}Appointment for: \n${widget.week}\n${widget.date.toString()}\nReason for this appointment is: \n$body",
                        'user_email': widget.profile.email,
                        'name': widget.profile.fullName,
                      },
                      emailjs.Options(
                        publicKey: '3NwU3xKGeU3nLblXw',
                        privateKey: dotenv.env['MY_PRIVATE_KEY'],
                      ),
                    );

                    _subjectController.clear();
                    _bodyController.clear();
                    setState(() {
                      subject = '';
                      body = '';
                    });

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Email sent and appointment booked!'),
                        ),
                      );
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AppointmentTypePage(),
                        ),
                        (route) => route.isFirst,
                      );
                    }
                  } catch (error) {
                    print("Error booking appointment: $error");
                    if (error is emailjs.EmailJSResponseStatus) {
                      print('Email Status: ${error.status}');
                      print('Email Error Text: ${error.text}');
                    }
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to book appointment: $error'),
                        ),
                      );
                    }
                  }
                },
                child: const Text("Send"),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }
}
