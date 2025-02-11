import 'package:a4m/Student/BrowseCourse/BrowseAvailableContainer.dart';
import 'package:a4m/Student/MyCourses/myCoursesMain.dart';
import 'package:a4m/Student/MyCourses/studentViewCourse.dart';
import 'package:a4m/Student/ReviewAssessments/MarkedAssessment/MarkedAssessment.dart';
import 'package:a4m/Student/ReviewAssessments/ReviewedCourses/RevieweedCourses.dart';
import 'package:a4m/Student/ReviewAssessments/reviewAssessmnts.dart';
import 'package:a4m/Student/StudentCertificates/CertificatesMain.dart';
import 'package:a4m/Student/assessments/SubmitAssessments/SubmitAssessment.dart';
import 'package:a4m/Student/assessments/SubmitModuleAssessments/SubmitModuleAssessments.dart';
import 'package:a4m/Student/assessments/assessments.dart';
import 'package:a4m/Student/commonUi/studentNavBar.dart';
import 'package:flutter/material.dart';

class StudentMain extends StatefulWidget {
  final String studentId;
  const StudentMain({super.key, required this.studentId});

  @override
  State<StudentMain> createState() => _StudentMainState();
}

class _StudentMainState extends State<StudentMain> {
  var pageIndex = 0;
  String selectedCourseId = '';
  String moduleId = '';

  void changePageWithCourseId(int value, String courseId,
      [String moduleId = '']) {
    setState(() {
      pageIndex = value;
      selectedCourseId = courseId;
      this.moduleId = moduleId;
    });
  }

  @override
  Widget build(BuildContext context) {
    var pages = [
      MyCoursesMain(
        changePageWithCourseId: changePageWithCourseId,
        studentId: widget.studentId,
      ),
      BrowseAvailableContainer(),
      AssessmentsMain(
        changePageWithCourseId: changePageWithCourseId,
        studentId: widget.studentId,
      ),
      Reviewedcourses(
        changePageWithCourseId: changePageWithCourseId,
        studentId: widget.studentId,
      ),
      CertificatesMainStudent(),
      SubmitAssessment(
        courseId: selectedCourseId,
        moduleId: moduleId,
        studentId: widget.studentId,
      ),
      MarkedAssessment(
        courseId: selectedCourseId,
        moduleId: moduleId,
        studentId: widget.studentId,
      ),
      StudentViewCourse(
        courseId: selectedCourseId,
      ),
      SubmitModuleAssessments(
        changePageWithCourseId: changePageWithCourseId,
        selectedCourseId: selectedCourseId,
        studentID: widget.studentId,
      ),
      ReviewAssessments(
        changePageWithCourseId: changePageWithCourseId,
        courseId: selectedCourseId,
      ),
    ];

    return StudentNavBar(
      child: pages[pageIndex],
      changePage: (value) => changePageWithCourseId(value, ''),
    );
  }
}
