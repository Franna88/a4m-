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
import 'package:a4m/Lecturers/LectureCourses/Lecture_modules.dart';
import 'package:a4m/Lecturers/LectureCourses/lecture_courses.dart';
import 'package:a4m/Lecturers/LectureCourses/view_modules_complete.dart';
import 'package:a4m/Lecturers/LectureDashboard/lecture_dashboard.dart';
import 'package:a4m/Lecturers/LectureMessages/lecture_messages.dart';
import 'package:a4m/Lecturers/LecturePresentations/lecture_presentations.dart';
import 'package:a4m/Lecturers/LectureStudents/lecture_students.dart';
import 'package:a4m/Lecturers/lecture_navbar.dart';
import 'package:flutter/material.dart';

class LectureHomePage extends StatefulWidget {
  final String lecturerId;

  const LectureHomePage({super.key, required this.lecturerId});

  @override
  State<LectureHomePage> createState() => _LectureHomePageState();
}

class _LectureHomePageState extends State<LectureHomePage> {
  var pageIndex = 0;
  String selectedCourseId = ''; // To store the passed course ID
  String selectedModuleId = ''; // To store the passed module ID

  // Modify changePage to optionally accept a courseId
  void changePage(int value, {String courseId = '', String moduleId = ''}) {
    setState(() {
      pageIndex = value;
      if (courseId.isNotEmpty) {
        selectedCourseId = courseId;
      }
      if (moduleId.isNotEmpty) {
        selectedModuleId = moduleId;
      }
      print(
          "Updated Course ID: $selectedCourseId, Module ID: $selectedModuleId");
    });
  }

  @override
  Widget build(BuildContext context) {
    var pages = [
      LectureDashboard(
        lecturerId: widget.lecturerId,
        changePageWithCourseId: (int newPage, String courseId) {
          changePage(newPage, courseId: courseId); // Pass the courseId
        },
      ),
      LectureCourses(
        changePageWithCourseId: (int newPage, String courseId) {
          changePage(newPage, courseId: courseId); // Pass the courseId
        },
        lecturerId: widget.lecturerId,
      ),
      LectureStudent(),
      LecturePresentations(),
      LectureMessages(),
      ViewModulesComplete(
        courseId: selectedCourseId,
        moduleId: selectedModuleId,
      ),
      LectureModulesContainer(
        changePage: changePage,
        courseId: selectedCourseId, // Use the selected courseId here
      ),
    ];

    return LectureNavbar(
      child: pages[pageIndex],
      changePage: (value) => changePage(value),
    );
  }
}
