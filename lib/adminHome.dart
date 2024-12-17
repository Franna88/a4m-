import 'package:a4m/Admin/AdminA4mMembers/a4mMemebersList.dart';
import 'package:a4m/Admin/AdminCertification/adminCertification.dart';
import 'package:a4m/Admin/AdminCourses/adminCourseList.dart';
import 'package:a4m/Admin/AdminMarketing/AdminMarketing.dart';
import 'package:a4m/Admin/AdminMessaging/adminMessagesMain.dart';
import 'package:a4m/Admin/ApproveContent/ReviewContent.dart/ReviewCourse.dart';
import 'package:a4m/Admin/ApproveContent/ReviewContent.dart/ReviewModule.dart';
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
  Map<String, dynamic>? pageData; // Store the data to be passed to the page

  // Updated changePage function to accept an optional data argument
  void changePage(int value, [Map<String, dynamic>? data]) {
    setState(() {
      pageIndex = value;
      pageData = data;

      // Debugging statement to track courseId
      if (data != null && data.containsKey('courseId')) {
        print('AdminHome: Received courseId ${data['courseId']}');
      } else {
        print('AdminHome: No courseId provided');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      AdminDashboardMain(),
      AdminCourseList(),
      AdminMarketing(),
      A4mMembersList(),
      AdminCertification(),
      ApproveContent(
        changePage: changePage,
      ),
      CompSuggestionsMain(),
      AdminMessagesMain(),
      CirriculumVitae(),
      ReviewCourse(
        changePageIndex: changePage,
        courseId: pageData != null && pageData!.containsKey('courseId')
            ? pageData!['courseId']
            : '',
      ),
      ReviewModule(
        changePageIndex: changePage,
        courseId: pageData != null && pageData!.containsKey('courseId')
            ? pageData!['courseId']
            : '',
      ),
    ];

    return AdminMainNavBar(
      child: pages[pageIndex],
      changePage: changePage,
    );
  }
}
