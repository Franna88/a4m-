import 'package:a4m/Admin/AdminMarketing/adminCourseDetailsPopup/adminCourseDetailsPopup.dart';
import 'package:a4m/Admin/AdminMarketing/dummyData/adminCourseDummyData.dart';
import 'package:a4m/Admin/AdminMarketing/ui/adminCourseContainers.dart';
import 'package:a4m/CommonComponents/inputFields/myDropDownMenu.dart';
import 'package:a4m/CommonComponents/inputFields/mySearchBar.dart';
import 'package:a4m/Lecturers/LectureCourses/lecture_course_containers.dart';
import 'package:a4m/Lecturers/LectureCourses/lecture_course_details_popup.dart';
import 'package:a4m/Lecturers/LectureCourses/lecture_course_dummy_data.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

class LectureCourses extends StatefulWidget {
  final Function(int) changePage;
  const LectureCourses({super.key, required this.changePage});

  @override
  State<LectureCourses> createState() => _LectureCoursesState();
}

class _LectureCoursesState extends State<LectureCourses> {
  Future openCourseDetailsPopup() => showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: LectureCourseDetailsPopup(),
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
                SizedBox(
                  width: 300,
                  height: 50,
                  child: MySearchBar(
                    textController: courseSearch,
                    hintText: 'Search Course',
                  ),
                ),
                // const SizedBox(width: 20),
                // MyDropDownMenu(
                //   description: 'Course Category',
                //   customSize: 300,
                //   items: [],
                //   textfieldController: courseCategorySelect,
                // ),
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
                    (lectureCourseDummy.length / crossAxisCount).ceil(),
                    (_) => auto, // Auto height for each row
                  ),
                  rowGap: 20, // Space between rows
                  columnGap: 20, // Space between columns
                  children: [
                    for (var course in lectureCourseDummy)
                      SizedBox(
                        width: 320, // Fixed width
                        height: 340, // Fixed height
                        child: LectureCourseContainers(
                          courseName: course.courseName,
                          modulesComplete: course.modulesComplete,
                          courseDescription: course.courseDescription,
                          totalStudents: course.totalStudents,
                          moduleAmount: course.moduleAmount,
                          assessmentAmount: course.assessmentAmount,
                          courseImage: course.courseImage,
                          onTap: openCourseDetailsPopup,
                          changePage: widget.changePage,
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
