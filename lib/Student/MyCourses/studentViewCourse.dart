import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Constants/myColors.dart';
import '../../Themes/text_style.dart';
import '../../CommonComponents/buttons/slimButtons.dart';
import '../../myutility.dart';
import '../commonUi/studentModuleContainer.dart';
import '../commonUi/pdfViewer.dart';
import '../ReviewAssessments/CourseEvaluation/CourseEvaluationForm.dart';

class StudentViewCourse extends StatefulWidget {
  final String courseId; // Pass the selected course's ID

  const StudentViewCourse({super.key, required this.courseId});

  @override
  State<StudentViewCourse> createState() => _StudentViewCourseState();
}

class _StudentViewCourseState extends State<StudentViewCourse> {
  late Future<List<Map<String, dynamic>>> _modulesFuture;
  late Future<Map<String, dynamic>> _courseFuture;

  @override
  void initState() {
    super.initState();
    _modulesFuture = fetchModules();
    _courseFuture = fetchCourseDetails();
  }

  Future<Map<String, dynamic>> fetchCourseDetails() async {
    try {
      DocumentSnapshot courseDoc = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .get();

      if (courseDoc.exists) {
        return {
          'id': courseDoc.id,
          ...courseDoc.data() as Map<String, dynamic>
        };
      }
      return {};
    } catch (e) {
      debugPrint('Error fetching course details: $e');
      return {};
    }
  }

  // Fetch modules for the current course
  Future<List<Map<String, dynamic>>> fetchModules() async {
    try {
      // Get the modules subcollection for the selected course
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('modules')
          .get();

      // Map the documents to a list of module data
      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      debugPrint('Error fetching modules: $e');
      return [];
    }
  }

  // Helper method to open URLs
  void _launchUrl(String url) async {
    final Uri uri = Uri.parse(url); // Parse the URL into a Uri object
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode
            .externalApplication, // Ensures the default browser is used
      );
    } else {
      debugPrint('Unable to open the URL: $url');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open the file.')),
      );
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
              color: Colors.white,
              border: Border.all(width: 0.8),
            ),
            width: MyUtility(context).width,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<Map<String, dynamic>>(
                    future: _courseFuture,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }

                      final courseData = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                courseData['courseName'] ?? 'Course Details',
                                style: MyTextStyles(context).subHeaderBlack,
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => Dialog(
                                      child: CourseEvaluationForm(
                                        courseId: widget.courseId,
                                        courseName: courseData['courseName'] ??
                                            'Unknown Course',
                                        studentId: FirebaseAuth
                                                .instance.currentUser?.uid ??
                                            '',
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.rate_review),
                                label: const Text('Evaluate Course'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Mycolors().darkTeal,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    },
                  ),
                  // Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Modules',
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

                  // Modules Grid
                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: _modulesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(child: Text('No modules found.'));
                        }

                        final modules = snapshot.data!;

                        return SingleChildScrollView(
                          child: LayoutGrid(
                            columnSizes: List.generate(
                              crossAxisCount,
                              (_) =>
                                  FlexibleTrackSize(1), // Use FlexibleTrackSize
                            ),
                            rowSizes: List.generate(
                              (modules.length / crossAxisCount).ceil(),
                              (_) => auto, // Auto height for each row
                            ),
                            rowGap: 20, // Space between rows
                            columnGap: 20, // Space between columns
                            children: [
                              for (var module in modules)
                                SizedBox(
                                  width: 320,
                                  height: 340,
                                  child: StudentModuleContainer(
                                    moduleName:
                                        module['moduleName'] ?? 'No Name',
                                    moduleDescription:
                                        module['moduleDescription'] ??
                                            'No Description',
                                    moduleImage: module['moduleImageUrl'] ??
                                        'images/placeholder.png',
                                    assessmentAmount:
                                        (module['assessmentsPdfUrl'] != null
                                                ? 1
                                                : 0)
                                            .toString(),
                                    studentGuidePdfUrl: () {
                                      if (module['studentGuidePdfUrl'] !=
                                          null) {
                                        debugPrint(
                                            'Opening Student Guide PDF: ${module['studentGuidePdfUrl']}');
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Scaffold(
                                              appBar: AppBar(
                                                title: Text('Student Guide'),
                                                backgroundColor:
                                                    Mycolors().darkGrey,
                                              ),
                                              body: StudentPdfViewer(
                                                pdfUrl: module[
                                                    'studentGuidePdfUrl']!,
                                                title: 'Student Guide',
                                                showDownloadButton: false,
                                              ),
                                            ),
                                          ),
                                        );
                                      } else {
                                        debugPrint(
                                            'Student Guide PDF URL is null');
                                      }
                                    },
                                    testSheetPdfUrl: () {
                                      if (module['testSheetPdfUrl'] != null) {
                                        debugPrint(
                                            'Opening Test Sheet PDF: ${module['testSheetPdfUrl']}');
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Scaffold(
                                              appBar: AppBar(
                                                title: Text('Test Sheet'),
                                                backgroundColor:
                                                    Mycolors().darkGrey,
                                              ),
                                              body: StudentPdfViewer(
                                                pdfUrl:
                                                    module['testSheetPdfUrl']!,
                                                title: 'Test Sheet',
                                                showDownloadButton: true,
                                              ),
                                            ),
                                          ),
                                        );
                                      } else {
                                        debugPrint(
                                            'Test Sheet PDF URL is null');
                                      }
                                    },
                                    assessmentsPdfUrl: () {
                                      if (module['assessmentsPdfUrl'] != null) {
                                        debugPrint(
                                            'Opening Assessments PDF: ${module['assessmentsPdfUrl']}');
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Scaffold(
                                              appBar: AppBar(
                                                title: Text('Assessment'),
                                                backgroundColor:
                                                    Mycolors().darkGrey,
                                              ),
                                              body: StudentPdfViewer(
                                                pdfUrl: module[
                                                    'assessmentsPdfUrl']!,
                                                title: 'Assessment',
                                                showDownloadButton: true,
                                              ),
                                            ),
                                          ),
                                        );
                                      } else {
                                        debugPrint(
                                            'Assessments PDF URL is null');
                                      }
                                    },
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
