import 'package:a4m/Student/commonUi/studentCourseItem.dart';
import 'package:a4m/Student/dummyList/studentCourseListModel.dart';
import 'package:flutter/material.dart';

class AllStudentCourses extends StatefulWidget {
  const AllStudentCourses({super.key});

  @override
  State<AllStudentCourses> createState() => _AllStudentCoursesState();
}

class _AllStudentCoursesState extends State<AllStudentCourses> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: dummyStudentCourseList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(top: 10),
            child: StudentCourseItem(
              courseName: dummyStudentCourseList[index].courseName,
              courseImage: dummyStudentCourseList[index].courseImage,
              courseDescription: dummyStudentCourseList[index].courseDescription,
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
