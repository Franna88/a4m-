import 'package:a4m/Facilitator/Pages/MyCourses/commonUi/facilitatorModuleContainer.dart';
import 'package:a4m/Student/commonUi/pdfViewer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../Constants/myColors.dart';

class FacilitatorViewCourse extends StatefulWidget {
  final String courseId;

  const FacilitatorViewCourse({super.key, required this.courseId});

  @override
  State<FacilitatorViewCourse> createState() => _FacilitatorViewCourseState();
}

class _FacilitatorViewCourseState extends State<FacilitatorViewCourse> {
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

  Future<List<Map<String, dynamic>>> fetchModules() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('modules')
          .get();

      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      debugPrint('Error fetching modules: $e');
      return [];
    }
  }

  void _openPdf(BuildContext context, String pdfUrl, String title) {
    if (pdfUrl.isNotEmpty) {
      Navigator.of(context, rootNavigator: false).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: Mycolors().darkGrey,
            ),
            body: StudentPdfViewer(
              pdfUrl: pdfUrl,
              title: title,
              showDownloadButton: true,
            ),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'PDF not available',
            style: GoogleFonts.poppins(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = (screenWidth ~/ 400).clamp(1, 3);

    return Container(
      width: screenWidth - 320,
      height: MediaQuery.of(context).size.height - 80,
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<Map<String, dynamic>>(
                future: _courseFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final courseData = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            courseData['courseName'] ?? 'Course Details',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'My Course Modules',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 10),
              Divider(
                color: Mycolors().green,
                thickness: 4,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _modulesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: GoogleFonts.poppins(color: Colors.red),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          'No modules found.',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      );
                    }

                    final modules = snapshot.data!;

                    return SingleChildScrollView(
                      child: LayoutGrid(
                        columnSizes: List.generate(
                          crossAxisCount,
                          (_) => const FlexibleTrackSize(1),
                        ),
                        rowSizes: List.generate(
                          (modules.length / crossAxisCount).ceil(),
                          (_) => auto,
                        ),
                        rowGap: 20,
                        columnGap: 20,
                        children: [
                          for (var module in modules)
                            FacilitatorModuleContainer(
                              moduleName: module['moduleName'] ?? 'No Name',
                              moduleDescription: module['moduleDescription'] ??
                                  'No Description',
                              moduleImage: module['moduleImageUrl'] ??
                                  'https://picsum.photos/400',
                              assessmentAmount:
                                  (module['assessmentsPdfUrl'] != null ? 1 : 0)
                                      .toString(),
                              facilitatorGuidePdfUrl: () => _openPdf(
                                context,
                                module['facilitatorGuidePdfUrl'] ?? '',
                                'Facilitator Guide',
                              ),
                              testSheetPdfUrl: () => _openPdf(
                                context,
                                module['testSheetPdfUrl'] ?? '',
                                'Test Sheet',
                              ),
                              assessmentsPdfUrl: () => _openPdf(
                                context,
                                module['assessmentsPdfUrl'] ?? '',
                                'Assessments',
                              ),
                              answerSheetPdfUrl: () => _openPdf(
                                context,
                                module['answerSheetPdfUrl'] ?? '',
                                'Answer Sheet',
                              ),
                              assignmentsPdfUrl: () => _openPdf(
                                context,
                                module['assignmentsPdfUrl'] ?? '',
                                'Assignments',
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
    );
  }
}
