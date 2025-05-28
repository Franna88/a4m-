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
import 'package:intl/intl.dart';

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
  bool _isLoading = true;

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
    setState(() {
      _isLoading = true;
    });

    if (_userId.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final remindersSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(_userId)
          .collection('reminders')
          .get();

      final Map<DateTime, List<Map<String, dynamic>>> newReminders = {};

      if (remindersSnapshot.docs.isNotEmpty) {
        for (var doc in remindersSnapshot.docs) {
          final data = doc.data();
          final reminderDate = (data['date'] as Timestamp).toDate();
          final normalizedDate = DateTime(
            reminderDate.year,
            reminderDate.month,
            reminderDate.day,
          );

          if (!newReminders.containsKey(normalizedDate)) {
            newReminders[normalizedDate] = [];
          }

          newReminders[normalizedDate]!.add({
            'id': doc.id,
            'title': data['title'],
            'time': data['time'],
            'description': data['description'] ?? '',
            'date': reminderDate,
          });
        }
      }

      if (mounted) {
        setState(() {
          _reminders.clear();
          _reminders.addAll(newReminders);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading reminders: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _getTodaysReminders() {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    return _reminders[today] ?? [];
  }

  List<Map<String, dynamic>> _getSelectedDayReminders() {
    if (_selectedDay == null) return [];

    final selectedDayNormalized = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );

    return _reminders[selectedDayNormalized] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final todaysReminders = _getTodaysReminders();
    final selectedDayReminders = _getSelectedDayReminders();
    final bool isTodaySelected = _selectedDay != null &&
        _selectedDay!.year == DateTime.now().year &&
        _selectedDay!.month == DateTime.now().month &&
        _selectedDay!.day == DateTime.now().day;

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
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Calendar header with title and action button
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Calendar & Reminders',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_circle, color: Mycolors().blue),
                        onPressed: () => _showAddReminderDialog(context),
                        tooltip: 'Add Reminder',
                      ),
                    ],
                  ),
                ),
                // Calendar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: TableCalendar(
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
                      cellMargin: const EdgeInsets.all(2),
                    ),
                    headerStyle: HeaderStyle(
                      titleCentered: true,
                      formatButtonVisible: false,
                      titleTextStyle: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                      leftChevronIcon: Icon(Icons.chevron_left,
                          size: 24, color: Mycolors().blue),
                      rightChevronIcon: Icon(Icons.chevron_right,
                          size: 24, color: Mycolors().blue),
                      headerMargin: const EdgeInsets.only(bottom: 4),
                      headerPadding: const EdgeInsets.symmetric(vertical: 6),
                    ),
                    eventLoader: (day) {
                      final normalizedDay =
                          DateTime(day.year, day.month, day.day);
                      return _reminders[normalizedDay] ?? [];
                    },
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, date, events) {
                        if (events.isNotEmpty) {
                          return Positioned(
                            bottom: 1,
                            right: 1,
                            child: Container(
                              width: 8,
                              height: 8,
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
                    daysOfWeekHeight: 14,
                    rowHeight: 28,
                  ),
                ),

                // Divider between calendar and reminders sections
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Divider(color: Colors.grey.shade300),
                ),

                // Selected date header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDay != null
                            ? DateFormat('MMMM d, yyyy').format(_selectedDay!)
                            : DateFormat('MMMM d, yyyy').format(DateTime.now()),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Mycolors().blue,
                        ),
                      ),
                      if (_selectedDay != null)
                        TextButton.icon(
                          icon: Icon(Icons.add,
                              size: 18, color: Mycolors().green),
                          label: Text(
                            'Add Reminder',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Mycolors().green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () => _showAddReminderDialog(context),
                        ),
                    ],
                  ),
                ),

                // Reminders list for selected day
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: selectedDayReminders.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.event_note,
                                  size: 32,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No reminders for ${_selectedDay != null ? DateFormat('MMM d').format(_selectedDay!) : "today"}',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: selectedDayReminders.length,
                            separatorBuilder: (context, index) =>
                                Divider(color: Colors.grey[200], height: 1),
                            itemBuilder: (context, index) {
                              final reminder = selectedDayReminders[index];
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 8),
                                dense: true,
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Mycolors().blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.notifications_active,
                                    color: Mycolors().blue,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  reminder['title'],
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      reminder['time'],
                                      style: GoogleFonts.poppins(
                                        color: Mycolors().blue,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (reminder['description'] != null &&
                                        reminder['description'].isNotEmpty)
                                      Text(
                                        reminder['description'],
                                        style: GoogleFonts.poppins(
                                          color: Colors.grey[600],
                                          fontSize: 11,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: Colors.red[400],
                                    size: 20,
                                  ),
                                  onPressed: () =>
                                      _deleteReminder(reminder['id']),
                                ),
                              );
                            },
                          ),
                  ),
                ),

                // Today's Reminders section (only shown if there are today's reminders and not viewing today)
                if (todaysReminders.isNotEmpty && !isTodaySelected) ...[
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Divider(color: Colors.grey.shade300),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Text(
                      "Today's Reminders",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Mycolors().green,
                      ),
                    ),
                  ),
                  Container(
                    height: 80,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: todaysReminders.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final reminder = todaysReminders[index];
                        return Container(
                          width: 160,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Mycolors().green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Mycolors().green.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                reminder['title'],
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: Colors.grey[800],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                reminder['time'],
                                style: GoogleFonts.poppins(
                                  color: Mycolors().green,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
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
        return StatefulBuilder(
          builder: (context, setState) {
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
                    Text(
                      'Date: ${_selectedDay != null ? DateFormat('MMM d, yyyy').format(_selectedDay!) : DateFormat('MMM d, yyyy').format(DateTime.now())}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'ReminderTitle',
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
                          setState(() {
                            selectedTime = time;
                            timeController.text =
                                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                          });
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
                        labelText: 'Reminder Description',
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
        'createdBy': _userId,
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
        'date': reminderDateTime,
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

      final List<DateTime> keysToCheck = List<DateTime>.from(_reminders.keys);
      for (var date in keysToCheck) {
        final updatedReminders = _reminders[date]!
            .where((reminder) => reminder['id'] != reminderId)
            .toList();

        if (updatedReminders.isEmpty) {
          _reminders.remove(date);
        } else {
          _reminders[date] = updatedReminders;
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
