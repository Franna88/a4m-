import 'package:a4m/Student/dummyList/allStudentCourses.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Themes/Constants/myColors.dart';

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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Courses',
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
            child: Row(
              children: [
                _buildTab('All Courses', 0),
                _buildTab('In Progress', 1),
                _buildTab('Completed', 2),
              ],
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
                  AllStudentCourses(
                    studentId: widget.studentId,
                    onCourseTap: (courseId) {
                      widget.changePageWithCourseId(7, courseId);
                    },
                  ),
                  // In Progress Courses
                  AllStudentCourses(
                    studentId: widget.studentId,
                    filterByCompletion: false,
                    onCourseTap: (courseId) {
                      widget.changePageWithCourseId(7, courseId);
                    },
                  ),
                  // Completed Courses
                  AllStudentCourses(
                    studentId: widget.studentId,
                    filterByCompletion: true,
                    onCourseTap: (courseId) {
                      widget.changePageWithCourseId(7, courseId);
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

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _selectedIndex = index),
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? Mycolors().green : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
