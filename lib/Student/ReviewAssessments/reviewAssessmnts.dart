import 'package:a4m/Student/ReviewAssessments/ui/reviewAssessmentsList.dart';
import 'package:flutter/material.dart';

import '../../LandingPage/CourseListPage/ui/categoryNameStack.dart';
import '../../myutility.dart';

class ReviewAssessments extends StatefulWidget {
  const ReviewAssessments({super.key});

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
          const SizedBox(
            height: 15,
          ),
          SizedBox(
              width: MyUtility(context).width - 360,
              height: MyUtility(context).height - 205,
              child: ReviewAssessmentsList()),
        ],
      ),
    );
  }
}
