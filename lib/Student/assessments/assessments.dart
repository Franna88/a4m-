import 'package:a4m/LandingPage/CourseListPage/ui/categoryNameStack.dart';
import 'package:a4m/Student/assessments/AssessmentList.dart';
import 'package:a4m/Student/assessments/AssessmentTabBar.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';

class AssessmentsMain extends StatefulWidget {
  final void Function(int newPage, String courseId) changePageWithCourseId;
  final String studentId;

  const AssessmentsMain({
    Key? key,
    required this.changePageWithCourseId,
    required this.studentId,
  }) : super(key: key);

  @override
  State<AssessmentsMain> createState() => _AssessmentsMainState();
}

class _AssessmentsMainState extends State<AssessmentsMain> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CategoryNameStack(text: 'Submissions'),
          const SizedBox(height: 15),
          SizedBox(
            height: 50,
            width: 500,
            child: AssessmentTabBar(
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
                AssessmentCourses(
                  studentId: widget.studentId,
                  onTap: (courseId) {
                    widget.changePageWithCourseId(8, courseId);
                  },
                ),
                // 🔹 Active Courses (Incomplete)
                AssessmentCourses(
                  studentId: widget.studentId,
                  filterByCompletion: false, // 🔹 Show only active courses
                  onTap: (courseId) {
                    widget.changePageWithCourseId(8, courseId);
                  },
                ),
                // 🔹 Completed Courses
                AssessmentCourses(
                  studentId: widget.studentId,
                  filterByCompletion: true, // 🔹 Show only completed courses
                  onTap: (courseId) {
                    widget.changePageWithCourseId(8, courseId);
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
