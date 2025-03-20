import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../Constants/myColors.dart';
import '../../Themes/text_style.dart';
import '../BrowseCourse/BrowseCourseContainer.dart';
import '../../myutility.dart';

class BrowseAvailableContainer extends StatefulWidget {
  final String studentId;
  const BrowseAvailableContainer({super.key, required this.studentId});

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

      // Check if the course has assigned lecturers
      if (courseData['assignedLecturers'] != null &&
          (courseData['assignedLecturers'] as List).isNotEmpty) {
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
    }
    return courses;
  }

  // Method to show the popup dialog
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
                _addCourseToStudent(course);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Method to add the course to the student's profile
  Future<void> _addCourseToStudent(Map<String, dynamic> course) async {
    String studentId = widget.studentId; // Use the correct studentId

    if (studentId.isNotEmpty) {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference studentRef =
          firestore.collection('Users').doc(studentId);
      DocumentReference courseRef =
          firestore.collection('courses').doc(course['courseId']);

      try {
        // Fetch student data from the "Users" collection
        DocumentSnapshot studentSnapshot = await studentRef.get();
        if (!studentSnapshot.exists) {
          print('Student record not found!');
          return;
        }

        Map<String, dynamic> studentData =
            studentSnapshot.data() as Map<String, dynamic>;

        // Add the course to the student's profile
        await studentRef.update({
          'courses': FieldValue.arrayUnion(
              [course['courseId']]), // Update user's courses array
        });

        // Add the student to the course's student list
        await courseRef.update({
          'students': FieldValue.arrayUnion([
            {
              'studentId': studentId, // Store correct studentId
              'name': studentData['name'] ?? 'Unknown',
              'registered': true, // Mark as registered
            }
          ]),
        });

        print('Course successfully added for student!');
      } catch (e) {
        print('Error adding course: $e');
      }
    } else {
      print('Invalid student ID!');
    }
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
                                GestureDetector(
                                  onTap: () => _showAddCourseDialog(
                                      course), // Show dialog on course click
                                  child: SizedBox(
                                    width: 320, // Fixed width
                                    height: 340, // Fixed height
                                    child: BrowseCourseContainer(
                                      imagePath: course['courseImageUrl'] ??
                                          'images/placeholder.png',
                                      courseName:
                                          course['courseName'] ?? 'No Name',
                                      description:
                                          course['courseDescription'] ??
                                              'No Description',
                                      price:
                                          'R ${course['coursePrice'] ?? '0'}',
                                      moduleCount: course['moduleCount'] ?? 0,
                                      assessmentCount:
                                          course['assessmentCount'] ?? 0,
                                      studentCount: course['studentCount'] ?? 0,
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
