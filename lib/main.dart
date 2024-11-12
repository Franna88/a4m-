import 'package:a4m/Admin/AdminA4mMembers/a4mMemebersList.dart';
import 'package:a4m/Admin/AdminA4mMembers/ui/memberContainers.dart';
import 'package:a4m/Admin/AdminCertification/adminCertification.dart';
import 'package:a4m/Admin/AdminCourses/adminCourseList.dart';
import 'package:a4m/Admin/AdminMarketing/AdminMarketing.dart';
import 'package:a4m/Admin/ApproveContent/Table/reviewMarksTable.dart';
import 'package:a4m/Admin/ApproveContent/approveContent.dart';
import 'package:a4m/Admin/Commonui/adminMainNavBar.dart';
import 'package:a4m/Admin/Dashboard/adminDashboardMain.dart';
import 'package:a4m/LandingPage/CourseListPage/courseListPage.dart';
import 'package:a4m/LandingPage/landingPageMain.dart';
import 'package:a4m/Login/loginPopup.dart';
import 'package:a4m/adminHome.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(

      home: //CourseListPage()
      //LandingPageMain()
      AdminHome()
      //LoginPopup(),
    ),
  );
}
