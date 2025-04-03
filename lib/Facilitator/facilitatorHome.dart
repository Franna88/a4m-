import 'package:a4m/Facilitator/Pages/BrowseCourses/facilitatorBrowseCourses.dart';
import 'package:a4m/Facilitator/Pages/Dashboard/facilitatorDashboard.dart';
import 'package:a4m/Facilitator/Pages/MyCourses/facilitatorMyCourses.dart';
import 'package:a4m/Facilitator/Pages/Students/facilitatorStudents.dart';
import 'package:a4m/Facilitator/facilitatorNavBar.dart';
import 'package:a4m/Admin/AdminMessaging/adminMessagesMain.dart';
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
      FacilitatorStudents(),
      AdminMessagesMain(
        userId: widget.facilitatorId,
        userRole: 'facilitator',
      ),
    ];

    return FacilitatorNavBar(
      child: pages[pageIndex],
      changePage: (value) => changePage(value),
    );
  }
}
