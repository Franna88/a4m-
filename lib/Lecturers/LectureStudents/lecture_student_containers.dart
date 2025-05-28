import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_network/image_network.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../CommonComponents/displayCardIcons.dart';
import '../../../Constants/myColors.dart';

class LectureStudentContainers extends StatefulWidget {
  final bool? isLecturer;
  final bool? isContentDev;
  final bool? isFacilitator;
  final bool? isStudent;
  final String image;
  final String name;
  final String number;
  final String userId;
  final String? studentAmount;
  final String? contentTotal;
  final String? rating;
  final VoidCallback? onMessageTap;
  final String lecturerId;
  final List<Map<String, dynamic>> lecturerCourses;
  const LectureStudentContainers({
    super.key,
    this.isLecturer,
    this.isContentDev,
    this.isFacilitator,
    this.isStudent,
    required this.image,
    required this.name,
    required this.number,
    required this.userId,
    this.studentAmount,
    this.contentTotal,
    this.rating,
    this.onMessageTap,
    required this.lecturerId,
    required this.lecturerCourses,
  });

  @override
  State<LectureStudentContainers> createState() =>
      _LectureStudentContainersState();
}

class _LectureStudentContainersState extends State<LectureStudentContainers> {
  void _showStudentInfoDialog() async {
    final userId = widget.userId;
    if (userId.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('No user ID provided.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text('Close'))
          ],
        ),
      );
      return;
    }

    List<Map<String, dynamic>> courseProgress = [];

    for (var course in widget.lecturerCourses) {
      final courseId = course['id'];
      final courseName = course['name'];
      final studentsList = (course['students'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((student) => student['studentId'] as String?)
          .where((id) => id != null)
          .cast<String>()
          .toList();
      if (!studentsList.contains(userId)) continue;
      int submittedAssessments = 0;
      int totalAssessments = 0;
      int submittedTests = 0;
      int totalTests = 0;

      // Get all modules for this course
      final modulesSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('modules')
          .get();

      for (var moduleDoc in modulesSnapshot.docs) {
        final moduleData = moduleDoc.data();
        // Count if this module has an assessment
        if (moduleData['assessmentsPdfUrl'] != null &&
            (moduleData['assessmentsPdfUrl'] as String).isNotEmpty) {
          totalAssessments++;
        }
        if (moduleData['testSheetPdfUrl'] != null &&
            (moduleData['testSheetPdfUrl'] as String).isNotEmpty) {
          totalTests++;
        }
        // For each module, get the submission for this student
        final submissionDoc = await moduleDoc.reference
            .collection('submissions')
            .doc(userId)
            .get();
        if (submissionDoc.exists) {
          final submissionData = submissionDoc.data();
          final submittedAssessmentsArr =
              submissionData?['submittedAssessments'] ?? [];
          for (var assessment in submittedAssessmentsArr) {
            if (assessment['assessmentName'] != null &&
                moduleData['assessmentsPdfUrl'] != null &&
                (moduleData['assessmentsPdfUrl'] as String).isNotEmpty) {
              submittedAssessments++;
            }
            if (assessment['assessmentName'] != null &&
                moduleData['testSheetPdfUrl'] != null &&
                (moduleData['testSheetPdfUrl'] as String).isNotEmpty) {
              submittedTests++;
            }
          }
        }
      }

      courseProgress.add({
        'courseName': courseName,
        'submittedAssessments': submittedAssessments,
        'totalAssessments': totalAssessments,
        'submittedTests': submittedTests,
        'totalTests': totalTests,
      });
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Student Progress',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (courseProgress.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      'No progress data found for this student in your assigned courses.',
                      style: GoogleFonts.montserrat(color: Colors.grey[700]),
                    ),
                  ),
                for (var course in courseProgress) ...[
                  Text('${course['courseName']}',
                      style:
                          GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text('Assessments: ', style: GoogleFonts.montserrat()),
                      Text(
                          '${course['submittedAssessments']}/${course['totalAssessments']}',
                          style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold)),
                      const SizedBox(width: 16),
                      Text('Tests: ', style: GoogleFonts.montserrat()),
                      Text(
                          '${course['submittedTests']}/${course['totalTests']}',
                          style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(15),
      elevation: 5,
      child: Container(
        height: 310,
        width: 250,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 250,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                child: Stack(
                  children: [
                    // Profile Image
                    Positioned.fill(
                      child: widget.image.startsWith('http') &&
                              widget.image.isNotEmpty
                          ? ImageNetwork(
                              image: widget.image,
                              fitWeb: BoxFitWeb.cover,
                              fitAndroidIos: BoxFit.cover,
                              height: 180,
                              width: 250,
                              duration: 500,
                              onLoading: const Center(
                                child: CircularProgressIndicator(),
                              ),
                              onError: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  image: const DecorationImage(
                                    image: AssetImage('images/person2.png'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('images/person2.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                    ),
                    // Gradient Overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Mycolors().green,
                              const Color.fromARGB(0, 255, 255, 255),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.name,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: widget.onMessageTap,
              icon: Icon(
                Icons.mail_outline, // Replace with your desired icon
                color: Colors.white, // White icon
                size: 25,
              ),
              label: Text(
                'Message', // Replace with your desired text
                style: TextStyle(
                  color: Colors.white, // White text
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4880FF), // Button background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0), // Rounded corners
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                width: 300,
                height: 2,
                color: const Color.fromARGB(255, 189, 189, 189),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: DisplayCardIcons(
                    icon: Icons.book_outlined,
                    count: widget.studentAmount ?? '0',
                    tooltipText: 'Courses',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.school_outlined,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Student',
                        style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600),
                      ),
                      IconButton(
                        icon: const Icon(Icons.info_outline,
                            size: 18, color: Colors.grey),
                        tooltip: 'View Progress',
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        onPressed: _showStudentInfoDialog,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
