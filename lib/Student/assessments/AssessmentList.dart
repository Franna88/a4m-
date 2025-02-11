import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:a4m/Student/assessments/assessmentsContainer.dart';

class AssessmentCourses extends StatefulWidget {
  final void Function(String courseId) onTap;
  final String studentId;
  final bool?
      filterByCompletion; // 🔹 null = show all, false = active, true = completed

  const AssessmentCourses({
    super.key,
    required this.onTap,
    required this.studentId,
    this.filterByCompletion,
  });

  @override
  State<AssessmentCourses> createState() => _AssessmentCoursesState();
}

class _AssessmentCoursesState extends State<AssessmentCourses> {
  late Future<List<Map<String, dynamic>>> _studentCoursesFuture;

  @override
  void initState() {
    super.initState();
    _studentCoursesFuture = fetchStudentCourses();
  }

  /// 🔹 Fetch student courses and check if they are completed
  Future<List<Map<String, dynamic>>> fetchStudentCourses() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('courses').get();

      List<Map<String, dynamic>> studentCourses = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        if (data.containsKey('students') && data['students'] is List) {
          final students = data['students'] as List<dynamic>;

          // Check if student is enrolled in this course
          if (students.any((student) =>
              student is Map<String, dynamic> &&
              student['studentId'] == widget.studentId)) {
            Map<String, dynamic> courseData = {'id': doc.id, ...data};

            // 🔹 Fetch module & assessment counts
            Map<String, dynamic> courseInfo =
                await getCourseModulesAndAssessments(doc.id);

            courseData['moduleCount'] = courseInfo['moduleCount'];
            courseData['assessmentCount'] = courseInfo['assessmentCount'];
            courseData['isCompleted'] = courseInfo['isCompleted'];

            studentCourses.add(courseData);
          }
        }
      }

      // 🔹 Filter courses based on completion status
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

  /// 🔹 Get **module count**, **assessment count**, and **completion status** for a course
  Future<Map<String, dynamic>> getCourseModulesAndAssessments(
      String courseId) async {
    int moduleCount = 0;
    int assessmentCount = 0;
    bool isCompleted = true; // Assume completed, will check later

    QuerySnapshot moduleSnapshot = await FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .collection('modules')
        .get();

    moduleCount = moduleSnapshot.docs.length;

    if (moduleCount == 0) {
      return {
        'moduleCount': 0,
        'assessmentCount': 0,
        'isCompleted': false,
      };
    }

    for (var module in moduleSnapshot.docs) {
      String moduleId = module.id;
      final moduleData = module.data() as Map<String, dynamic>;

      // 🔹 Count assessments in the module
      int moduleAssessments = 0;

      if (moduleData['assessmentsPdfUrl'] != null &&
          moduleData['assessmentsPdfUrl'].isNotEmpty) {
        moduleAssessments++;
      }

      if (moduleData['testSheetPdfUrl'] != null &&
          moduleData['testSheetPdfUrl'].isNotEmpty) {
        moduleAssessments++;
      }

      assessmentCount += moduleAssessments;

      // 🔹 Check if module is fully submitted & marked
      DocumentSnapshot submissionDoc = await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('modules')
          .doc(moduleId)
          .collection('submissions')
          .doc(widget.studentId)
          .get();

      if (!submissionDoc.exists) {
        isCompleted = false; // No submission → Not complete
        continue;
      }

      List<dynamic> submittedAssessments =
          submissionDoc['submittedAssessments'] ?? [];

      // 🔹 Every assessment in this module must have a mark
      bool allAssessmentsMarked =
          submittedAssessments.length == moduleAssessments &&
              submittedAssessments.every((assessment) =>
                  assessment.containsKey('mark') && assessment['mark'] != null);

      if (!allAssessmentsMarked) {
        isCompleted = false; // Missing marks → Not complete
      }
    }

    return {
      'moduleCount': moduleCount,
      'assessmentCount': assessmentCount,
      'isCompleted': isCompleted,
    };
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
          return Center(
            child: widget.filterByCompletion == true
                ? const Text('No courses completed.')
                : const Text('No courses found.'),
          );
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
