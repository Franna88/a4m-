import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:a4m/Student/assessments/SubmitModuleAssessments/ModuleAssessmentsList.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SubmitModuleAssessments extends StatefulWidget {
  final void Function(int newPage, String courseId, String moduleId)
      changePageWithCourseId;
  final String selectedCourseId;
  final String studentID;

  const SubmitModuleAssessments({
    super.key,
    required this.changePageWithCourseId,
    required this.selectedCourseId,
    required this.studentID,
  });

  @override
  State<SubmitModuleAssessments> createState() =>
      _SubmitModuleAssessmentsState();
}

class _SubmitModuleAssessmentsState extends State<SubmitModuleAssessments> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: MyUtility(context).width - 360,
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                const SizedBox(height: 10),
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Mycolors().green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildTab('All', 0),
                    const SizedBox(width: 16),
                    _buildTab('Active', 1),
                    const SizedBox(width: 16),
                    _buildTab('Completed', 2),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: MyUtility(context).height - 280,
                  child: _selectedIndex == 0
                      ? ModuleAssessmentList(
                          courseId: widget.selectedCourseId,
                          onTap: (moduleId) {
                            widget.changePageWithCourseId(
                              5,
                              widget.selectedCourseId,
                              moduleId,
                            );
                          },
                          studentId: widget.studentID,
                        )
                      : Center(
                          child: Text(
                            _selectedIndex == 1 ? 'Active' : 'Completed',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Mycolors().green.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Mycolors().green : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Mycolors().green : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}
