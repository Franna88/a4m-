import 'package:a4m/LandingPage/CourseListPage/ui/categoryNameStack.dart';
import 'package:a4m/Student/commonUi/customTabBar.dart';
import 'package:a4m/Student/dummyList/allStudentCourses.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';

class MyCoursesMain extends StatefulWidget {
  final void Function(int newPage, String courseId) changePageWithCourseId;
  final String studentId;

  const MyCoursesMain({
    super.key,
    required this.changePageWithCourseId,
    required this.studentId,
  });

  @override
  State<MyCoursesMain> createState() => _MyCoursesMainState();
}

class _MyCoursesMainState extends State<MyCoursesMain> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CategoryNameStack(text: 'My Courses'),
          const SizedBox(height: 15),
          SizedBox(
            height: 50,
            width: 500,
            child: CustomTabBar(
              selectedIndex: _selectedIndex,
              onTabSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
          SizedBox(
            width: MyUtility(context).width - 360,
            height: MyUtility(context).height - 205,
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                // 🔹 All Courses
                AllStudentCourses(
                  studentId: widget.studentId,
                  onCourseTap: (courseId) {
                    widget.changePageWithCourseId(7, courseId);
                  },
                ),
                // 🔹 Active Courses (Incomplete)
                AllStudentCourses(
                  studentId: widget.studentId,
                  filterByCompletion: false, // 🔹 Show only active courses
                  onCourseTap: (courseId) {
                    widget.changePageWithCourseId(7, courseId);
                  },
                ),
                // 🔹 Completed Courses
                AllStudentCourses(
                  studentId: widget.studentId,
                  filterByCompletion: true, // 🔹 Show only completed courses
                  onCourseTap: (courseId) {
                    widget.changePageWithCourseId(7, courseId);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
