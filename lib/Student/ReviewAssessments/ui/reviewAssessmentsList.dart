import 'package:a4m/Student/ReviewAssessments/ui/reviewAssessmentsItem.dart';
import 'package:a4m/Student/commonUi/studentCourseItem.dart';
import 'package:a4m/Student/dummyList/studentCourseListModel.dart';
import 'package:flutter/material.dart';

import '../../dummyList/reviewAssessmentsModel.dart';

class ReviewAssessmentsList extends StatefulWidget {
  const ReviewAssessmentsList({super.key});

  @override
  State<ReviewAssessmentsList> createState() => _ReviewAssessmentsListState();
}

class _ReviewAssessmentsListState extends State<ReviewAssessmentsList> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: dummyStudentCourseList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(top: 10),
            child: ReviewAssessmentsItem(
              moduleName: dummyRieviewAssessmentList[index].moduleName,
              moduleImage: dummyRieviewAssessmentList[index].moduleImage,
              moduleDescription:
                  dummyRieviewAssessmentList[index].moduleDescription,
              moduleCount: dummyRieviewAssessmentList[index].moduleCount,
              assessmentCount:
                  dummyRieviewAssessmentList[index].assessmentCount,
              onTap: () {},
              isPassed: dummyRieviewAssessmentList[index].isPassed,
            ),
          );
        },
      ),
    );
  }
}
