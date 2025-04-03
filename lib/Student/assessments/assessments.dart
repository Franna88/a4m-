import 'package:a4m/LandingPage/CourseListPage/ui/categoryNameStack.dart';
import 'package:a4m/Student/assessments/AssessmentList.dart';
import 'package:a4m/Student/assessments/AssessmentTabBar.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AssessmentsMain extends StatefulWidget {
  final void Function(int newPage, String courseId) changePageWithCourseId;
  final String studentId;

  const AssessmentsMain({
    super.key,
    required this.changePageWithCourseId,
    required this.studentId,
  });

  @override
  State<AssessmentsMain> createState() => _AssessmentsMainState();
}

class _AssessmentsMainState extends State<AssessmentsMain> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Submissions',
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
            child: AssessmentTabBar(
              selectedIndex: _selectedIndex,
              onTabSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
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
              child: IndexedStack(
                index: _selectedIndex,
                sizing: StackFit.expand,
                children: [
                  // All Courses
                  AssessmentCourses(
                    studentId: widget.studentId,
                    onTap: (courseId) {
                      widget.changePageWithCourseId(8, courseId);
                    },
                  ),
                  // Active Courses (Incomplete)
                  AssessmentCourses(
                    studentId: widget.studentId,
                    filterByCompletion: false,
                    onTap: (courseId) {
                      widget.changePageWithCourseId(8, courseId);
                    },
                  ),
                  // Completed Courses
                  AssessmentCourses(
                    studentId: widget.studentId,
                    filterByCompletion: true,
                    onTap: (courseId) {
                      widget.changePageWithCourseId(8, courseId);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
