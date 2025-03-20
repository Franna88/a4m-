import 'package:a4m/Facilitator/Pages/MyCourses/ui/facilitatorCourseContainers.dart';
import 'package:a4m/LandingPage/CourseListPage/ui/categoryNameStack.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../CommonComponents/inputFields/mySearchBar.dart';

class FacilitatorMyCourses extends StatefulWidget {
  final String facilitatorId;
  const FacilitatorMyCourses({super.key, required this.facilitatorId});

  @override
  State<FacilitatorMyCourses> createState() => _FacilitatorMyCoursesState();
}

class _FacilitatorMyCoursesState extends State<FacilitatorMyCourses> {
  List<Map<String, dynamic>> facilitatorCourses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFacilitatorCourses();
  }

  Future<void> _fetchFacilitatorCourses() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Fetch facilitator's document
      DocumentSnapshot facilitatorDoc =
          await firestore.collection('Users').doc(widget.facilitatorId).get();

      if (facilitatorDoc.exists) {
        List<dynamic> coursesList = facilitatorDoc['facilitatorCourses'] ?? [];

        // Extract course IDs from maps
        List<String> courseIds =
            coursesList.map((course) => course['courseId'] as String).toList();

        if (courseIds.isNotEmpty) {
          // Fetch course details from Firestore
          QuerySnapshot coursesSnapshot = await firestore
              .collection('courses')
              .where(FieldPath.documentId, whereIn: courseIds)
              .get();

          List<Map<String, dynamic>> fetchedCourses = [];

          for (var doc in coursesSnapshot.docs) {
            final courseData = doc.data() as Map<String, dynamic>;

            // Fetch modules for the course
            QuerySnapshot moduleSnapshot = await firestore
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
            fetchedCourses.add({
              ...courseData,
              'courseId': doc.id,
              'moduleCount': moduleCount,
              'assessmentCount': assessmentCount,
              'studentCount': studentCount,
            });
          }

          setState(() {
            facilitatorCourses = fetchedCourses;
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
        }
      } else {
        print("Facilitator document not found.");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching facilitator courses: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseSearch = TextEditingController();
    final screenWidth = MyUtility(context).width - 280;

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
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          LayoutGrid(
                            columnSizes: List.generate(
                              crossAxisCount,
                              (_) => FlexibleTrackSize(1),
                            ),
                            rowSizes: List.generate(
                              (facilitatorCourses.length / crossAxisCount)
                                  .ceil(),
                              (_) => auto,
                            ),
                            columnGap: 8,
                            rowGap: 15,
                            children: facilitatorCourses
                                .map(
                                  (course) => FacilitatorCourseContainers(
                                    isAssignStudent: true,
                                    courseName:
                                        course['courseName'] ?? 'Unknown',
                                    courseDescription:
                                        course['courseDescription'] ?? '',
                                    totalStudents:
                                        course['studentCount']?.toString() ??
                                            '0',
                                    totalAssesments:
                                        course['assessmentCount']?.toString() ??
                                            '0',
                                    totalModules:
                                        course['moduleCount']?.toString() ??
                                            '0',
                                    courseImage: course['courseImageUrl'] ??
                                        'https://via.placeholder.com/150',
                                    coursePrice:
                                        'R ${course['coursePrice']?.toString() ?? '0'}',
                                    facilitatorId: widget.facilitatorId,
                                    courseId: course['courseId'],
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 10),
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
