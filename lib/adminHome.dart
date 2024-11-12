import 'package:a4m/Admin/AdminA4mMembers/a4mMemebersList.dart';
import 'package:a4m/Admin/AdminCertification/adminCertification.dart';
import 'package:a4m/Admin/AdminCourses/adminCourseList.dart';
import 'package:a4m/Admin/AdminMarketing/AdminMarketing.dart';
import 'package:a4m/Admin/AdminMessaging/adminMessagesMain.dart';

import 'package:a4m/Admin/ApproveContent/approveContent.dart';
import 'package:a4m/Admin/Commonui/adminMainNavBar.dart';
import 'package:a4m/Admin/ComplaintsSuggestions/compSuggestionsMain.dart';
import 'package:a4m/Admin/CurriculumVitae/cirriculumVitae.dart';
import 'package:a4m/Admin/Dashboard/adminDashboardMain.dart';
import 'package:flutter/material.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  var pageIndex = 0;

  var pages = [
    AdminDashboardMain(),
    AdminCourseList(),
    AdminMarketing(),
    A4mMembersList(),
    AdminCertification(),
    ApproveContent(),

    CompSuggestionsMain(),
    AdminMessagesMain(),
    CirriculumVitae(),

    // Add other pages here
  ];

  void changePage(int value) {
    setState(() {
      pageIndex = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminMainNavBar(
      child: pages[pageIndex],
      changePage: changePage,
    );
  }
}
