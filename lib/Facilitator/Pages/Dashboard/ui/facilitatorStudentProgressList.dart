import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../myutility.dart';
import 'studentProgressListItem.dart';
import 'FacilitatorStudentPopup.dart';

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

      QuerySnapshot studentSnapshot = await firestore
          .collection('Users')
          .doc(widget.facilitatorId)
          .collection('facilitatorStudents')
          .get();

      List<Map<String, dynamic>> studentList = [];

      for (var studentDoc in studentSnapshot.docs) {
        var studentData = studentDoc.data() as Map<String, dynamic>;
        String studentId = studentDoc.id;

        DocumentSnapshot facilitatorDoc =
            await firestore.collection('Users').doc(widget.facilitatorId).get();
        List<dynamic> facilitatorCourses =
            facilitatorDoc['facilitatorCourses'] ?? [];

        String assignedCourseId = '';
        String assignedCourseName = 'None Assigned';

        for (var course in facilitatorCourses) {
          String courseId = course['courseId'];
          DocumentSnapshot courseSnapshot =
              await firestore.collection('courses').doc(courseId).get();
          List<dynamic> courseStudents = courseSnapshot['students'] ?? [];

          if (courseStudents.any((s) => s['studentId'] == studentId)) {
            assignedCourseId = courseId;
            assignedCourseName =
                courseSnapshot['courseName'] ?? 'Unknown Course';
            break;
          }
        }

        double progress = 0.0;
        if (assignedCourseId.isNotEmpty) {
          print("Fetching modules for Course: $assignedCourseId");
          QuerySnapshot moduleSnapshot = await firestore
              .collection('courses')
              .doc(assignedCourseId)
              .collection('modules')
              .get();
          int totalModules = moduleSnapshot.docs.length;
          print("Total Modules Found: $totalModules");

          int totalRequiredSubmissions = 0;
          int totalSubmissions = 0;

          for (var module in moduleSnapshot.docs) {
            final moduleData = module.data() as Map<String, dynamic>;
            int moduleRequiredSubmissions = 0;

            if (moduleData['assessmentsPdfUrl'] != null &&
                moduleData['assessmentsPdfUrl'].isNotEmpty) {
              moduleRequiredSubmissions++;
            }
            if (moduleData['testSheetPdfUrl'] != null &&
                moduleData['testSheetPdfUrl'].isNotEmpty) {
              moduleRequiredSubmissions++;
            }

            totalRequiredSubmissions += moduleRequiredSubmissions;

            DocumentSnapshot submissionDoc = await firestore
                .collection('courses')
                .doc(assignedCourseId)
                .collection('modules')
                .doc(module.id)
                .collection('submissions')
                .doc(studentId)
                .get();

            if (!submissionDoc.exists) {
              print(
                  "No submission found for student: $studentId in module: ${module.id}");
              continue;
            }

            print(
                "Submission found for student: $studentId in module: ${module.id}");

            if (submissionDoc.data() != null &&
                submissionDoc.data() is Map<String, dynamic>) {
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
          }

          progress = totalRequiredSubmissions > 0
              ? (totalSubmissions / totalRequiredSubmissions).clamp(0.0, 1.0)
              : 0.0;

          print(
              "Student: $studentId | Course: $assignedCourseName | Modules: $totalModules | Required Submissions: $totalRequiredSubmissions | Submissions: $totalSubmissions | Progress: $progress");
        }

        studentList.add({
          'name': studentData['name'] ?? 'Unknown',
          'course': assignedCourseName,
          'progress': progress,
        });
      }

      setState(() {
        students = studentList;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching student progress: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MyUtility(context).height * 0.62 - 80,
      width: MyUtility(context).width * 0.78 - 310,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 2.0,
            spreadRadius: 2.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Student Progress',
                  style: GoogleFonts.kanit(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle_outline),
                  onPressed: () {
                    showStudentPopup(context, widget.facilitatorId);
                  },
                ),
              ],
            ),
            const SizedBox(height: 15),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : students.isEmpty
                      ? Center(child: Text("No students found."))
                      : ListView.builder(
                          itemCount: students.length,
                          itemBuilder: (context, index) {
                            final student = students[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: StudentProgressListItem(
                                studentName: student['name'],
                                courseName: student['course'],
                                progress: student['progress'],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
