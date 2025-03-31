import 'package:a4m/Student/StudentCertificates/CertificatesStudentContainer.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../Themes/Constants/myColors.dart';
import '../../Themes/text_style.dart';

class CertificatesMainStudent extends StatefulWidget {
  const CertificatesMainStudent({super.key});

  @override
  State<CertificatesMainStudent> createState() =>
      _CertificatesMainStudentState();
}

class _CertificatesMainStudentState extends State<CertificatesMainStudent> {
  bool isLoading = true;
  List<Map<String, dynamic>> completedCourses = [];
  final String studentId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    fetchCompletedCourses();
  }

  Future<void> fetchCompletedCourses() async {
    if (studentId.isEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('courses').get();

      List<Map<String, dynamic>> courses = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        if (data.containsKey('students') && data['students'] is List) {
          final students = data['students'] as List<dynamic>;

          // Check if student is enrolled in this course
          if (students.any((student) =>
              student is Map<String, dynamic> &&
              student['studentId'] == studentId)) {
            // Check if course is completed
            bool isCompleted = await checkCourseCompletion(doc.id);

            if (isCompleted) {
              // Get completion date if available, otherwise use current date
              String completionDate = await getCompletionDate(doc.id) ??
                  DateTime.now().toString().split(' ')[0];

              // Get certificate price (could be stored in course or fixed)
              String certificatePrice = data['certificatePrice'] ?? 'R 299';

              // Get module and assessment counts
              Map<String, dynamic> courseInfo =
                  await getCourseModulesAndAssessments(doc.id);

              courses.add({
                'id': doc.id,
                'courseName': data['courseName'] ?? 'Unnamed Course',
                'courseDescription':
                    data['courseDescription'] ?? 'No description available',
                'courseImageUrl':
                    data['courseImageUrl'] ?? 'images/course1.png',
                'completionDate': completionDate,
                'certificatePrice': certificatePrice,
                'moduleCount': courseInfo['moduleCount'],
                'assessmentCount': courseInfo['assessmentCount'],
              });
            }
          }
        }
      }

      setState(() {
        completedCourses = courses;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching completed courses: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<bool> checkCourseCompletion(String courseId) async {
    try {
      QuerySnapshot moduleSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('modules')
          .get();

      if (moduleSnapshot.docs.isEmpty) {
        return false;
      }

      for (var module in moduleSnapshot.docs) {
        String moduleId = module.id;

        // Check if this module has been submitted and graded
        DocumentSnapshot submissionDoc = await FirebaseFirestore.instance
            .collection('courses')
            .doc(courseId)
            .collection('modules')
            .doc(moduleId)
            .collection('submissions')
            .doc(studentId)
            .get();

        if (!submissionDoc.exists) {
          return false; // Not completed
        }

        List<dynamic> submittedAssessments =
            submissionDoc['submittedAssessments'] ?? [];

        // If any assessment is missing a mark, course is not complete
        if (submittedAssessments.any((assessment) =>
            !assessment.containsKey('mark') ||
            assessment['mark'] == null ||
            assessment['mark'].toString().isEmpty)) {
          return false;
        }
      }

      return true; // All modules completed and graded
    } catch (e) {
      print('Error checking course completion: $e');
      return false;
    }
  }

  Future<String?> getCompletionDate(String courseId) async {
    try {
      // Get the latest submission date as the completion date
      QuerySnapshot moduleSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('modules')
          .get();

      DateTime? latestSubmission;

      for (var module in moduleSnapshot.docs) {
        DocumentSnapshot submissionDoc = await FirebaseFirestore.instance
            .collection('courses')
            .doc(courseId)
            .collection('modules')
            .doc(module.id)
            .collection('submissions')
            .doc(studentId)
            .get();

        if (submissionDoc.exists) {
          Timestamp submitted = submissionDoc['submitted'] ?? Timestamp.now();
          DateTime submissionDate = submitted.toDate();

          if (latestSubmission == null ||
              submissionDate.isAfter(latestSubmission)) {
            latestSubmission = submissionDate;
          }
        }
      }

      return latestSubmission?.toString().split(' ')[0];
    } catch (e) {
      print('Error getting completion date: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> getCourseModulesAndAssessments(
      String courseId) async {
    try {
      QuerySnapshot moduleSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('modules')
          .get();

      int moduleCount = moduleSnapshot.docs.length;
      int assessmentCount = 0;

      for (var module in moduleSnapshot.docs) {
        final moduleData = module.data() as Map<String, dynamic>;
        if (moduleData['assessmentsPdfUrl'] != null &&
            moduleData['assessmentsPdfUrl'].isNotEmpty) {
          assessmentCount++;
        }
      }

      return {
        'moduleCount': moduleCount,
        'assessmentCount': assessmentCount,
      };
    } catch (e) {
      print('Error getting course modules and assessments: $e');
      return {
        'moduleCount': 0,
        'assessmentCount': 0,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = (screenWidth ~/ 400).clamp(1, 6);

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
                  // Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Certificates',
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

                  // Courses grid
                  Expanded(
                    child: isLoading
                        ? Center(child: CircularProgressIndicator())
                        : completedCourses.isEmpty
                            ? Center(
                                child: Text(
                                'You haven\'t completed any courses yet.\nComplete a course to get a certificate.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16),
                              ))
                            : SingleChildScrollView(
                                child: LayoutGrid(
                                  columnSizes: List.generate(
                                    crossAxisCount,
                                    (_) => FlexibleTrackSize(1),
                                  ),
                                  rowSizes: List.generate(
                                    (completedCourses.length / crossAxisCount)
                                        .ceil(),
                                    (_) => auto,
                                  ),
                                  rowGap: 20,
                                  columnGap: 20,
                                  children: [
                                    for (var course in completedCourses)
                                      SizedBox(
                                        width: 320,
                                        height: 340,
                                        child: CertificatesStudentContainer(
                                          imagePath: course['courseImageUrl'] ??
                                              'images/course1.png',
                                          courseName: course['courseName'],
                                          description:
                                              course['courseDescription'],
                                          price: course['certificatePrice'],
                                          assessmentCount:
                                              course['assessmentCount'],
                                          moduleCount: course['moduleCount'],
                                          completionDate:
                                              course['completionDate'],
                                          courseId: course['id'],
                                          studentId: studentId,
                                        ),
                                      ),
                                  ],
                                ),
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
