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
import 'package:a4m/Lecturers/LectureCourses/lecture_courses.dart';
import 'package:a4m/Lecturers/LectureCourses/view_modules_complete.dart';
import 'package:a4m/Lecturers/LectureDashboard/lecture_dashboard.dart';
import 'package:a4m/Lecturers/LectureMessages/lecture_messages.dart';
import 'package:a4m/Lecturers/LecturePresentations/lecture_presentations.dart';
import 'package:a4m/Lecturers/LectureStudents/lecture_students.dart';
import 'package:a4m/Lecturers/lecture_navbar.dart';
import 'package:flutter/material.dart';

class LectureHomePage extends StatefulWidget {
  const LectureHomePage({super.key});

  @override
  State<LectureHomePage> createState() => _LectureHomePageState();
}

class _LectureHomePageState extends State<LectureHomePage> {
  var pageIndex = 0;

  var pages = [
    LectureDashboard(),
    LectureCourses(),

    LectureStudent(),

    LecturePresentations(),
    LectureMessages(),
    ViewModulesComplete(),
    // Add other pages here
  ];

  void changePage(int value) {
    setState(() {
      pageIndex = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LectureNavbar(
      child: pages[pageIndex],
      changePage: changePage,
    );
  }
}
