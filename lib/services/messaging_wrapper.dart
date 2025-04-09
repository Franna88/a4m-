import 'package:a4m/Admin/AdminMessaging/adminMessagesMain.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessagingWrapper extends StatefulWidget {
  final String
      userRole; // 'student', 'lecturer', 'contentDev', 'facilitator', 'admin'
  final String userId;

  const MessagingWrapper({
    super.key,
    required this.userRole,
    required this.userId,
  });

  @override
  State<MessagingWrapper> createState() => _MessagingWrapperState();
}

class _MessagingWrapperState extends State<MessagingWrapper> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  String _normalizedRole = '';

  @override
  void initState() {
    super.initState();
    _setupUserRole();
  }

  Future<void> _setupUserRole() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Map userRole to the naming format expected by the messaging system
      // The messaging system expects: 'student', 'lecturer', 'content_dev', 'facilitator', 'admin'
      // But Firestore might store them as 'student', 'lecturer', 'contentDev', etc.
      _normalizedRole = _normalizeUserRole(widget.userRole);

      // Log for debugging
      print(
          "Initializing messaging for $_normalizedRole with ID: ${widget.userId}");
    } catch (e) {
      print("Error setting up user role: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper to normalize role names
  String _normalizeUserRole(String role) {
    switch (role.toLowerCase()) {
      case 'student':
        return 'student';
      case 'lecturer':
        return 'lecturer';
      case 'contentdev':
        return 'content_dev';
      case 'content_dev':
        return 'content_dev';
      case 'facilitator':
        return 'facilitator';
      case 'admin':
        return 'admin';
      default:
        return 'student'; // Default fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Pass the normalized role to the messaging system
    return AdminMessagesMain(
      userId: widget.userId,
      userRole: _normalizedRole,
    );
  }
}

// Extension methods to help with allowed communications
extension CommunicationRules on String {
  bool canCommunicateWith(String otherRole) {
    // Normalize the otherRole first
    final normalizedOtherRole = _normalizeRoleForComm(otherRole);

    // Define who can talk to whom based on the list provided
    switch (this) {
      case 'student':
        return ['student', 'lecturer', 'admin'].contains(normalizedOtherRole);
      case 'lecturer':
        return ['student', 'lecturer', 'admin', 'facilitator', 'content_dev']
            .contains(normalizedOtherRole);
      case 'content_dev':
        return ['admin', 'lecturer'].contains(normalizedOtherRole);
      case 'admin':
        return ['student', 'lecturer', 'content_dev', 'facilitator']
            .contains(normalizedOtherRole);
      case 'facilitator':
        return ['lecturer', 'facilitator', 'admin']
            .contains(normalizedOtherRole);
      default:
        return false;
    }
  }

  // Helper to normalize role names for communication rules
  String _normalizeRoleForComm(String role) {
    switch (role.toLowerCase()) {
      case 'student':
        return 'student';
      case 'lecturer':
        return 'lecturer';
      case 'contentdev':
        return 'content_dev';
      case 'content_dev':
        return 'content_dev';
      case 'facilitator':
        return 'facilitator';
      case 'admin':
        return 'admin';
      default:
        return role; // Just return the role if none of these match
    }
  }
}
