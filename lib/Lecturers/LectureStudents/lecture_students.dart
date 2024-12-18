import 'package:a4m/Admin/AdminA4mMembers/dummyDataModel/membersDummyData.dart';
import 'package:a4m/CommonComponents/inputFields/myDropDownMenu.dart';
import 'package:a4m/CommonComponents/inputFields/mySearchBar.dart';
import 'package:a4m/Lecturers/LectureStudents/lecture_student_containers.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

class LectureStudent extends StatefulWidget {
  const LectureStudent({super.key});

  @override
  State<LectureStudent> createState() => _LectureStudentState();
}

class _LectureStudentState extends State<LectureStudent> {
  @override
  Widget build(BuildContext context) {
    final memberSearch = TextEditingController();
    final memberCategorySelect = TextEditingController();

    // Calculate the number of columns based on the screen width
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount =
        (screenWidth ~/ 400).clamp(1, 6); // Minimum 1, maximum 6

    return Container(
      width: MyUtility(context).width - 320,
      height: MyUtility(context).height - 80,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar and dropdown
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyDropDownMenu(
                  description: 'A-Z',
                  customSize: 300,
                  items: [], // Update with member categories if needed
                  textfieldController: memberCategorySelect,
                ),
                MyDropDownMenu(
                  description: 'New',
                  customSize: 300,
                  items: [], // Update with member categories if needed
                  textfieldController: memberCategorySelect,
                ),
                SizedBox(
                  width: 300,
                  height: 50,
                  child: MySearchBar(
                    textController: memberSearch,
                    hintText: 'Search Member',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Scrollable grid layout
            Expanded(
              child: SingleChildScrollView(
                child: LayoutGrid(
                  columnSizes: List.generate(
                    crossAxisCount,
                    (_) => FlexibleTrackSize(220),
                  ),
                  rowSizes: List.generate(
                    (memberdummyData.length / crossAxisCount).ceil(),
                    (_) => auto,
                  ),
                  rowGap: 20, // Space between rows
                  columnGap: 1, // Space between columns
                  children: [
                    for (var member in memberdummyData)
                      SizedBox(
                        height: 300,
                        width: 250,
                        child: LectureStudentContainers(
                          isLecturer: member.isLecturer,
                          isContentDev: member.isContentDev,
                          isFacilitator: member.isFacilitator,
                          image: member.image,
                          name: member.name,
                          number: member.number,
                          studentAmount: member.students,
                          contentTotal: member.content,
                          rating: member.rating,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
