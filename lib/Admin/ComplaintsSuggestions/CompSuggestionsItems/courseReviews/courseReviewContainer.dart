import 'package:flutter/material.dart';
import '../../../../myutility.dart';
import 'ui/courseReviewTable.dart';

class CourseReviewContainer extends StatefulWidget {
  const CourseReviewContainer({super.key});

  @override
  State<CourseReviewContainer> createState() => _CourseReviewContainerState();
}

class _CourseReviewContainerState extends State<CourseReviewContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        border: Border.all(
          width: 2,
          color: Colors.black,
        ),
      ),
      width: MyUtility(context).width - 580,
      height: MyUtility(context).height - 110,
      child: const CourseReviewTable(),
    );
  }
}
