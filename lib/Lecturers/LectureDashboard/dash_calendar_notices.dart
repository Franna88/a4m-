import 'package:a4m/Constants/myColors.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';

class DashCalendarNotices extends StatefulWidget {
  const DashCalendarNotices({Key? key}) : super(key: key);

  @override
  State<DashCalendarNotices> createState() => _DashCalendarNoticesState();
}

class _DashCalendarNoticesState extends State<DashCalendarNotices> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<DateTime, List<Map<String, dynamic>>> _reminders = {};

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: CalendarStyle(
              selectedDecoration:
                  BoxDecoration(color: Mycolors().blue, shape: BoxShape.circle),
              todayDecoration: BoxDecoration(
                  color: Mycolors().blue.withOpacity(0.5),
                  shape: BoxShape.circle),
            ),
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Divider(
              thickness: 5,
              color: Mycolors().offWhite,
            ),
          ),
          Row(
            children: [
              Spacer(),
              const Text(
                'Today\'s Reminders',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              Spacer(),
              IconButton(
                icon: const Icon(Icons.add, size: 30),
                onPressed: () => _showAddReminderDialog(context),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              children: (_reminders[_selectedDay] ?? []).map((reminder) {
                return ListTile(
                  title: Text(reminder['title']),
                  subtitle: Text(reminder['time']),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddReminderDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Reminder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(color: Colors.black),
                ),
              ),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(
                  labelText: 'Time (e.g., 10:00 AM)',
                  labelStyle: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300], // Button color
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _addReminder(titleController.text, timeController.text);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Mycolors().blue,
              ),
              child: const Text(
                'Add',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _addReminder(String title, String time) {
    final DateTime reminderDate = _selectedDay ?? DateTime.now();
    if (title.isNotEmpty && time.isNotEmpty) {
      setState(() {
        _reminders[reminderDate] ??= [];
        _reminders[reminderDate]!.add({'title': title, 'time': time});
      });
    }
  }
}
