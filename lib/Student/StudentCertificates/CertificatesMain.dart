import 'package:a4m/Student/BrowseCourse/BrowseCourseContainer.dart';
import 'package:a4m/Student/StudentCertificates/CertificatesStudentContainer.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

import '../../Constants/myColors.dart';
import '../../Themes/text_style.dart';
import '../dummyList/moduleDummyList.dart';

class CertificatesMainStudent extends StatefulWidget {
  const CertificatesMainStudent({super.key});

  @override
  State<CertificatesMainStudent> createState() =>
      _CertificatesMainStudentState();
}

class _CertificatesMainStudentState extends State<CertificatesMainStudent> {
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
                            const SizedBox(
                              width: 320, // Fixed width
                              height: 340, // Fixed height
                              child: CertificatesStudentContainer(
                                imagePath: 'images/course1.png',
                                courseName: 'Introduction to Flutter',
                                description:
                                    'Learn the basics of Flutter and how to create stunning mobile apps.',
                                price: 'R 323',
                                assessmentCount: 7,
                                moduleCount: 5,
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
