import 'package:a4m/Admin/AdminMarketing/adminCourseDetailsPopup/adminCourseDetailsPopup.dart';
import 'package:a4m/Admin/AdminMarketing/dummyData/adminCourseDummyData.dart';
import 'package:a4m/Admin/AdminMarketing/ui/adminCourseContainers.dart';
import 'package:a4m/CommonComponents/buttons/slimButtons.dart';
import 'package:a4m/CommonComponents/inputFields/myDropDownMenu.dart';
import 'package:a4m/CommonComponents/inputFields/mySearchBar.dart';
import 'package:a4m/ContentDev/EditContentDev/EditContentDevComponants/edit_module_containers.dart';
import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:a4m/Themes/text_style.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

class EditModule extends StatefulWidget {
  final Function(int) changePageIndex;
  final String moduleName;

  EditModule({
    super.key,
    required this.changePageIndex,
    this.moduleName = 'Manufacturing Level 1',
  });

  @override
  State<EditModule> createState() => _EditModuleState();
}

class _EditModuleState extends State<EditModule> {
  Future openCourseDetailsPopup() => showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: AdminCourseDetailsPopup(),
        );
      });

  @override
  Widget build(BuildContext context) {
    // Calculate the number of columns based on the screen width
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
            color: Colors.white,
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
                        widget.moduleName,
                        style: MyTextStyles(context).subHeaderBlack,
                      ),
                      Spacer(),
                      SlimButtons(
                        buttonText: 'Add Module',
                        buttonColor: Mycolors().blue,
                        onPressed: () {},
                        customWidth: 105,
                        customHeight: 30,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Divider(
                    color: Mycolors().green,
                    thickness: 6,
                  ),
                  const SizedBox(height: 20),

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
                              child: EditModuleContainers(
                                courseName: course.courseName,
                                price: course.price,
                                courseDescription: course.courseDescription,
                                totalStudents: course.totalStudents,
                                moduleAmount: course.moduleAmount,
                                assessmentAmount: course.assessmentAmount,
                                courseImage: course.courseImage,
                                onTap: openCourseDetailsPopup,
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
          ),
        ),
      ),
    );
  }
}
