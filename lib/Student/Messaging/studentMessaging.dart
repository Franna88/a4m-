import 'package:a4m/CommonComponents/messaging/messaging_page.dart';
import 'package:a4m/CommonComponents/messaging/simple_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentMessaging extends StatefulWidget {
  final String studentId;

  const StudentMessaging({
    Key? key,
    required this.studentId,
  }) : super(key: key);

  @override
  State<StudentMessaging> createState() => _StudentMessagingState();
}

class _StudentMessagingState extends State<StudentMessaging> {
  bool _useSimpleMessaging = true; // Set to true to use the simple version

  @override
  Widget build(BuildContext context) {
    // Debug print to verify the ID is passed correctly
    print('StudentMessaging: Building with ID ${widget.studentId}');

    // If the ID is empty, show a meaningful error
    if (widget.studentId.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Error: Missing student ID',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Please log in again to fix this issue',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Use simple messaging UI for now to ensure something displays
    return _useSimpleMessaging
        ? SimpleMessagingPage(
            userId: widget.studentId,
            userRole: 'student',
          )
        : MessagingPage(
            userId: widget.studentId,
            userRole: 'student',
          );
  }
}
