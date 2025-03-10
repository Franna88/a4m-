import 'package:a4m/Facilitator/Pages/MyCourses/ui/facilitatorCourseContainers.dart';
import 'package:a4m/LandingPage/CourseListPage/ui/categoryNameStack.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../CommonComponents/inputFields/myDropDownMenu.dart';
import '../../../CommonComponents/inputFields/mySearchBar.dart';

class FacilitatorBrowseCourses extends StatefulWidget {
  final String facilitatorId;
  const FacilitatorBrowseCourses({super.key, required this.facilitatorId});

  @override
  State<FacilitatorBrowseCourses> createState() =>
      _FacilitatorBrowseCoursesState();
}

class _FacilitatorBrowseCoursesState extends State<FacilitatorBrowseCourses> {
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
  Future<void> _addCourseToFacilitator(Map<String, dynamic> course) async {
    String facilitatorId = widget.facilitatorId; // Get facilitator ID

    if (facilitatorId.isNotEmpty) {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference facilitatorRef =
          firestore.collection('Users').doc(facilitatorId);

      try {
        // Fetch facilitator data
        DocumentSnapshot facilitatorSnapshot = await facilitatorRef.get();
        if (!facilitatorSnapshot.exists) {
          print('Facilitator record not found!');
          return;
        }

        // Add the course ID to the facilitatorCourses array
        await facilitatorRef.update({
          'facilitatorCourses': FieldValue.arrayUnion([
            {
              'courseId': course['courseId'], // Store the course document ID
            }
          ]),
        });

        print('Course successfully added for facilitator!');
      } catch (e) {
        print('Error adding course to facilitator: $e');
      }
    } else {
      print('Invalid facilitator ID!');
    }
  }

  // Fetch approved courses from Firebase
  Future<List<Map<String, dynamic>>> fetchApprovedCourses() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('courses')
        .where('status', isEqualTo: 'approved') // Filter by status
        .get();

    List<Map<String, dynamic>> courses = [];
    for (var doc in snapshot.docs) {
      final courseData = doc.data() as Map<String, dynamic>;

      // Check if the course has assigned lecturers
      if (courseData['assignedLecturers'] == null ||
          (courseData['assignedLecturers'] as List).isEmpty) {
        continue; // Skip this course if no lecturers are assigned
      }

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

  void _showAddCourseDialog(Map<String, dynamic> course) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Course'),
          content: Text(
              'Do you want to add ${course['courseName']} to your courses?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addCourseToFacilitator(course); // Add course to Firestore
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final category = TextEditingController();
    final courseSearch = TextEditingController();
    final screenWidth = MyUtility(context).width - 280;

    // Decrease spacing by calculating tighter crossAxisCount
    int crossAxisCount =
        (screenWidth ~/ 300).clamp(1, 6); // Adjusted for tight layout

    return Container(
      height: MyUtility(context).height - 50,
      width: screenWidth,
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
                  CategoryNameStack(text: 'My Courses'),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      MyDropDownMenu(
                          description: 'Category',
                          customSize: 300,
                          items: ['test1', 'test2'],
                          textfieldController: category),
                      const SizedBox(
                        width: 40,
                      ),
                      SizedBox(
                        width: 350,
                        child: MySearchBar(
                            textController: courseSearch,
                            hintText: 'Search Course'),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
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
                                  child: GestureDetector(
                                    onTap: () => _showAddCourseDialog(
                                        course), // Show dialog before adding course
                                    child: SizedBox(
                                      width: 320,
                                      height: 340,
                                      child: FacilitatorCourseContainers(
                                        courseImage: course['courseImageUrl'] ??
                                            'images/placeholder.png',
                                        courseName:
                                            course['courseName'] ?? 'No Name',
                                        courseDescription:
                                            course['courseDescription'] ??
                                                'No Description',
                                        coursePrice:
                                            'R ${course['coursePrice']?.toString() ?? '0'}',
                                        totalModules:
                                            course['moduleCount']?.toString() ??
                                                '0',
                                        totalAssesments:
                                            course['assessmentCount']
                                                    ?.toString() ??
                                                '0',
                                        totalStudents: course['studentCount']
                                                ?.toString() ??
                                            '0',
                                        isAssignStudent: false,
                                        facilitatorId: widget
                                            .facilitatorId, // Pass facilitatorId
                                        courseId:
                                            course['courseId'], // Pass courseId
                                      ),
                                    ),
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
