import 'package:a4m/Student/MyCourses/myCoursesMain.dart';
import 'package:a4m/Student/MyCourses/studentViewCourse.dart';
import 'package:a4m/Student/ReviewAssessments/reviewAssessmnts.dart';
import 'package:a4m/Student/assessments/assessments.dart';
import 'package:a4m/Student/commonUi/studentNavBar.dart';
import 'package:flutter/material.dart';

class StudentMain extends StatefulWidget {
  const StudentMain({super.key});

  @override
  State<StudentMain> createState() => _StudentMainState();
}

class _StudentMainState extends State<StudentMain> {
  var pageIndex = 0;

  void changePage(int value) {
    setState(() {
      pageIndex = value;
    });
  }

  List<Widget> pages = [
    StudentViewCourse(),
    MyCoursesMain(),
    AssessmentsMain(),
    ReviewAssessments()
  ];

  @override
  Widget build(BuildContext context) {
    return StudentNavBar(child: pages[pageIndex], changePage: changePage);
  }
}
