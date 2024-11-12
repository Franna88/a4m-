import 'package:a4m/Admin/AdminMessaging/adminMessaging.dart';
import 'package:a4m/Admin/AdminMessaging/ui/adminMessagingItems/adminInbox.dart';
import 'package:flutter/material.dart';

import 'ui/adminMessagingItems/FacilitatorList/facilitatorList.dart';
import 'ui/adminMessagingItems/LecturerList/LecturerList.dart';
import 'ui/adminMessagingItems/contentDevList/contentDevList.dart';
import 'ui/adminMessagingItems/importantMessages/adminImportantMessages.dart';
import 'ui/adminMessagingItems/studentList/studentList.dart';

class AdminMessagesMain extends StatefulWidget {
  const AdminMessagesMain({super.key});

  @override
  State<AdminMessagesMain> createState() => _AdminMessagesMainState();
}

class _AdminMessagesMainState extends State<AdminMessagesMain> {
  var pageIndex = 0;

  var pages = [
    AdminInbox(),
    AdminImportantMessages(),
    ContentDevList(),
    LecturerList(),
    StudentList(),
    FacilitatorList(),
  ];

  void changePage(int value) {
    setState(() {
      pageIndex = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminMessaging(changePage: changePage, child: pages[pageIndex]);
  }
}
