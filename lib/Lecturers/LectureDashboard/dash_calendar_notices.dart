import 'package:a4m/Constants/myColors.dart';
import 'package:a4m/Lecturers/LectureDashboard/dashboard_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class DashCalendarNotices extends StatefulWidget {
  const DashCalendarNotices({super.key});

  @override
  State<DashCalendarNotices> createState() => _DashCalendarNoticesState();
}

class _DashCalendarNoticesState extends State<DashCalendarNotices> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<DateTime, List<Map<String, dynamic>>> _reminders = {};
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final String _userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _initializeNotifications();
    _loadReminders();
  }

  Future<void> _initializeNotifications() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
      },
    );
  }

  Future<void> _loadReminders() async {
    if (_userId.isEmpty) return;

    try {
      final remindersSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(_userId)
          .collection('reminders')
          .get();

      if (remindersSnapshot.docs.isNotEmpty) {
        for (var doc in remindersSnapshot.docs) {
          final data = doc.data();
          final reminderDate = (data['date'] as Timestamp).toDate();
          final normalizedDate = DateTime(
            reminderDate.year,
            reminderDate.month,
            reminderDate.day,
          );

          if (!_reminders.containsKey(normalizedDate)) {
            _reminders[normalizedDate] = [];
          }

          _reminders[normalizedDate]!.add({
            'id': doc.id,
            'title': data['title'],
            'time': data['time'],
            'description': data['description'] ?? '',
          });
        }

        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      print('Error loading reminders: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Calendar & Reminders',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
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
              selectedDecoration: BoxDecoration(
                color: Mycolors().blue,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Mycolors().blue.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              weekendTextStyle: const TextStyle(color: Colors.red),
              outsideTextStyle: TextStyle(color: Colors.grey[400]),
              markerDecoration: BoxDecoration(
                color: Mycolors().green,
                shape: BoxShape.circle,
              ),
              cellMargin: const EdgeInsets.all(4),
            ),
            headerStyle: const HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              titleTextStyle:
                  TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              leftChevronIcon: Icon(Icons.chevron_left, size: 24),
              rightChevronIcon: Icon(Icons.chevron_right, size: 24),
              headerMargin: EdgeInsets.only(bottom: 8),
              headerPadding: EdgeInsets.symmetric(vertical: 4),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (_reminders.containsKey(date)) {
                  return Positioned(
                    bottom: 1,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Mycolors().green,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
            daysOfWeekHeight: 20,
            rowHeight: 35,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Reminders',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle_outline,
                      color: Mycolors().blue, size: 20),
                  onPressed: () => _showAddReminderDialog(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _reminders[_selectedDay]?.isEmpty ?? true
                  ? Center(
                      child: Text(
                        'No reminders for today',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: (_reminders[_selectedDay] ?? []).length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final reminder = _reminders[_selectedDay]![index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          visualDensity: const VisualDensity(vertical: -4),
                          title: Text(
                            reminder['title'],
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          subtitle: Text(
                            reminder['time'],
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                              fontSize: 11,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: Colors.red[400],
                              size: 16,
                            ),
                            onPressed: () => _deleteReminder(reminder['id']),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddReminderDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController timeController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Add Reminder',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: TextStyle(color: Mycolors().blue),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Mycolors().blue),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final TimeOfDay? time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (time != null) {
                      selectedTime = time;
                      timeController.text =
                          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Time',
                      labelStyle: TextStyle(color: Mycolors().blue),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Mycolors().blue),
                      ),
                    ),
                    child: Text(
                      timeController.text.isEmpty
                          ? 'Select Time'
                          : timeController.text,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description (Optional)',
                    labelStyle: TextStyle(color: Mycolors().blue),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Mycolors().blue),
                    ),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    timeController.text.isNotEmpty) {
                  _addReminder(
                    titleController.text,
                    timeController.text,
                    descriptionController.text,
                    selectedTime,
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Mycolors().blue,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                'Add',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addReminder(
    String title,
    String time,
    String description,
    TimeOfDay selectedTime,
  ) async {
    if (_userId.isEmpty) return;

    final DateTime reminderDate = _selectedDay ?? DateTime.now();
    final DateTime reminderDateTime = DateTime(
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    try {
      final docRef = await FirebaseFirestore.instance
          .collection('Users')
          .doc(_userId)
          .collection('reminders')
          .add({
        'title': title,
        'time': time,
        'description': description,
        'date': Timestamp.fromDate(reminderDateTime),
        'createdAt': FieldValue.serverTimestamp(),
      });

      final normalizedDate = DateTime(
        reminderDate.year,
        reminderDate.month,
        reminderDate.day,
      );

      if (!_reminders.containsKey(normalizedDate)) {
        _reminders[normalizedDate] = [];
      }

      _reminders[normalizedDate]!.add({
        'id': docRef.id,
        'title': title,
        'time': time,
        'description': description,
      });

      await _scheduleNotification(
        docRef.id,
        title,
        description,
        reminderDateTime,
      );

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error adding reminder: $e');
    }
  }

  Future<void> _deleteReminder(String reminderId) async {
    if (_userId.isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(_userId)
          .collection('reminders')
          .doc(reminderId)
          .delete();

      for (var date in _reminders.keys) {
        _reminders[date] = _reminders[date]!
            .where((reminder) => reminder['id'] != reminderId)
            .toList();

        if (_reminders[date]!.isEmpty) {
          _reminders.remove(date);
        }
      }

      final notificationId = reminderId.hashCode.abs() % 100000000;
      await flutterLocalNotificationsPlugin.cancel(notificationId);

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error deleting reminder: $e');
    }
  }

  Future<void> _scheduleNotification(
    String id,
    String title,
    String description,
    DateTime scheduledDate,
  ) async {
    final notificationId = id.hashCode.abs() % 100000000;

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'lecturer_reminders',
      'Lecturer Reminders',
      channelDescription: 'Notifications for lecturer reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    final DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      title,
      description.isNotEmpty ? description : 'Reminder for today',
      tz.TZDateTime.from(scheduledDate, tz.local),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
