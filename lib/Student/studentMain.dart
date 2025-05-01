import 'package:a4m/Admin/AdminMessaging/adminMessagesMain.dart';
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
import 'package:a4m/Student/ReviewAssessments/CourseEvaluation/CourseEvaluationPage.dart';
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
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _initializePages();
  }

  void _initializePages() {
    _pages = [
      MyCoursesMain(
        changePageWithCourseId: changePageWithCourseId,
        studentId: widget.studentId,
      ), // 0
      BrowseAvailableContainer(
        studentId: widget.studentId,
      ), // 1
      AssessmentsMain(
        changePageWithCourseId: changePageWithCourseId,
        studentId: widget.studentId,
      ), // 2
      Reviewedcourses(
        changePageWithCourseId: changePageWithCourseId,
        studentId: widget.studentId,
      ), // 3 - Results
      CertificatesMainStudent(), // 4
      SubmitAssessment(
        courseId: selectedCourseId,
        moduleId: moduleId,
        studentId: widget.studentId,
      ), // 5
      MarkedAssessment(
        courseId: selectedCourseId,
        moduleId: moduleId,
        studentId: widget.studentId,
      ), // 6
      StudentViewCourse(
        courseId: selectedCourseId,
      ), // 7 - Course Module View
      SubmitModuleAssessments(
        changePageWithCourseId: changePageWithCourseId,
        selectedCourseId: selectedCourseId,
        studentID: widget.studentId,
      ), // 8
      AdminMessagesMain(
        userId: widget.studentId,
        userRole: 'student',
      ), // 9 - Messages
      ReviewAssessments(
        changePageWithCourseId: changePageWithCourseId,
        courseId: selectedCourseId,
      ), // 10 - Review Assessments
      const CourseEvaluationPage(), // 11 - Course Evaluation
    ];
  }

  void changePageWithCourseId(int value, String courseId,
      [String moduleId = '']) {
    setState(() {
      pageIndex = value;
      selectedCourseId = courseId;
      this.moduleId = moduleId;
      // Update pages that depend on courseId and moduleId
      _updateDynamicPages();
    });
  }

  void _updateDynamicPages() {
    // Update only the pages that depend on courseId and moduleId
    _pages[5] = SubmitAssessment(
      courseId: selectedCourseId,
      moduleId: moduleId,
      studentId: widget.studentId,
    );
    _pages[6] = MarkedAssessment(
      courseId: selectedCourseId,
      moduleId: moduleId,
      studentId: widget.studentId,
    );
    _pages[7] = StudentViewCourse(
      courseId: selectedCourseId,
    );
    _pages[8] = SubmitModuleAssessments(
      changePageWithCourseId: changePageWithCourseId,
      selectedCourseId: selectedCourseId,
      studentID: widget.studentId,
    );
    _pages[10] = ReviewAssessments(
      changePageWithCourseId: changePageWithCourseId,
      courseId: selectedCourseId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StudentNavBar(
      changePage: (value) => changePageWithCourseId(value, ''),
      initialIndex: pageIndex,
      child: _pages[pageIndex],
    );
  }
}
