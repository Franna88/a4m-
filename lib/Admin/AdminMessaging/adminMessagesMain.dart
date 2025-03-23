import 'package:a4m/CommonComponents/messaging/messaging_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminMessagesMain extends StatefulWidget {
  const AdminMessagesMain({super.key});

  @override
  State<AdminMessagesMain> createState() => _AdminMessagesMainState();
}

class _AdminMessagesMainState extends State<AdminMessagesMain> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? '';

    return MessagingPage(
      userId: userId,
      userRole: 'admin',
    );
  }
}
