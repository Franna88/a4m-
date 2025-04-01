import 'package:a4m/Student/ReviewAssessments/ui/reviewAssessmentsList.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Themes/Constants/myColors.dart';
import '../../myutility.dart';

class ReviewAssessments extends StatefulWidget {
  final void Function(int newPage, String courseId, String moduleId)
      changePageWithCourseId;
  final String courseId;

  const ReviewAssessments({
    super.key,
    required this.changePageWithCourseId,
    required this.courseId,
  });

  @override
  State<ReviewAssessments> createState() => _ReviewAssessmentsState();
}

class _ReviewAssessmentsState extends State<ReviewAssessments> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MyUtility(context).width - 360,
      height: MyUtility(context).height - 80,
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
                'Results',
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
                child: ReviewAssessmentsList(
                  courseId: widget.courseId,
                  onTap: (moduleId) {
                    widget.changePageWithCourseId(6, widget.courseId, moduleId);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
