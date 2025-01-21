import 'package:a4m/Student/assessments/assessmentsContainer.dart';
import 'package:a4m/Student/commonUi/studentCourseItem.dart';
import 'package:a4m/Student/dummyList/studentCourseListModel.dart';
import 'package:flutter/material.dart';

class AssessmentCourses extends StatefulWidget {
  const AssessmentCourses({super.key});

  @override
  State<AssessmentCourses> createState() => _AssessmentCoursesState();
}

class _AssessmentCoursesState extends State<AssessmentCourses> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: dummyStudentCourseList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(top: 10),
            child: AssessmentsContainer(
              courseName: dummyStudentCourseList[index].courseName,
              courseImage: dummyStudentCourseList[index].courseImage,
              courseDescription:
                  dummyStudentCourseList[index].courseDescription,
              moduleCount: dummyStudentCourseList[index].moduleCount,
              assessmentCount: dummyStudentCourseList[index].assessmentCount,
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
