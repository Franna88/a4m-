import 'package:a4m/Facilitator/Pages/MyCourses/ui/facilitatorCourseContainers.dart';
import 'package:a4m/LandingPage/CourseListPage/ui/categoryNameStack.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

import '../../../CommonComponents/inputFields/mySearchBar.dart';

class FacilitatorMyCourses extends StatefulWidget {
  const FacilitatorMyCourses({super.key});

  @override
  State<FacilitatorMyCourses> createState() => _FacilitatorMyCoursesState();
}

class _FacilitatorMyCoursesState extends State<FacilitatorMyCourses> {
  final List<Map<String, String>> dummyCourses = List.generate(
    10,
    (index) => {
      'courseName': 'Course ${index + 1}',
      'courseDescription': 'This is a description for Course ${index + 1}',
      'totalStudents': '${(index + 1) * 10}',
      'totalAssesments': '${(index + 1) * 2}',
      'totalModules': '${(index + 1)}',
      'courseImage': 'images/course${(index % 3) + 1}.png',
      'coursePrice': '\$${(index + 1) * 50}',
    },
  );

  @override
  Widget build(BuildContext context) {
    final courseSearch = TextEditingController();
    final screenWidth = MyUtility(context).width - 280;

    // Decrease spacing by calculating tighter crossAxisCount
    int crossAxisCount =
        (screenWidth ~/ 300).clamp(1, 6); // Adjusted for tight layout

    return SizedBox(
      height: MyUtility(context).height - 50,
      width: screenWidth,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CategoryNameStack(text: 'My Courses'),
            const SizedBox(height: 20),
            SizedBox(
              width: 350,
              child: MySearchBar(
                textController: courseSearch,
                hintText: 'Search Course',
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    LayoutGrid(
                      columnSizes: List.generate(
                        crossAxisCount,
                        (_) => FlexibleTrackSize(1),
                      ),
                      rowSizes: List.generate(
                        (dummyCourses.length / crossAxisCount).ceil(),
                        (_) => auto,
                      ),
                      columnGap: 8, // Reduce horizontal spacing
                      rowGap: 15, // Reduce vertical spacing
                      children: dummyCourses
                          .map(
                            (course) => FacilitatorCourseContainers(
                              isAssignStudent: true,
                              courseName: course['courseName']!,
                              courseDescription: course['courseDescription']!,
                              totalStudents: course['totalStudents']!,
                              totalAssesments: course['totalAssesments']!,
                              totalModules: course['totalModules']!,
                              courseImage: course['courseImage']!,
                              coursePrice: course['coursePrice']!,
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 10), // Less bottom padding
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
