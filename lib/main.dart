import 'package:a4m/Admin/AdminA4mMembers/a4mMemebersList.dart';
import 'package:a4m/Admin/AdminA4mMembers/ui/memberContainers.dart';
import 'package:a4m/Admin/AdminCertification/adminCertification.dart';
import 'package:a4m/Admin/AdminCourses/adminCourseList.dart';
import 'package:a4m/Admin/AdminMarketing/AdminMarketing.dart';
import 'package:a4m/Admin/ApproveContent/Table/reviewMarksTable.dart';
import 'package:a4m/Admin/ApproveContent/approveContent.dart';
import 'package:a4m/Admin/Commonui/adminMainNavBar.dart';
import 'package:a4m/Admin/Dashboard/adminDashboardMain.dart';
import 'package:a4m/ContentDev/content_dev_landing.dart';
import 'package:a4m/ContentDev/create_course.dart';
import 'package:a4m/LandingPage/CourseListPage/courseListPage.dart';
import 'package:a4m/LandingPage/landingPageMain.dart';
import 'package:a4m/Login/loginPopup.dart';
import 'package:a4m/Student/studentMain.dart';
import 'package:a4m/adminHome.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyAuBnb6FAMGp1Q-1TONFnXr31vlH_BqbM8",
          authDomain: "a-4-m-13d70.firebaseapp.com",
          projectId: "a-4-m-13d70",
          storageBucket: "a-4-m-13d70.firebasestorage.app",
          messagingSenderId: "1000734229320",
          appId: "1:1000734229320:web:f351c28b1be78a632d297d"),
    );
    print("Firebase initialized successfully");
  } catch (e) {
    print("Error initializing Firebase: $e");
  }
  runApp(
    const MaterialApp(
      home: Scaffold(
          body: //StudentMain()
              //ContentDevHome(),
              //CourseListPage()
              LandingPageMain()
          // AdminHome()
          // LoginPopup(),),
          ),
    ),
  );
}
