import 'package:a4m/Admin/AdminMessaging/adminMessaging.dart';
import 'package:a4m/Admin/AdminMessaging/ui/adminMessagingItems/adminInbox.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:a4m/services/messaging_service.dart';
import 'package:a4m/CommonComponents/dialogs/submitUserReportDialog.dart';
import 'package:a4m/myutility.dart';

import 'ui/adminMessagingItems/FacilitatorList/facilitatorList.dart';
import 'ui/adminMessagingItems/LecturerList/LecturerList.dart';
import 'ui/adminMessagingItems/contentDevList/contentDevList.dart';
import 'ui/adminMessagingItems/importantMessages/adminImportantMessages.dart';
import 'ui/adminMessagingItems/studentList/studentList.dart';

class AdminMessagesMain extends StatefulWidget {
  final String? userId; // Optional user ID
  final String?
      userRole; // Optional user role ('student', 'lecturer', 'content_dev', 'facilitator', 'admin')
  final String? initialSelectedUserId;
  final String? initialSelectedUserName;
  final String? initialSelectedUserType;

  const AdminMessagesMain({
    super.key,
    this.userId,
    this.userRole,
    this.initialSelectedUserId,
    this.initialSelectedUserName,
    this.initialSelectedUserType,
  });

  @override
  State<AdminMessagesMain> createState() => _AdminMessagesMainState();
}

class _AdminMessagesMainState extends State<AdminMessagesMain> {
  int pageIndex = 0;
  String? selectedUserId;
  String? selectedUserName;
  String? selectedUserType;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final MessagingService _messagingService = MessagingService();

  @override
  void initState() {
    super.initState();
    // Initialize with provided values if available
    selectedUserId = widget.initialSelectedUserId;
    selectedUserName = widget.initialSelectedUserName;
    selectedUserType = widget.initialSelectedUserType;
  }

  String get currentUserId => widget.userId ?? _auth.currentUser?.uid ?? '';
  String get currentUserRole =>
      widget.userRole ?? 'admin'; // Default to admin if not specified

  void changePage(int index) {
    setState(() {
      pageIndex = index;
      // Only clear selection if no initial values were provided
      if (widget.initialSelectedUserId == null) {
        selectedUserId = null;
        selectedUserName = null;
        selectedUserType = null;
      }
    });
  }

  void handleUserSelected(String userId, String userName, String userType) {
    print('User selected: ID=$userId, Name=$userName, Type=$userType');
    setState(() {
      selectedUserId = userId;
      selectedUserName = userName;
      selectedUserType = userType;
      pageIndex = 0; // Switch to inbox when a user is selected
    });
  }

  // Helper to determine if a user can chat with another role
  bool canChatWith(String otherRole) {
    switch (currentUserRole) {
      case 'student':
        return ['student', 'lecturer', 'admin'].contains(otherRole);
      case 'lecturer':
        return ['student', 'lecturer', 'admin', 'facilitator']
            .contains(otherRole);
      case 'content_dev':
        return ['admin'].contains(otherRole);
      case 'admin':
        return ['student', 'lecturer', 'content_dev', 'facilitator']
            .contains(otherRole);
      case 'facilitator':
        return ['lecturer', 'facilitator', 'admin'].contains(otherRole);
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = currentUserRole == 'admin';
    final List<Widget> pages = [];
    final List<String> pageNames = [];

    print(
        'MESSAGING DEBUG: Building messaging UI for role: $currentUserRole, userID: $currentUserId');

    // All users see inbox
    pages.add(AdminInbox(
      currentUserId: currentUserId,
      messagingService: _messagingService,
      selectedUserName: selectedUserName,
      selectedUserId: selectedUserId,
      selectedUserType: selectedUserType,
    ));
    pageNames.add('Inbox');

    // Important messages only for admin
    if (isAdmin) {
      pages.add(const AdminImportantMessages());
      pageNames.add('Important');
    }

    // Add appropriate user lists based on communication rules
    if (canChatWith('content_dev')) {
      pages.add(ContentDevList(
        onContentDevSelected: handleUserSelected,
      ));
      pageNames.add('Content Devs');
    }

    if (canChatWith('lecturer')) {
      pages.add(LecturerList(
        onLecturerSelected: handleUserSelected,
      ));
      pageNames.add('Lecturers');
    }

    // Only show Students tab if the user is not a student
    if (canChatWith('student') && currentUserRole != 'student') {
      pages.add(StudentList(
        onStudentSelected: handleUserSelected,
        currentUserId: currentUserId,
      ));
      pageNames.add('Students');
    }

    if (canChatWith('facilitator')) {
      pages.add(FacilitatorList(
        onFacilitatorSelected: handleUserSelected,
      ));
      pageNames.add('Facilitators');
    }

    // Ensure pageIndex is valid
    if (pageIndex >= pages.length) {
      pageIndex = 0;
    }

    print('MESSAGING DEBUG: Available pages: $pageNames');

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double navbarWidth = currentUserRole == 'admin' ? 0 : 280;
    final double bottomOffset = currentUserRole == 'admin' ? 0 : 50;

    return SizedBox(
      width: screenWidth - navbarWidth,
      height: screenHeight - bottomOffset,
      child: AdminMessaging(
        changePage: changePage,
        availablePageNames: pageNames,
        currentUserRole: currentUserRole,
        child: pages[pageIndex],
      ),
    );
  }
}
