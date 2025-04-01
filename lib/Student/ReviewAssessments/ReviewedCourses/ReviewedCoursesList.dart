import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:a4m/Student/assessments/assessmentsContainer.dart';
import 'package:google_fonts/google_fonts.dart';

class ReviewedCoursesList extends StatefulWidget {
  final void Function(String courseId) onTap;
  final String studentId;
  final bool?
      filterByCompletion; // null = show all, false = active, true = completed

  const ReviewedCoursesList({
    super.key,
    required this.onTap,
    required this.studentId,
    this.filterByCompletion,
  });

  @override
  State<ReviewedCoursesList> createState() => _ReviewedCoursesListState();
}

class _ReviewedCoursesListState extends State<ReviewedCoursesList> {
  late Future<List<Map<String, dynamic>>> _studentCoursesFuture;

  @override
  void initState() {
    super.initState();
    _studentCoursesFuture = fetchStudentCourses();
  }

  // 🔹 Fetch courses that the student is enrolled in and count modules/assessments
  Future<List<Map<String, dynamic>>> fetchStudentCourses() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('courses').get();

      List<Map<String, dynamic>> studentCourses = snapshot.docs
          .where((doc) {
            final data = doc.data() as Map<String, dynamic>;

            if (data.containsKey('students') && data['students'] is List) {
              final students = data['students'] as List<dynamic>;

              return students.any((student) {
                if (student is Map<String, dynamic>) {
                  return student['studentId'] == widget.studentId;
                }
                return false;
              });
            }
            return false;
          })
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();

      // Count modules and total assessments (`assessmentsPdfUrl` & `testSheetPdfUrl`)
      for (var course in studentCourses) {
        int moduleCount = 0;
        int assessmentCount = 0;
        int completedAssessments = 0;

        // Fetch the modules subcollection for each course
        QuerySnapshot moduleSnapshot = await FirebaseFirestore.instance
            .collection('courses')
            .doc(course['id'])
            .collection('modules')
            .get();

        moduleCount = moduleSnapshot.docs.length;

        for (var module in moduleSnapshot.docs) {
          final moduleData = module.data() as Map<String, dynamic>;

          // Count assessments
          if (moduleData['assessmentsPdfUrl'] != null &&
              moduleData['assessmentsPdfUrl'].isNotEmpty) {
            assessmentCount++;

            // Check if assessment is completed
            QuerySnapshot reviewSnapshot = await FirebaseFirestore.instance
                .collection('courses')
                .doc(course['id'])
                .collection('modules')
                .doc(module.id)
                .collection('reviews')
                .where('studentId', isEqualTo: widget.studentId)
                .get();

            if (reviewSnapshot.docs.isNotEmpty) {
              completedAssessments++;
            }
          }

          // Count test sheets
          if (moduleData['testSheetPdfUrl'] != null &&
              moduleData['testSheetPdfUrl'].isNotEmpty) {
            assessmentCount++;

            // Check if test is completed
            QuerySnapshot testReviewSnapshot = await FirebaseFirestore.instance
                .collection('courses')
                .doc(course['id'])
                .collection('modules')
                .doc(module.id)
                .collection('testReviews')
                .where('studentId', isEqualTo: widget.studentId)
                .get();

            if (testReviewSnapshot.docs.isNotEmpty) {
              completedAssessments++;
            }
          }
        }

        // Add counts to the course map
        course['moduleCount'] = moduleCount;
        course['assessmentCount'] = assessmentCount;
        course['completedAssessments'] = completedAssessments;
        course['isCompleted'] =
            completedAssessments == assessmentCount && assessmentCount > 0;
      }

      // Filter courses based on completion status if specified
      if (widget.filterByCompletion != null) {
        studentCourses = studentCourses
            .where(
                (course) => course['isCompleted'] == widget.filterByCompletion)
            .toList();
      }

      return studentCourses;
    } catch (e) {
      debugPrint('❌ Error fetching student courses: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _studentCoursesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                '❌ Error: ${snapshot.error}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.red,
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                widget.filterByCompletion == null
                    ? '⚠️ No courses found.'
                    : widget.filterByCompletion!
                        ? '⚠️ No completed courses found.'
                        : '⚠️ No active courses found.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            );
          }

          final courses = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: AssessmentsContainer(
                  courseName: course['courseName'] ?? 'No Name',
                  courseImage: course['courseImageUrl'] ??
                      'https://via.placeholder.com/200',
                  courseDescription:
                      course['courseDescription'] ?? 'No Description',
                  moduleCount: course['moduleCount'].toString(),
                  assessmentCount: course['assessmentCount'].toString(),
                  completedAssessments:
                      course['completedAssessments'].toString(),
                  isCompleted: course['isCompleted'],
                  onTap: () {
                    widget.onTap(course['id']);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
