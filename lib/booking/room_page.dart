import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../profile/profile_model.dart';

class RoomModel {
  final int id;
  final String roomCode;

  RoomModel({required this.id, required this.roomCode});
}

class GridBooking {
  final int roomId;
  final int startSlotIndex;
  final int durationSlots;
  final String title;
  final bool isClass;

  GridBooking({
    required this.roomId,
    required this.startSlotIndex,
    required this.durationSlots,
    required this.title,
    this.isClass = false,
  });
}

class RoomPage extends StatefulWidget {
  final String buildingName;
  final Profile profile;
  const RoomPage({
    super.key,
    required this.buildingName,
    required this.profile,
  });

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  final double cellWidth = 120.0;
  final double cellHeight = 60.0;
  final double timeColumnWidth = 80.0;
  final double roomHeaderHeight = 50.0;
  final int totalTimeSlots = 28;

  final ScrollController _gridVerticalController = ScrollController();
  final ScrollController _timeVerticalController = ScrollController();
  final ScrollController _gridHorizontalController = ScrollController();
  final ScrollController _roomHeaderHorizontalController = ScrollController();

  bool isLoading = true;
  DateTime selectedDate = DateTime.now();
  List<RoomModel> rooms = [];
  List<GridBooking> activeBookings = [];

  int? selectedRoomId;
  int? startSlotIndex;
  int durationSlots = 1;
  double currentSelectionHeight = 60.0;

  @override
  void initState() {
    super.initState();
    _setupScrollSync();
    _fetchGridData();
  }

  void _setupScrollSync() {
    _gridVerticalController.addListener(() {
      if (_timeVerticalController.hasClients &&
          _timeVerticalController.offset != _gridVerticalController.offset) {
        _timeVerticalController.jumpTo(_gridVerticalController.offset);
      }
    });
    _gridHorizontalController.addListener(() {
      if (_roomHeaderHorizontalController.hasClients &&
          _roomHeaderHorizontalController.offset !=
              _gridHorizontalController.offset) {
        _roomHeaderHorizontalController.jumpTo(
          _gridHorizontalController.offset,
        );
      }
    });
  }

  @override
  void dispose() {
    _gridVerticalController.dispose();
    _timeVerticalController.dispose();
    _gridHorizontalController.dispose();
    _roomHeaderHorizontalController.dispose();
    super.dispose();
  }

