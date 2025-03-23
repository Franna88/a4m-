import 'package:a4m/CommonComponents/messaging/messaging_page.dart';
import 'package:a4m/CommonComponents/messaging/simple_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminMessaging extends StatefulWidget {
  const AdminMessaging({Key? key}) : super(key: key);

  @override
  State<AdminMessaging> createState() => _AdminMessagingState();
}

class _AdminMessagingState extends State<AdminMessaging> {
  bool _useSimpleMessaging = true; // Set to true to use the simple version

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? '';

    // Debug print to verify the ID is passed correctly
    print('AdminMessaging: Building with ID $userId');

    // If the ID is empty, show a meaningful error
    if (userId.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Error: You are not logged in',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Please log in to use messaging',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Use simple messaging UI for now to ensure something displays
    return _useSimpleMessaging
        ? SimpleMessagingPage(
            userId: userId,
            userRole: 'admin',
          )
        : MessagingPage(
            userId: userId,
            userRole: 'admin',
          );
  }
}
