import 'package:a4m/Admin/AdminMarketing/adminCourseDetailsPopup/adminCourseDetailsPopup.dart';
import 'package:a4m/Admin/AdminMarketing/dummyData/adminCourseDummyData.dart';
import 'package:a4m/Admin/AdminMarketing/ui/adminCourseContainers.dart';
import 'package:a4m/CommonComponents/inputFields/myDropDownMenu.dart';
import 'package:a4m/CommonComponents/inputFields/mySearchBar.dart';
import 'package:a4m/ContentDev/EditContentDev/EditContentDevComponants/edit_course_containers.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

class EditContentDev extends StatefulWidget {
  Function(int) changePageIndex;
  EditContentDev({
    super.key,
    required this.changePageIndex,
  });

  @override
  State<EditContentDev> createState() => _EditContentDevState();
}

class _EditContentDevState extends State<EditContentDev> {
  Future openCourseDetailsPopup() => showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: AdminCourseDetailsPopup(),
        );
      });

  @override
  Widget build(BuildContext context) {
    final courseSearch = TextEditingController();
    final courseCategorySelect = TextEditingController();

    // Calculate the number of columns based on the screen width
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount =
        (screenWidth ~/ 400).clamp(1, 6); // Minimum 1, maximum 4

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
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                MyDropDownMenu(
                  description: 'Latest',
                  customSize: 300,
                  items: [],
                  textfieldController: courseCategorySelect,
                ),
                Spacer(),
                SizedBox(
                  width: 300,
                  height: 50,
                  child: MySearchBar(
                    textController: courseSearch,
                    hintText: 'Search',
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
                    (_) => FlexibleTrackSize(1), // Use FlexibleTrackSize
                  ),
                  rowSizes: List.generate(
                    (adminCourseDummy.length / crossAxisCount).ceil(),
                    (_) => auto, // Auto height for each row
                  ),
                  rowGap: 20, // Space between rows
                  columnGap: 20, // Space between columns
                  children: [
                    for (var course in adminCourseDummy)
                      SizedBox(
                        width: 320, // Fixed width
                        height: 340, // Fixed height
                        child: EditCourseContainers(
                          courseName: course.courseName,
                          price: course.price,
                          courseDescription: course.courseDescription,
                          totalStudents: course.totalStudents,
                          moduleAmount: course.moduleAmount,
                          assessmentAmount: course.assessmentAmount,
                          courseImage: course.courseImage,
                          onTap: () {
                            widget.changePageIndex(8);
                          },
                          editOnTap: () {
                            widget.changePageIndex(3);
                          },
                          deleteOnTap: () {},
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
