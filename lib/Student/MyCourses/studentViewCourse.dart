import 'package:a4m/Admin/AdminMarketing/ui/adminCourseContainers.dart';
import 'package:a4m/Student/commonUi/studentModuleContainer.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

import '../../Admin/AdminMarketing/dummyData/adminCourseDummyData.dart';
import '../../CommonComponents/buttons/slimButtons.dart';
import '../../Constants/myColors.dart';
import '../../Themes/text_style.dart';
import '../dummyList/moduleDummyList.dart';

class StudentViewCourse extends StatefulWidget {
  const StudentViewCourse({super.key});

  @override
  State<StudentViewCourse> createState() => _StudentViewCourseState();
}

class _StudentViewCourseState extends State<StudentViewCourse> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount =
        (screenWidth ~/ 400).clamp(1, 6); // Minimum 1, maximum 4

    return Container(
      width: MyUtility(context).width - 320,
      height: MyUtility(context).height - 80,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MyUtility(context).height * 0.78,
          ),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white, border: Border.all(width: 0.8)),
            width: MyUtility(context).width,
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
                      Text(
                        'Test',
                        style: MyTextStyles(context).subHeaderBlack,
                      ),
                      Spacer(),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Divider(
                    color: Mycolors().green,
                    thickness: 6,
                  ),
                  const SizedBox(height: 20),

                  // USING A ADMIN DUMMY LIST

                  // Scrollable grid layout
                  Expanded(
                    child: SingleChildScrollView(
                      child: LayoutGrid(
                        columnSizes: List.generate(
                          crossAxisCount,
                          (_) => FlexibleTrackSize(1), // Use FlexibleTrackSize
                        ),
                        rowSizes: List.generate(
                          (dummyModuleList.length / crossAxisCount).ceil(),
                          (_) => auto, // Auto height for each row
                        ),
                        rowGap: 20, // Space between rows
                        columnGap: 20, // Space between columns
                        children: [
                          for (var module in dummyModuleList)
                            SizedBox(
                                width: 320, // Fixed width
                                height: 340, // Fixed height
                                child: StudentModuleContainer(
                                    assessmentAmount: module.assessmentCount,
                                    moduleName: module.moduleName,
                                    moduleDescription: module.moduleDescription,
                                    moduleImage: module.moduleImage)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
