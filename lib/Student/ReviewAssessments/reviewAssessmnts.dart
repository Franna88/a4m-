import 'package:a4m/Student/ReviewAssessments/ui/reviewAssessmentsList.dart';
import 'package:flutter/material.dart';
import '../../LandingPage/CourseListPage/ui/categoryNameStack.dart';
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CategoryNameStack(text: 'My Courses'),
          const SizedBox(height: 15),
          SizedBox(
            width: MyUtility(context).width - 360,
            height: MyUtility(context).height - 205,
            child: ReviewAssessmentsList(
              courseId: widget.courseId,
              onTap: (moduleId) {
                widget.changePageWithCourseId(6, widget.courseId, moduleId);
              },
            ),
          ),
        ],
      ),
    );
  }
}
