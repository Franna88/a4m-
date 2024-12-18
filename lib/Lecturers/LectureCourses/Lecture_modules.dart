import 'package:a4m/Lecturers/LectureCourses/Lecture_display_Module.dart';
import 'package:a4m/CommonComponents/inputFields/mySearchBar.dart';
import 'package:a4m/myutility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:url_launcher/url_launcher.dart';

class LectureModulesContainer extends StatefulWidget {
  final Function(int, {String courseId, String moduleId}) changePage;

  final String courseId;

  const LectureModulesContainer({
    super.key,
    required this.changePage,
    required this.courseId,
  });

  @override
  State<LectureModulesContainer> createState() =>
      _LectureModulesContainerState();
}

class _LectureModulesContainerState extends State<LectureModulesContainer> {
  List<Map<String, dynamic>> modules = [];
  bool isLoading = true;

  // Fetch modules dynamically from Firestore
  Future<void> fetchModules() async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('modules')
          .get();

      modules = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add document ID to the module data
        return data;
      }).toList();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching modules: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Launch URL for downloading PDFs
  Future<void> _downloadFile(String url) async {
    if (url != null && url.isNotEmpty && await canLaunch(url)) {
      await launch(url);
    } else {
      print("Failed to launch URL: $url");
    }
  }

  @override
  void initState() {
    super.initState();
    print("Course ID for Modules: ${widget.courseId}"); // Debugging
    fetchModules();
  }

  @override
  Widget build(BuildContext context) {
    final courseSearch = TextEditingController();
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = (screenWidth ~/ 400).clamp(1, 6);

    return Container(
      width: MyUtility(context).width - 320,
      height: MyUtility(context).height - 80,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            Row(
              children: [
                SizedBox(
                  width: 300,
                  height: 50,
                  child: MySearchBar(
                    textController: courseSearch,
                    hintText: 'Search Module',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Grid Layout for Modules
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: LayoutGrid(
                        columnSizes: List.generate(
                          crossAxisCount,
                          (_) => FlexibleTrackSize(1),
                        ),
                        rowSizes: List.generate(
                          (modules.length / crossAxisCount).ceil(),
                          (_) => auto,
                        ),
                        rowGap: 20,
                        columnGap: 20,
                        children: [
                          for (var module in modules)
                            SizedBox(
                              width: 320,
                              height: 340,
                              child: LectureDisplayModule(
                                courseName: module['moduleName'] ?? 'No Name',
                                modulesComplete: '3', // Default for now
                                courseDescription:
                                    module['moduleDescription'] ??
                                        'No Description',
                                totalStudents: '30', // Placeholder
                                moduleAmount: '5',
                                assessmentAmount: '2',
                                courseImage: module['moduleImageUrl'] ??
                                    'assets/placeholder_image.png',
                                onTap: () {
                                  print(
                                      "Navigating to Module ID: ${module['id']}"); // Verify module['id']
                                  widget.changePage(5,
                                      courseId: widget.courseId,
                                      moduleId: module['id']);
                                },

                                changePage: widget.changePage,
                                onActivitiesTap: () => _downloadFile(
                                    module['activitiesPdfUrl'] ?? ''),
                                onAssessmentsTap: () => _downloadFile(
                                    module['assessmentsPdfUrl'] ?? ''),
                                onTestSheetTap: () => _downloadFile(
                                    module['testSheetPdfUrl'] ?? ''),
                                onAnswerSheetTap: () => _downloadFile(
                                    module['answerSheetPdfUrl'] ?? ''),
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
