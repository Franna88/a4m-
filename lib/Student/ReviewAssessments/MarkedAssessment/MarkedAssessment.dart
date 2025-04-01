import 'package:a4m/Constants/myColors.dart';
import 'package:a4m/Student/ReviewAssessments/MarkedAssessment/Ui/MarkedContainer.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MarkedAssessment extends StatefulWidget {
  final String courseId;
  final String moduleId;
  final String studentId; // 🔹 Added studentId parameter

  const MarkedAssessment({
    super.key,
    required this.courseId,
    required this.moduleId,
    required this.studentId, // 🔹 Ensure studentId is received
  });

  @override
  State<MarkedAssessment> createState() => _MarkedAssessmentState();
}

class _MarkedAssessmentState extends State<MarkedAssessment> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        width: MyUtility(context).width - 320,
        height: MyUtility(context).height - 80,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.black,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Material(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Module Title
                Container(
                  width: 400,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Mycolors().darkGrey,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        'Results',
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Marked Assessments List
                Expanded(
                  child: MarkedContainer(
                    courseId: widget.courseId,
                    moduleId: widget.moduleId,
                    studentId: widget.studentId, // 🔹 Pass studentId correctly
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
