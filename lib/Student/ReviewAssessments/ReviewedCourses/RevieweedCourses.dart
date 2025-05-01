import 'package:a4m/LandingPage/CourseListPage/ui/categoryNameStack.dart';
import 'package:a4m/Student/ReviewAssessments/ReviewedCourses/ReviewedCoursesList.dart';
import 'package:a4m/Student/assessments/AssessmentList.dart';
import 'package:a4m/Student/assessments/AssessmentTabBar.dart';
import 'package:a4m/Student/commonUi/customTabBar.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Reviewedcourses extends StatefulWidget {
  final void Function(int newPage, String courseId) changePageWithCourseId;
  final String studentId;

  const Reviewedcourses(
      {super.key,
      required this.changePageWithCourseId,
      required this.studentId});

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
            widget.changePageWithCourseId(10, courseId);
          },
        ),
      ),
      Center(
        child: ReviewedCoursesList(
          studentId: widget.studentId,
          onTap: (courseId) {
            widget.changePageWithCourseId(10, courseId);
          },
          filterByCompletion: false,
        ),
      ),
      Center(
        child: ReviewedCoursesList(
          studentId: widget.studentId,
          onTap: (courseId) {
            widget.changePageWithCourseId(10, courseId);
          },
          filterByCompletion: true,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Results',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: SizedBox(
                height: 50,
                child: AssessmentTabBar(
                  selectedIndex: _selectedIndex,
                  onTabSelected: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: _pages[_selectedIndex],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
