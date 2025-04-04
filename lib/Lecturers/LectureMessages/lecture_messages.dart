import 'package:a4m/Admin/AdminMessaging/adminMessagesMain.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:a4m/services/messaging_service.dart';

class LectureMessages extends StatefulWidget {
  const LectureMessages({super.key});

  @override
  State<LectureMessages> createState() => _LectureMessagesState();
}

class _LectureMessagesState extends State<LectureMessages> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final MessagingService _messagingService = MessagingService();

  @override
  Widget build(BuildContext context) {
    // Use the authenticated user ID for the lecturer
    final String lecturerId = _auth.currentUser?.uid ?? '';

    if (lecturerId.isEmpty) {
      return const Center(
        child: Text('You must be logged in to view messages.'),
      );
    }

    // Get selected chat information from the messaging service
    final selectedChatId = _messagingService.selectedChatId;
    final selectedOtherUserId = _messagingService.selectedOtherUserId;
    final selectedOtherUserName = _messagingService.selectedOtherUserName;
    final selectedUserType = _messagingService.selectedUserType;

    return AdminMessagesMain(
      userId: lecturerId,
      userRole: 'lecturer',
      initialSelectedUserId: selectedOtherUserId,
      initialSelectedUserName: selectedOtherUserName,
      initialSelectedUserType: selectedUserType,
    );
  }
}
