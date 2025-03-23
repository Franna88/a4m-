import 'package:a4m/Admin/AdminMessaging/adminMessagesMain.dart';
import 'package:a4m/Facilitator/Pages/BrowseCourses/facilitatorBrowseCourses.dart';
import 'package:a4m/Facilitator/Pages/Dashboard/facilitatorDashboard.dart';
import 'package:a4m/Facilitator/Pages/Messaging/facilitatorMessaging.dart';
import 'package:a4m/Facilitator/Pages/MyCourses/facilitatorMyCourses.dart';
import 'package:a4m/Facilitator/Pages/Students/facilitatorStudents.dart';
import 'package:a4m/Facilitator/facilitatorNavBar.dart';
import 'package:a4m/Lecturers/LectureCourses/Lecture_modules.dart';
import 'package:a4m/Lecturers/LectureCourses/lecture_courses.dart';
import 'package:a4m/Lecturers/LectureCourses/view_modules_complete.dart';
import 'package:a4m/Lecturers/LectureDashboard/lecture_dashboard.dart';
import 'package:a4m/Lecturers/LectureMessages/lecture_messages.dart';
import 'package:a4m/Lecturers/LecturePresentations/lecture_presentations.dart';
import 'package:a4m/Lecturers/LectureStudents/lecture_students.dart';
import 'package:a4m/Lecturers/lecture_navbar.dart';
import 'package:flutter/material.dart';

class FacilitatorHome extends StatefulWidget {
  final String facilitatorId;
  const FacilitatorHome({
    super.key,
    required this.facilitatorId,
  });

  @override
  State<FacilitatorHome> createState() => _FacilitatorHomeState();
}

class _FacilitatorHomeState extends State<FacilitatorHome> {
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
      FacilitatorDashboard(
        facilitatorId: widget.facilitatorId,
      ),
      FacilitatorMyCourses(
        facilitatorId: widget.facilitatorId,
      ),
      FacilitatorBrowseCourses(
        facilitatorId: widget.facilitatorId,
      ),
      FacilitatorStudents(
        facilitatorId: widget.facilitatorId,
      ),
      const LecturePresentations(),
      FacilitatorMessaging(facilitatorId: widget.facilitatorId),
    ];

    return FacilitatorNavBar(
      child: pages[pageIndex],
      changePage: (value) => changePage(value),
    );
  }
}
