import 'package:a4m/Lecturers/LectureCourses/Lecture_modules.dart';
import 'package:a4m/Lecturers/LectureCourses/lecture_courses.dart';
import 'package:a4m/Lecturers/LectureCourses/view_modules_complete.dart';
import 'package:a4m/Lecturers/LectureDashboard/lecture_dashboard.dart';
import 'package:a4m/Lecturers/LectureMessages/lecture_messages.dart';
import 'package:a4m/Lecturers/LecturePresentations/lecture_presentations.dart';
import 'package:a4m/Lecturers/LectureStudents/lecture_students.dart';
import 'package:a4m/Lecturers/lecture_navbar.dart';
import 'package:a4m/Lecturers/LectureCourses/assessment_submissions_view.dart';
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

  @override
  void initState() {
    super.initState();
    assert(widget.lecturerId.isNotEmpty, 'Lecturer ID must not be empty');
    print(
        'Initializing LectureHomePage with lecturer ID: ${widget.lecturerId}');
  }

  // Updated changePage to use named parameters consistently
  void changePage(int value, {String courseId = '', String moduleId = ''}) {
    print(
        "changePage called with value: $value, courseId: $courseId, moduleId: $moduleId");

    if (value < 0 || value >= getPages().length) {
      print('Invalid page index: $value');
      return;
    }

    setState(() {
      pageIndex = value;
      if (courseId.isNotEmpty) {
        selectedCourseId = courseId;
        print("Updated selectedCourseId to: $selectedCourseId");
      }
      if (moduleId.isNotEmpty) {
        selectedModuleId = moduleId;
        print("Updated selectedModuleId to: $selectedModuleId");
      }
      print(
          "Navigation - Page: $value, Course ID: $selectedCourseId, Module ID: $selectedModuleId");
    });
  }

  List<Widget> getPages() {
    print(
        "Building pages with Course ID: $selectedCourseId, Module ID: $selectedModuleId");
    return [
      LectureDashboard(
        lecturerId: widget.lecturerId,
        changePageWithCourseId: (page,
            {String courseId = '', String moduleId = ''}) {
          changePage(page, courseId: courseId, moduleId: moduleId);
        },
      ),
      LectureCourses(
        changePageWithCourseId: (int newPage,
            {String courseId = '', String moduleId = ''}) {
          print(
              "LectureCourses navigation - Page: $newPage, Course ID: $courseId");
          changePage(newPage, courseId: courseId, moduleId: moduleId);
        },
        lecturerId: widget.lecturerId,
      ),
      LectureStudent(
        lecturerId: widget.lecturerId,
        changePage: changePage,
      ),
      LecturePresentations(),
      LectureMessages(),
      ViewModulesComplete(
        courseId: selectedCourseId,
        moduleId: selectedModuleId,
      ),
      LectureModulesContainer(
        changePage: changePage,
        courseId: selectedCourseId,
      ),
      AssessmentSubmissionsView(
        courseId: selectedCourseId,
        moduleId: selectedModuleId,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return LectureNavbar(
      child: getPages()[pageIndex],
      changePage: (value) => changePage(value),
    );
  }
}