  Future<void> _fetchGridData() async {
    setState(() => isLoading = true);
    final supabase = Supabase.instance.client;

    try {
      final roomsResponse = await supabase
          .from('rooms')
          .select('room_id, room_code, building!inner(name)')
          .eq('building.name', widget.buildingName);

      rooms = roomsResponse
          .map(
            (r) => RoomModel(
              id: r['room_id'] as int,
              roomCode: r['room_code'] as String,
            ),
          )
          .toList();

      if (rooms.isEmpty) {
        setState(() => isLoading = false);
        return;
      }

      List<int> roomIds = rooms.map((r) => r.id).toList();
      String dateString = DateFormat('yyyy-MM-dd').format(selectedDate);
      String dayOfWeek = DateFormat('EEEE').format(selectedDate);

      final manualBookings = await supabase
          .from('booked_rooms')
          .select('*')
          .eq('date', dateString)
          .inFilter('room_id', roomIds);

      final classesResponse = await supabase
          .from('course_schedule')
          .select(
            'start_time, end_time, room_id, course_sections(courses(course_name))',
          )
          .eq('day', dayOfWeek)
          .inFilter('room_id', roomIds);

      List<GridBooking> combinedBookings = [];

      for (var b in manualBookings) {
        combinedBookings.add(
          _createGridBooking(
            roomId: b['room_id'],
            startTime: b['start'],
            endTime: b['end'],
            title: 'Student Booking',
            isClass: false,
          ),
        );
      }

      for (var c in classesResponse) {
        String courseName = 'Class';
        try {
          courseName =
              c['course_sections']['courses']['course_name'] ?? 'Class';
        } catch (e) {
          print("Could not parse course name: $e");
        }

        combinedBookings.add(
          _createGridBooking(
            roomId: c['room_id'],
            startTime: c['start_time'],
            endTime: c['end_time'],
            title: courseName,
            isClass: true,
          ),
        );
      }

      setState(() {
        activeBookings = combinedBookings;
        isLoading = false;
        selectedRoomId = null;
        startSlotIndex = null;
      });
    } catch (e) {
      print('Error fetching grid data: $e');
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load schedule')),
        );
      }
    }
  }

  GridBooking _createGridBooking({
    required int roomId,
    required String startTime,
    required String endTime,
    required String title,
    required bool isClass,
  }) {
    int startSlot = _timeToSlotIndex(startTime);
    int endSlot = _timeToSlotIndex(endTime);
    return GridBooking(
      roomId: roomId,
      startSlotIndex: startSlot,
      durationSlots: endSlot - startSlot,
      title: title,
      isClass: isClass,
    );
  }

  int _timeToSlotIndex(String timeString) {
    final parts = timeString.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);
    return ((hour * 60 + minute) - (8 * 60)) ~/ 30;
  }

  String _formatTime(int slotIndex) {
    int hour = 8 + (slotIndex ~/ 2);
    int min = (slotIndex % 2) * 30;
    String period = hour >= 12 ? 'PM' : 'AM';
    if (hour > 12) hour -= 12;
    return '$hour:${min == 0 ? '00' : '30'} $period';
  }

  bool _isSlotBooked(int roomId, int slotIndex) {
    return activeBookings.any(
      (b) =>
          b.roomId == roomId &&
          slotIndex >= b.startSlotIndex &&
          slotIndex < (b.startSlotIndex + b.durationSlots),
    );
  }

  int _getMaxAllowedDuration(int roomId, int startSlot) {
    var upcoming = activeBookings
        .where((b) => b.roomId == roomId && b.startSlotIndex > startSlot)
        .toList();
    if (upcoming.isEmpty) return totalTimeSlots - startSlot;
    upcoming.sort((a, b) => a.startSlotIndex.compareTo(b.startSlotIndex));
    return upcoming.first.startSlotIndex - startSlot;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.buildingName), elevation: 0),
      body: Column(
        children: [
          _buildDateSelector(),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : rooms.isEmpty
                ? const Center(child: Text("No rooms found for this building."))
                : _buildMainGrid(),
          ),

          if (selectedRoomId != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: () => _saveBookingToSupabase(),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: Text(
                    'Confirm Booking (${durationSlots * 30} mins)',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              if (selectedDate.isAfter(
                DateTime.now().subtract(const Duration(days: 1)),
              )) {
                setState(
                  () => selectedDate = selectedDate.subtract(
                    const Duration(days: 1),
                  ),
                );
                _fetchGridData();
              }
            },
          ),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 90)),
                );
                if (picked != null && picked != selectedDate) {
                  setState(() => selectedDate = picked);
                  _fetchGridData();
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_month, size: 20),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        DateFormat('EEEE, MMM dd, yyyy').format(selectedDate),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(
                () => selectedDate = selectedDate.add(const Duration(days: 1)),
              );
              _fetchGridData();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMainGrid() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: timeColumnWidth,
              height: roomHeaderHeight,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300),
                  right: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _roomHeaderHorizontalController,
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: Row(
                  children: rooms
                      .map(
                        (room) => Container(
                          width: cellWidth,
                          height: roomHeaderHeight,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade300),
                              right: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: Text(
                            room.roomCode,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),

        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: timeColumnWidth,
                child: SingleChildScrollView(
                  controller: _timeVerticalController,
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    children: List.generate(
                      totalTimeSlots,
                      (index) => Container(
                        height: cellHeight,
                        alignment: Alignment.topCenter,
                        padding: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(color: Colors.grey.shade300),
                            bottom: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        child: Text(
                          _formatTime(index),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  controller: _gridVerticalController,
                  child: SingleChildScrollView(
                    controller: _gridHorizontalController,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: rooms.length * cellWidth,
                      height: totalTimeSlots * cellHeight,
                      child: Stack(
                        children: [
                          _buildBackgroundGrid(),
                          ...activeBookings.map(
                            (b) => _buildRenderedBooking(b),
                          ),
                          if (selectedRoomId != null && startSlotIndex != null)
                            _buildActiveSelection(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBackgroundGrid() {
    return Row(
      children: rooms.map((room) {
        return Column(
          children: List.generate(totalTimeSlots, (slotIndex) {
            return GestureDetector(
              onTap: () {
                if (_isSlotBooked(room.id, slotIndex)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('This time is unavailable'),
                      duration: Duration(milliseconds: 500),
                    ),
                  );
                  return;
                }
                setState(() {
                  selectedRoomId = room.id;
                  startSlotIndex = slotIndex;
                  durationSlots = 1;
                  currentSelectionHeight = cellHeight;
                });
              },
              child: Container(
                width: cellWidth,
                height: cellHeight,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border(
                    right: BorderSide(color: Colors.grey.shade300),
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
              ),
            );
          }),
        );
      }).toList(),
    );
  }

  Widget _buildRenderedBooking(GridBooking booking) {
    int roomIndex = rooms.indexWhere((r) => r.id == booking.roomId);
    if (roomIndex == -1) return const SizedBox.shrink();

    Color boxColor = booking.isClass
        ? Colors.orange.shade100
        : Colors.red.shade100;
    Color borderColor = booking.isClass ? Colors.orange : Colors.red;

    return Positioned(
      left: roomIndex * cellWidth,
      top: booking.startSlotIndex * cellHeight,
      width: cellWidth,
      height: booking.durationSlots * cellHeight,
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: boxColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            booking.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: borderColor,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveSelection() {
    int roomIndex = rooms.indexWhere((r) => r.id == selectedRoomId);
    return Positioned(
      left: roomIndex * cellWidth,
      top: startSlotIndex! * cellHeight,
      width: cellWidth,
      height: durationSlots * cellHeight,
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(6),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                'New\n${durationSlots * 30} mins',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 20,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  double newHeight = currentSelectionHeight + details.delta.dy;

                  int maxDuration = _getMaxAllowedDuration(
                    selectedRoomId!,
                    startSlotIndex!,
                  );
                  double maxHeight = maxDuration * cellHeight;
                  double minHeight = cellHeight;

                  if (newHeight < minHeight) newHeight = minHeight;
                  if (newHeight > maxHeight) newHeight = maxHeight;

                  int newDuration = (newHeight / cellHeight).round();

                  setState(() {
                    currentSelectionHeight = newHeight;
                    durationSlots = newDuration;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(6),
                      bottomRight: Radius.circular(6),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.drag_handle,
                      size: 16,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveBookingToSupabase() async {
    String startTime = _formatTimeAs24Hour(startSlotIndex!);
    String endTime = _formatTimeAs24Hour(startSlotIndex! + durationSlots);
    String dateString = DateFormat('yyyy-MM-dd').format(selectedDate);

    try {
      await Supabase.instance.client.from('booked_rooms').insert({
        'room_id': selectedRoomId,
        'date': dateString,
        'start': startTime,
        'end': endTime,
        'student_id': int.parse(widget.profile.studentNumber),
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Booking Confirmed!')));
      }
      _fetchGridData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving booking: $e')));
      }
    }
  }

  String _formatTimeAs24Hour(int slotIndex) {
    int hour = 8 + (slotIndex ~/ 2);
    int min = (slotIndex % 2) * 30;
    String hourStr = hour.toString().padLeft(2, '0');
    String minStr = min.toString().padLeft(2, '0');
    return '$hourStr:$minStr:00';
  }
}
