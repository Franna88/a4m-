import 'package:a4m/Constants/myColors.dart';
import 'package:a4m/Student/assessments/SubmitAssessments/SubmitContainerList.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SubmitAssessment extends StatefulWidget {
  final String courseId;
  final String moduleId;
  final String studentId;

  const SubmitAssessment({
    super.key,
    required this.courseId,
    required this.moduleId,
    required this.studentId,
  });

  @override
  State<SubmitAssessment> createState() => _SubmitAssessmentState();
}

class _SubmitAssessmentState extends State<SubmitAssessment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                'Submit Submissions',
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
              Expanded(
                child: SubmitContainerList(
                  courseId: widget.courseId,
                  moduleId: widget.moduleId,
                  studentId: widget.studentId,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
