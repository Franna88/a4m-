import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../myutility.dart';
import '../../../../Constants/myColors.dart';
import 'studentProgressListItem.dart';
import 'FacilitatorStudentPopup.dart';
import 'studentProgressReport.dart';

class FacilitatorStudentProgressList extends StatefulWidget {
  final String facilitatorId;
  const FacilitatorStudentProgressList(
      {super.key, required this.facilitatorId});

  @override
  State<FacilitatorStudentProgressList> createState() =>
      _FacilitatorStudentProgressListState();
}

class _FacilitatorStudentProgressListState
    extends State<FacilitatorStudentProgressList> {
  List<Map<String, dynamic>> students = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFacilitatorStudents();
  }

  Future<void> _fetchFacilitatorStudents() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // First fetch all facilitator students in a single query
      QuerySnapshot studentSnapshot = await firestore
          .collection('Users')
          .doc(widget.facilitatorId)
          .collection('facilitatorStudents')
          .get();

      if (studentSnapshot.docs.isEmpty) {
        if (!mounted) return;
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Get facilitator courses in a single query
      DocumentSnapshot facilitatorDoc =
          await firestore.collection('Users').doc(widget.facilitatorId).get();
      List<dynamic> facilitatorCourses =
          facilitatorDoc['facilitatorCourses'] ?? [];

      if (facilitatorCourses.isEmpty) {
        if (!mounted) return;
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Extract course IDs for batch querying
      List<String> courseIds = [];
      for (var course in facilitatorCourses) {
        courseIds.add(course['courseId']);
      }

      // Batch query for all courses
      List<Future<DocumentSnapshot>> courseFutures = [];
      for (String courseId in courseIds) {
        courseFutures.add(firestore.collection('courses').doc(courseId).get());
      }
      List<DocumentSnapshot> courseSnapshots = await Future.wait(courseFutures);

      // Create a map of courseId to courseName and students for quick lookup
      Map<String, Map<String, dynamic>> courseMap = {};
      for (var courseSnapshot in courseSnapshots) {
        if (courseSnapshot.exists) {
          courseMap[courseSnapshot.id] = {
            'name': courseSnapshot['courseName'] ?? 'Unknown Course',
            'students': courseSnapshot['students'] ?? [],
          };
        }
      }

      // Process each student
      List<Map<String, dynamic>> studentList = [];
      List<Future<void>> progressFutures = [];

      for (var studentDoc in studentSnapshot.docs) {
        var studentData = studentDoc.data() as Map<String, dynamic>;
        String studentId = studentDoc.id;

        // Find which course this student is in
        String assignedCourseId = '';
        String assignedCourseName = 'None Assigned';

        for (var courseId in courseMap.keys) {
          List<dynamic> courseStudents = courseMap[courseId]!['students'];
          if (courseStudents.any((s) => s['studentId'] == studentId)) {
            assignedCourseId = courseId;
            assignedCourseName = courseMap[courseId]!['name'];
            break;
          }
        }

        // Create a temporary student entry with progress 0
        Map<String, dynamic> studentEntry = {
          'id': studentId,
          'name': studentData['name'] ?? 'Unknown',
          'course': assignedCourseName,
          'courseId': assignedCourseId,
          'progress': 0.0,
        };

        studentList.add(studentEntry);

        // Only calculate progress if a course is assigned
        if (assignedCourseId.isNotEmpty) {
          int studentIndex = studentList.length - 1;

          // Calculate progress in a separate Future to be resolved later
          progressFutures.add(() async {
            try {
              QuerySnapshot moduleSnapshot = await firestore
                  .collection('courses')
                  .doc(assignedCourseId)
                  .collection('modules')
                  .get();

              int totalRequiredSubmissions = 0;
              int totalSubmissions = 0;

              // Process modules in batches to improve performance
              const batchSize = 5;
              List<String> moduleIds =
                  moduleSnapshot.docs.map((doc) => doc.id).toList();

              for (var i = 0; i < moduleIds.length; i += batchSize) {
                final end = (i + batchSize < moduleIds.length)
                    ? i + batchSize
                    : moduleIds.length;
                final batch = moduleIds.sublist(i, end);

                await Future.wait(batch.map((moduleId) async {
                  final moduleDoc = moduleSnapshot.docs
                      .firstWhere((doc) => doc.id == moduleId);
                  final moduleData = moduleDoc.data() as Map<String, dynamic>;

                  int moduleRequiredSubmissions = 0;
                  if (moduleData['assessmentsPdfUrl'] != null &&
                      moduleData['assessmentsPdfUrl'].toString().isNotEmpty) {
                    moduleRequiredSubmissions++;
                  }
                  if (moduleData['testSheetPdfUrl'] != null &&
                      moduleData['testSheetPdfUrl'].toString().isNotEmpty) {
                    moduleRequiredSubmissions++;
                  }

                  totalRequiredSubmissions += moduleRequiredSubmissions;

                  // Check for submissions
                  DocumentSnapshot submissionDoc = await firestore
                      .collection('courses')
                      .doc(assignedCourseId)
                      .collection('modules')
                      .doc(moduleId)
                      .collection('submissions')
                      .doc(studentId)
                      .get();

                  if (submissionDoc.exists && submissionDoc.data() != null) {
                    Map<String, dynamic> submissionData =
                        submissionDoc.data() as Map<String, dynamic>;

                    if (submissionData.containsKey('submittedAssessments')) {
                      List<dynamic> submittedAssessments =
                          submissionData['submittedAssessments'];
                      totalSubmissions += submittedAssessments.length;
                    }
                    if (submissionData.containsKey('submittedTestSheets')) {
                      List<dynamic> submittedTestSheets =
                          submissionData['submittedTestSheets'];
                      totalSubmissions += submittedTestSheets.length;
                    }
                  }
                }));
              }

              double progress = totalRequiredSubmissions > 0
                  ? (totalSubmissions / totalRequiredSubmissions)
                      .clamp(0.0, 1.0)
                  : 0.0;

              // Update the student's progress if the widget is still mounted
              if (mounted && studentIndex < studentList.length) {
                setState(() {
                  studentList[studentIndex]['progress'] = progress;
                });
              }

              print(
                  "Student: $studentId | Course: $assignedCourseName | Progress: $progress");
            } catch (e) {
              print("Error calculating progress for student $studentId: $e");
            }
          }());
        }
      }

      // Update UI with student list immediately, progress will update as it's calculated
      if (!mounted) return;
      setState(() {
        students = studentList;
        isLoading = false;
      });

      // Start calculating progress for all students
      await Future.wait(progressFutures);
    } catch (e) {
      print("Error fetching student progress: $e");
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  void _showStudentProgressReport(String studentId, String studentName,
      String courseId, String courseName) {
    showDialog(
      context: context,
      builder: (context) => StudentProgressReport(
        studentId: studentId,
        studentName: studentName,
        courseId: courseId,
        courseName: courseName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MyUtility(context).height * 0.55 - 80,
      width: MyUtility(context).width * 0.78 - 310,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Student Progress',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
          // List Section
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
                    ),
                  )
                : students.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No students found",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: StudentProgressListItem(
                              studentName: student['name'],
                              courseName: student['course'],
                              progress: student['progress'],
                              studentId: student['id'],
                              onViewReport: student['courseId'].isNotEmpty
                                  ? (studentId) => _showStudentProgressReport(
                                        studentId,
                                        student['name'],
                                        student['courseId'],
                                        student['course'],
                                      )
                                  : null,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
