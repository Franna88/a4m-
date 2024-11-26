import 'package:a4m/Admin/AdminMessaging/adminMessaging.dart';
import 'package:a4m/Admin/AdminMessaging/ui/adminMessagingItems/FacilitatorList/facilitatorList.dart';
import 'package:a4m/Admin/AdminMessaging/ui/adminMessagingItems/LecturerList/LecturerList.dart';
import 'package:a4m/Admin/AdminMessaging/ui/adminMessagingItems/adminInbox.dart';
import 'package:a4m/Admin/AdminMessaging/ui/adminMessagingItems/contentDevList/contentDevList.dart';
import 'package:a4m/Admin/AdminMessaging/ui/adminMessagingItems/importantMessages/adminImportantMessages.dart';
import 'package:a4m/Admin/AdminMessaging/ui/adminMessagingItems/studentList/studentList.dart';
import 'package:a4m/ContentDev/ContentDevMessages/content_dev_navbar_buttons.dart';
import 'package:flutter/material.dart';

class ContentDevMessages extends StatefulWidget {
  const ContentDevMessages({super.key});

  @override
  State<ContentDevMessages> createState() => _ContentDevMessagesState();
}

class _ContentDevMessagesState extends State<ContentDevMessages> {
  var pageIndex = 0;

  var pages = [
    AdminInbox(),
    AdminImportantMessages(),
    LecturerList(),
  ];

  void changePage(int value) {
    setState(() {
      pageIndex = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ContentDevNavbarButtons(
        changePage: changePage, child: pages[pageIndex]);
  }
}
