import 'package:a4m/LandingPage/CourseListPage/ui/categoryNameStack.dart';
import 'package:a4m/Student/ReviewAssessments/ReviewedCourses/ReviewedCoursesList.dart';
import 'package:a4m/Student/assessments/AssessmentList.dart';
import 'package:a4m/Student/assessments/AssessmentTabBar.dart';
import 'package:a4m/Student/commonUi/customTabBar.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';

class Reviewedcourses extends StatefulWidget {
  final void Function(int newPage, String courseId) changePageWithCourseId;
  final String studentId;

  const Reviewedcourses(
      {Key? key, required this.changePageWithCourseId, required this.studentId})
      : super(key: key);

  @override
  State<Reviewedcourses> createState() => _ReviewedcoursesState();
}

class _ReviewedcoursesState extends State<Reviewedcourses> {
  int _selectedIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      Center(
        child: ReviewedCoursesList(
          studentId: widget.studentId,
          onTap: (courseId) {
            widget.changePageWithCourseId(9, courseId);
          },
        ),
      ),
      Center(
        child: Text('Active Page', style: TextStyle(fontSize: 24)),
      ),
      Center(
        child: Text('Completed Page', style: TextStyle(fontSize: 24)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CategoryNameStack(text: 'Reviewed Assessments'),
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
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }
}
