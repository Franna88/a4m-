import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

import '../../Constants/myColors.dart';
import '../../Themes/text_style.dart';
import '../BrowseCourse/BrowseCourseContainer.dart';
import '../../myutility.dart';

class BrowseAvailableContainer extends StatefulWidget {
  const BrowseAvailableContainer({super.key});

  @override
  State<BrowseAvailableContainer> createState() =>
      _BrowseAvailableContainerState();
}

class _BrowseAvailableContainerState extends State<BrowseAvailableContainer> {
  // Fetch approved courses from Firebase
  Future<List<Map<String, dynamic>>> fetchApprovedCourses() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('courses')
        .where('status', isEqualTo: 'approved') // Filter by status
        .get();

    List<Map<String, dynamic>> courses = [];
    for (var doc in snapshot.docs) {
      final courseData = doc.data() as Map<String, dynamic>;

      // Fetch modules for the course
      QuerySnapshot moduleSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(doc.id)
          .collection('modules')
          .get();

      // Count the number of modules
      int moduleCount = moduleSnapshot.docs.length;

      // Count the total number of assessments based on `assessmentsPdfUrl`
      int assessmentCount = 0;
      for (var module in moduleSnapshot.docs) {
        final moduleData = module.data() as Map<String, dynamic>;
        if (moduleData['assessmentsPdfUrl'] != null &&
            moduleData['assessmentsPdfUrl'].isNotEmpty) {
          assessmentCount++;
        }
      }

      // Count the number of students
      int studentCount =
          (courseData['students'] as List<dynamic>? ?? []).length;

      // Add all dynamic values to the course data
      courses.add({
        ...courseData,
        'courseId': doc.id,
        'moduleCount': moduleCount,
        'assessmentCount': assessmentCount,
        'studentCount': studentCount,
      });
    }
    return courses;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount =
        (screenWidth ~/ 400).clamp(1, 6); // Minimum 1, maximum 6

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
                        'Available Courses',
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

                  // Use FutureBuilder to display courses
                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: fetchApprovedCourses(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(
                              child: Text('No approved courses available.'));
                        }

                        final courses = snapshot.data!;

                        return SingleChildScrollView(
                          child: LayoutGrid(
                            columnSizes: List.generate(
                              crossAxisCount,
                              (_) =>
                                  FlexibleTrackSize(1), // Flexible column sizes
                            ),
                            rowSizes: List.generate(
                              (courses.length / crossAxisCount).ceil(),
                              (_) => auto, // Auto height for rows
                            ),
                            rowGap: 20, // Space between rows
                            columnGap: 20, // Space between columns
                            children: [
                              for (var course in courses)
                                SizedBox(
                                  width: 320, // Fixed width
                                  height: 340, // Fixed height
                                  child: BrowseCourseContainer(
                                    imagePath: course['courseImageUrl'] ??
                                        'images/placeholder.png',
                                    courseName:
                                        course['courseName'] ?? 'No Name',
                                    description: course['courseDescription'] ??
                                        'No Description',
                                    price: 'R ${course['coursePrice'] ?? '0'}',
                                    moduleCount: course['moduleCount'] ?? 0,
                                    assessmentCount:
                                        course['assessmentCount'] ?? 0,
                                    studentCount: course['studentCount'] ?? 0,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
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
