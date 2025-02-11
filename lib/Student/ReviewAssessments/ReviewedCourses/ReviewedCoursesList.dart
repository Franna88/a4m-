import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:a4m/Student/assessments/assessmentsContainer.dart';

class ReviewedCoursesList extends StatefulWidget {
  final void Function(String courseId) onTap;
  final String studentId;

  const ReviewedCoursesList({
    super.key,
    required this.onTap,
    required this.studentId,
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

        // Fetch the modules subcollection for each course
        QuerySnapshot moduleSnapshot = await FirebaseFirestore.instance
            .collection('courses')
            .doc(course['id'])
            .collection('modules')
            .get();

        moduleCount = moduleSnapshot.docs.length;

        for (var module in moduleSnapshot.docs) {
          final moduleData = module.data() as Map<String, dynamic>;

          // Count `assessmentsPdfUrl` if it exists and is not empty
          if (moduleData['assessmentsPdfUrl'] != null &&
              moduleData['assessmentsPdfUrl'].isNotEmpty) {
            assessmentCount++;
          }

          // Count `testSheetPdfUrl` if it exists and is not empty
          if (moduleData['testSheetPdfUrl'] != null &&
              moduleData['testSheetPdfUrl'].isNotEmpty) {
            assessmentCount++;
          }
        }

        // Add counts to the course map
        course['moduleCount'] = moduleCount;
        course['assessmentCount'] = assessmentCount;
      }

      return studentCourses;
    } catch (e) {
      debugPrint('❌ Error fetching student courses: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _studentCoursesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('❌ Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('⚠️ No courses found.'));
        }

        final courses = snapshot.data!;

        return ListView.builder(
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];

            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: AssessmentsContainer(
                courseName: course['courseName'] ?? 'No Name',
                courseImage: course['courseImageUrl'] ??
                    'https://via.placeholder.com/200',
                courseDescription:
                    course['courseDescription'] ?? 'No Description',
                moduleCount: course['moduleCount'].toString(),
                assessmentCount: course['assessmentCount'].toString(),
                onTap: () {
                  widget.onTap(course['id']);
                },
              ),
            );
          },
        );
      },
    );
  }
}
