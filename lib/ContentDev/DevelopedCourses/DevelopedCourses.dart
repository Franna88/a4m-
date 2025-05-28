import 'package:a4m/CommonComponents/inputFields/mySearchBar.dart';
import 'package:a4m/ContentDev/DevelopedCourses/DevelopedCourseEdit.dart';
import 'package:a4m/myutility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

class DevelopedCourses extends StatefulWidget {
  final Function(int, String) changePageWithCourseId;
  final String contentDevId;

  const DevelopedCourses({
    super.key,
    required this.changePageWithCourseId,
    required this.contentDevId,
  });

  @override
  State<DevelopedCourses> createState() => _DevelopedCoursesState();
}

class _DevelopedCoursesState extends State<DevelopedCourses> {
  List<Map<String, dynamic>> createdCourses = [];
  List<Map<String, dynamic>> filteredCourses = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;

  // Fetch courses created by this content developer
  Future<void> fetchCreatedCourses() async {
    try {
      print("Fetching courses created by: ${widget.contentDevId}");

      // Fetch courses from both collections
      QuerySnapshot coursesSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .where('createdBy', isEqualTo: widget.contentDevId)
          .get();

      QuerySnapshot pendingCoursesSnapshot = await FirebaseFirestore.instance
          .collection('pendingCourses')
          .where('createdBy', isEqualTo: widget.contentDevId)
          .get();

      List<Map<String, dynamic>> tempCourses = [];

      // Process regular courses
      for (var doc in coursesSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // Fetch module data to calculate assessments
        QuerySnapshot moduleSnapshot = await FirebaseFirestore.instance
            .collection('courses')
            .doc(doc.id)
            .collection('modules')
            .get();

        int totalAssessments = 0;
        for (var module in moduleSnapshot.docs) {
          final moduleData = module.data() as Map<String, dynamic>;
          if (moduleData.containsKey('assessmentsPdfUrl')) {
            totalAssessments++;
          }
        }

        // Fetch students count
        List students = data['students'] ?? [];

        tempCourses.add({
          'id': doc.id,
          'courseName': data['courseName'] ?? 'No Name',
          'courseDescription': data['courseDescription'] ?? '',
          'courseImage': data['courseImageUrl'] ?? '',
          'moduleAmount': moduleSnapshot.size,
          'totalStudents': students.length.toString(),
          'totalAssessments': totalAssessments.toString(),
          'status': data['status'] ?? 'approved',
          'declineReason': data['declineReason'],
          'previewPdfUrl': data['previewPdfUrl'],
          'courseCategory': data['courseCategory'] ?? '',
        });
      }

      // Process pending courses
      for (var doc in pendingCoursesSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // Fetch module data to calculate assessments
        QuerySnapshot moduleSnapshot = await FirebaseFirestore.instance
            .collection('pendingCourses')
            .doc(doc.id)
            .collection('modules')
            .get();

        int totalAssessments = 0;
        for (var module in moduleSnapshot.docs) {
          final moduleData = module.data() as Map<String, dynamic>;
          if (moduleData.containsKey('assessmentsPdfUrl')) {
            totalAssessments++;
          }
        }

        // Fetch students count
        List students = data['students'] ?? [];

        tempCourses.add({
          'id': doc.id,
          'courseName': data['courseName'] ?? 'No Name',
          'courseDescription': data['courseDescription'] ?? '',
          'courseImage': data['courseImageUrl'] ?? '',
          'moduleAmount': moduleSnapshot.size,
          'totalStudents': students.length.toString(),
          'totalAssessments': totalAssessments.toString(),
          'status': data['status'] ?? 'pending',
          'declineReason': data['declineReason'],
          'previewPdfUrl': data['previewPdfUrl'],
          'courseCategory': data['courseCategory'] ?? '',
        });
      }

      setState(() {
        createdCourses = tempCourses;
        filteredCourses = tempCourses; // Initialize filtered courses
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching courses: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCreatedCourses();

    // Set up search controller listener
    searchController.addListener(() {
      if (!isLoading) {
        _filterCourses(searchController.text);
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Filter courses based on search query
  void _filterCourses(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredCourses = createdCourses;
      });
      return;
    }

    final searchText = query.toLowerCase();
    setState(() {
      filteredCourses = createdCourses.where((course) {
        final courseName = course['courseName']?.toString().toLowerCase() ?? '';
        final courseDescription =
            course['courseDescription']?.toString().toLowerCase() ?? '';
        final courseCategory =
            course['courseCategory']?.toString().toLowerCase() ?? '';

        return courseName.contains(searchText) ||
            courseDescription.contains(searchText) ||
            courseCategory.contains(searchText);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = (screenWidth ~/ 400).clamp(1, 6);

    return SizedBox(
      width: MyUtility(context).width - 320,
      height: MyUtility(context).height - 80,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 300,
                  height: 50,
                  child: MySearchBar(
                    textController: searchController,
                    hintText: 'Search Course',
                    onChanged: (value) {
                      _filterCourses(value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Courses Grid
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredCourses.isEmpty
                      ? const Center(
                          child: Text(
                            'No courses created yet.',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        )
                      : SingleChildScrollView(
                          child: LayoutGrid(
                            columnSizes: List.generate(
                              crossAxisCount,
                              (_) => FlexibleTrackSize(1),
                            ),
                            rowSizes: List.generate(
                              (createdCourses.length / crossAxisCount).ceil(),
                              (_) => auto,
                            ),
                            rowGap: 20,
                            columnGap: 20,
                            children: [
                              for (var course in filteredCourses)
                                GestureDetector(
                                  onTap: () {
                                    print(
                                        "Navigating to Edit Course for ID: ${course['id']}");
                                    widget.changePageWithCourseId(
                                        2, course['id']);
                                  },
                                  child: DevelopedCourseEdit(
                                    courseName: course['courseName'],
                                    modulesComplete:
                                        course['moduleAmount'].toString(),
                                    courseDescription:
                                        course['courseDescription'],
                                    totalStudents: course['totalStudents'],
                                    moduleAmount:
                                        course['moduleAmount'].toString(),
                                    assessmentAmount:
                                        course['totalAssessments'],
                                    courseImage: course['courseImage'],
                                    onTap: () {},
                                    changePage: (index) =>
                                        widget.changePageWithCourseId(
                                            index, course['id']),
                                    courseStatus: course['status'],
                                    declineReason: course['declineReason'],
                                    previewPdfUrl: course['previewPdfUrl'],
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
