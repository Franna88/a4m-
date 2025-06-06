import 'package:a4m/Facilitator/Pages/MyCourses/ui/facilitatorCourseContainers.dart';
import 'package:a4m/Facilitator/Pages/MyCourses/facilitatorViewCourse.dart';
import 'package:a4m/LandingPage/CourseListPage/ui/categoryNameStack.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import '../../../CommonComponents/inputFields/mySearchBar.dart';

class FacilitatorMyCourses extends StatefulWidget {
  final String facilitatorId;
  final GlobalKey<NavigatorState> navigatorKey;

  const FacilitatorMyCourses({
    super.key,
    required this.facilitatorId,
    required this.navigatorKey,
  });

  @override
  State<FacilitatorMyCourses> createState() => _FacilitatorMyCoursesState();
}

class _FacilitatorMyCoursesState extends State<FacilitatorMyCourses> {
  List<Map<String, dynamic>> facilitatorCourses = [];
  List<Map<String, dynamic>> filteredCourses = [];
  bool isLoading = true;
  String searchQuery = '';
  Timer? _debounceTimer;
  final TextEditingController courseSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchFacilitatorCourses();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    courseSearchController.dispose();
    super.dispose();
  }

  // Handle search with debounce
  void _performSearch(String query) {
    // Cancel previous timer if it exists
    _debounceTimer?.cancel();

    // Create a new timer that will execute after 500ms
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        searchQuery = query.toLowerCase();
        _filterCourses();
      });
    });
  }

  // Filter courses based on search query
  void _filterCourses() {
    if (searchQuery.isEmpty) {
      filteredCourses = List.from(facilitatorCourses);
    } else {
      filteredCourses = facilitatorCourses.where((course) {
        final name = (course['courseName'] ?? '').toString().toLowerCase();
        final description =
            (course['courseDescription'] ?? '').toString().toLowerCase();
        return name.contains(searchQuery) || description.contains(searchQuery);
      }).toList();
    }
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
            filteredCourses = fetchedCourses; // Initialize filtered courses
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
            filteredCourses = [];
          });
        }
      } else {
        print("Facilitator document not found.");
        setState(() {
          isLoading = false;
          filteredCourses = [];
        });
      }
    } catch (e) {
      print("Error fetching facilitator courses: $e");
      setState(() {
        isLoading = false;
        filteredCourses = [];
      });
    }
  }

  void _navigateToCourseView(String courseId) {
    widget.navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => FacilitatorViewCourse(courseId: courseId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MyUtility(context).width - 280;

    int crossAxisCount =
        (screenWidth ~/ 300).clamp(1, 6); // Adjusted for tight layout

    return Navigator(
      key: widget.navigatorKey,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => SizedBox(
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
                      textController: courseSearchController,
                      hintText: 'Search Course',
                      onChanged: _performSearch,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : filteredCourses.isEmpty
                            ? Center(
                                child: Text(
                                  searchQuery.isEmpty
                                      ? 'No courses available'
                                      : 'No courses match your search',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              )
                            : SingleChildScrollView(
                                child: Column(
                                  children: [
                                    LayoutGrid(
                                      columnSizes: List.generate(
                                        crossAxisCount,
                                        (_) => const FlexibleTrackSize(1),
                                      ),
                                      rowSizes: List.generate(
                                        (filteredCourses.length /
                                                crossAxisCount)
                                            .ceil(),
                                        (_) => auto,
                                      ),
                                      columnGap: 8,
                                      rowGap: 15,
                                      children: filteredCourses
                                          .map(
                                            (course) => Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () =>
                                                    _navigateToCourseView(
                                                        course['courseId']),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                child:
                                                    FacilitatorCourseContainers(
                                                  isAssignStudent: true,
                                                  courseName:
                                                      course['courseName'] ??
                                                          'Unknown',
                                                  courseDescription: course[
                                                          'courseDescription'] ??
                                                      '',
                                                  totalStudents:
                                                      course['studentCount']
                                                              ?.toString() ??
                                                          '0',
                                                  totalAssesments:
                                                      course['assessmentCount']
                                                              ?.toString() ??
                                                          '0',
                                                  totalModules:
                                                      course['moduleCount']
                                                              ?.toString() ??
                                                          '0',
                                                  courseImage: course[
                                                          'courseImageUrl'] ??
                                                      'https://via.placeholder.com/150',
                                                  coursePrice:
                                                      'R ${course['coursePrice']?.toString() ?? '0'}',
                                                  facilitatorId:
                                                      widget.facilitatorId,
                                                  courseId: course['courseId'],
                                                ),
                                              ),
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
          ),
        );
      },
    );
  }
}
