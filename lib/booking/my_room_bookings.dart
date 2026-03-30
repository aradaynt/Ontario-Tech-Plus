import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../student.dart';

class RoomBookingModel {
  final dynamic id;
  final String date;
  final String start;
  final String end;
  final String roomCode;
  final String buildingName;

  RoomBookingModel({
    required this.id,
    required this.date,
    required this.start,
    required this.end,
    required this.roomCode,
    required this.buildingName,
  });

  @override
  String toString() {
    DateFormat inputFormat = DateFormat("HH:mm:ss");
    DateFormat outputFormat = DateFormat("h:mm a");

    String formatTime(String timeString) {
      try {
        DateTime dateTime = inputFormat.parse(timeString);
        return outputFormat.format(dateTime);
      } catch (e) {
        return timeString;
      }
    }

    return '$date: \n${formatTime(start)} - ${formatTime(end)} \n$buildingName - $roomCode';
  }
}

class MyRoomBookingsPage extends StatefulWidget {
  final Student student;
  const MyRoomBookingsPage({super.key, required this.student});

  @override
  State<MyRoomBookingsPage> createState() => _MyRoomBookingsPageState();
}

class _MyRoomBookingsPageState extends State<MyRoomBookingsPage> {
  bool _isLoading = true;
  List<RoomBookingModel> myBookings = [];
  late Student student1 = widget.student;

  Set<dynamic> selectedIds = {};

  @override
  void initState() {
    super.initState();
    fetchMyBookings();
  }

  Future<void> fetchMyBookings() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('booked_rooms')
          .select('''
            id, date, start, end, rooms (room_code, building (name))
          ''')
          .eq('student_id', student1.studentid)
          .order('date', ascending: true);

      final List<RoomBookingModel> fetched = (response as List).map((row) {
        final roomData = row['rooms'];
        final buildingData = roomData != null ? roomData['building'] : null;

        return RoomBookingModel(
          id: row['id'],
          date: row['date'],
          start: row['start'],
          end: row['end'],
          roomCode: roomData != null ? roomData['room_code'] : "Unknown Room",
          buildingName: buildingData != null
              ? buildingData['name']
              : "Unknown Building",
        );
      }).toList();

      if (mounted) {
        setState(() {
          myBookings = fetched;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Room Bookings Fetch Error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteSelected() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Multiple"),
        content: Text(
          "Are you sure you want to cancel ${selectedIds.length} bookings?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("DELETE", style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("CANCEL"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final idsToDelete = selectedIds.toList();

    setState(() {
      myBookings.removeWhere((b) => idsToDelete.contains(b.id));
      selectedIds.clear();
    });

    try {
      await Supabase.instance.client
          .from('booked_rooms')
          .delete()
          .inFilter('id', idsToDelete);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bookings cancelled successfully.")),
        );
      }
    } catch (e) {
      print("Batch delete failed: $e");
      fetchMyBookings();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to cancel some bookings. Please try again."),
          ),
        );
      }
    }
  }

  void _toggleSelection(dynamic id) {
    setState(() {
      if (selectedIds.contains(id)) {
        selectedIds.remove(id);
      } else {
        selectedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMultiSelectMode = selectedIds.isNotEmpty;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("My Room Bookings")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: isMultiSelectMode
          ? AppBar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => selectedIds.clear()),
              ),
              title: Text("${selectedIds.length} Selected"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: _deleteSelected,
                ),
              ],
            )
          : AppBar(title: const Text("My Room Bookings")),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            if (!isMultiSelectMode)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 175,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Swipe to Cancel",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(Icons.arrow_back),
                      ],
                    ),
                  ),
                ),
              ),

            if (myBookings.isEmpty)
              const Expanded(
                child: Center(
                  child: Text("You have no upcoming room bookings."),
                ),
              )
            else
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, right: 8),
                  child: Scrollbar(
                    thumbVisibility: true,
                    thickness: 12,
                    radius: const Radius.circular(10),
                    child: ListView.builder(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 8,
                        bottom: 50,
                      ),
                      itemCount: myBookings.length,
                      itemBuilder: (context, index) {
                        final booking = myBookings[index];
                        final isSelected = selectedIds.contains(booking.id);

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Dismissible(
                            key: Key(booking.id.toString()),
                            direction: isMultiSelectMode
                                ? DismissDirection.none
                                : DismissDirection.endToStart,
                            background: Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              return await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Cancel Booking"),
                                    content: const Text(
                                      "Are you sure you want to cancel this room booking?",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: const Text(
                                          "DELETE",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text("KEEP"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            onDismissed: (direction) async {
                              setState(() {
                                myBookings.removeAt(index);
                              });

                              try {
                                await Supabase.instance.client
                                    .from('booked_rooms')
                                    .delete()
                                    .eq('id', booking.id);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Booking for ${booking.roomCode} cancelled",
                                    ),
                                  ),
                                );
                              } catch (e) {
                                print("Delete failed: $e");
                                fetchMyBookings();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Failed to cancel. Please try again.",
                                    ),
                                  ),
                                );
                              }
                            },
                            child: GestureDetector(
                              onLongPress: () {
                                if (!isMultiSelectMode)
                                  _toggleSelection(booking.id);
                              },
                              onTap: () {
                                if (isMultiSelectMode)
                                  _toggleSelection(booking.id);
                              },
                              child: Card(
                                elevation: 2,
                                color: isSelected
                                    ? Theme.of(
                                        context,
                                      ).colorScheme.secondaryContainer
                                    : null,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: isSelected
                                      ? BorderSide(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          width: 2,
                                        )
                                      : BorderSide.none,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          booking.toString(),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                      if (isMultiSelectMode)
                                        Icon(
                                          isSelected
                                              ? Icons.check_circle
                                              : Icons.radio_button_unchecked,
                                          color: isSelected
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.primary
                                              : Colors.grey,
                                        ),
                                    ],
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
          ],
        ),
      ),
    );
  }
}
