import 'package:a4m/Admin/AdminCourses/Table/courseTable.dart';
import 'package:a4m/CommonComponents/inputFields/myDropDownMenu.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';

class AdminCourseList extends StatefulWidget {
  const AdminCourseList({super.key});

  @override
  State<AdminCourseList> createState() => _AdminCourseListState();
}

class _AdminCourseListState extends State<AdminCourseList> {
  @override
  Widget build(BuildContext context) {
    final courseCategory = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyDropDownMenu(
              description: 'Course Category',
              customSize: 300,
              items: [],
              textfieldController: courseCategory),
          const SizedBox(
            height: 20,
          ),
          Container(
            height: MyUtility(context).height * 0.75 - 53,
            width: MyUtility(context).width - 320,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              border: Border.all(
                width: 2,
                color: Colors.black,
              ),
            ),
            child: CourseTable(),
          ),
        ],
      ),
    );
  }
}
