import 'package:a4m/Admin/AdminMessaging/adminMessaging.dart';
import 'package:a4m/Admin/AdminMessaging/ui/adminMessagingItems/FacilitatorList/facilitatorList.dart';
import 'package:a4m/Admin/AdminMessaging/ui/adminMessagingItems/LecturerList/LecturerList.dart';
import 'package:a4m/Admin/AdminMessaging/ui/adminMessagingItems/adminInbox.dart';
import 'package:a4m/Admin/AdminMessaging/ui/adminMessagingItems/contentDevList/contentDevList.dart';
import 'package:a4m/Admin/AdminMessaging/ui/adminMessagingItems/importantMessages/adminImportantMessages.dart';
import 'package:a4m/Admin/AdminMessaging/ui/adminMessagingItems/studentList/studentList.dart';
import 'package:a4m/Lecturers/LectureMessages/lecture_message_navbar.dart';
import 'package:flutter/material.dart';

class LectureMessages extends StatefulWidget {
  const LectureMessages({super.key});

  @override
  State<LectureMessages> createState() => _LectureMessagesState();
}

class _LectureMessagesState extends State<LectureMessages> {
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
    return LectureMessageNavbar(
        changePage: changePage, child: pages[pageIndex]);
  }
}
