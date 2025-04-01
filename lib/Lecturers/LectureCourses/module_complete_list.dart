import 'package:a4m/CommonComponents/buttons/slimButtons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:a4m/Constants/myColors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:a4m/TableWidgets/tableStructure.dart';
import 'package:url_launcher/url_launcher.dart';

class ModuleCompleteList extends StatefulWidget {
  final String courseId;
  final String moduleId; // Added moduleId parameter

  const ModuleCompleteList({
    super.key,
    required this.courseId,
    required this.moduleId,
  });

  @override
  State<ModuleCompleteList> createState() => _ModuleCompleteListState();
}

class _ModuleCompleteListState extends State<ModuleCompleteList> {
  List<Map<String, dynamic>> submissions = [];
  String courseName = '';
  String moduleName = '';
  bool isLoading = true;

  Future<void> fetchStudentSubmissions() async {
    print("Starting fetchStudentSubmissions");
    print("CourseId: ${widget.courseId}");
    print("ModuleId: ${widget.moduleId}");

    try {
      // Fetch course details
      var courseDoc = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .get();

      if (!courseDoc.exists) {
        print("Course not found for ID: ${widget.courseId}");
        setState(() {
          isLoading = false;
        });
        return;
      }
      print("Course found: ${courseDoc.data()?['courseName']}");
      courseName = courseDoc.data()?['courseName'] ?? 'No Course Name';

      // Fetch module details
      var moduleDoc = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('modules')
          .doc(widget.moduleId)
          .get();

      if (!moduleDoc.exists) {
        print("Module not found for ID: ${widget.moduleId}");
        setState(() {
          isLoading = false;
        });
        return;
      }
      print("Module found: ${moduleDoc.data()?['moduleName']}");
      final moduleData = moduleDoc.data();
      moduleName = moduleData?['moduleName'] ?? 'No Module Name';

      // Get all submissions from the submissions subcollection
      var submissionsSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('modules')
          .doc(widget.moduleId)
          .collection('submissions')
          .get();

      print("Found ${submissionsSnapshot.docs.length} submission documents");
      List<Map<String, dynamic>> tempSubmissions = [];

      for (var submissionDoc in submissionsSnapshot.docs) {
        print("Processing submission for student: ${submissionDoc.id}");
        if (!submissionDoc.exists) continue;

        final submissionData = submissionDoc.data();
        if (submissionData == null) continue;

        final submittedAssessments =
            submissionData['submittedAssessments'] as List<dynamic>?;
        if (submittedAssessments == null) continue;

        print("Found ${submittedAssessments.length} assessments in submission");

        for (var assessment in submittedAssessments) {
          if (assessment == null || assessment is! Map<String, dynamic>)
            continue;

          final submittedTimestamp = assessment['submittedAt'];
          String submittedDate;
          if (submittedTimestamp is Timestamp) {
            submittedDate =
                submittedTimestamp.toDate().toString().split(' ')[0];
          } else if (submittedTimestamp is String) {
            submittedDate = submittedTimestamp;
          } else {
            submittedDate = 'Unknown Date';
          }

          tempSubmissions.add({
            'student': assessment['studentName'] ?? 'Unknown Student',
            'date': submittedDate,
            'course': courseName,
            'module': moduleName,
            'assessment': assessment['assessmentName'] ?? 'Unknown Assessment',
            'fileUrl': assessment['fileUrl'] ?? '',
            'mark': assessment['mark'] ?? '',
            'comment': assessment['comment'] ?? '',
            'submissionId': submissionDoc.id,
            'assessmentIndex': submittedAssessments.indexOf(assessment),
          });
          print("Added submission for student: ${assessment['studentName']}");
        }
      }

      print("Total processed submissions: ${tempSubmissions.length}");

      setState(() {
        submissions = tempSubmissions;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching submissions: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _openGradeDialog(Map<String, dynamic> submission) {
    final TextEditingController markController =
        TextEditingController(text: submission['mark']);
    final TextEditingController commentController =
        TextEditingController(text: submission['comment']);

    bool isReadOnly =
        submission['mark'].isNotEmpty && submission['comment'].isNotEmpty;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Grade Assessment',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: markController,
                    decoration: const InputDecoration(labelText: 'Mark'),
                    keyboardType: TextInputType.number,
                    readOnly: isReadOnly,
                  ),
                  TextField(
                    controller: commentController,
                    decoration: const InputDecoration(labelText: 'Comment'),
                    maxLines: 2,
                    readOnly: isReadOnly,
                  ),
                ],
              ),
              actions: [
                if (isReadOnly)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isReadOnly = false;
                      });
                    },
                    child: const Text('Edit'),
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                if (!isReadOnly)
                  TextButton(
                    onPressed: () async {
                      await _updateGrade(submission, markController.text,
                          commentController.text);
                      Navigator.pop(context);
                    },
                    child: const Text('Submit'),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateGrade(
      Map<String, dynamic> submission, String mark, String comment) async {
    try {
      final submissionRef = FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('modules')
          .doc(widget.moduleId)
          .collection('submissions')
          .doc(submission['submissionId']);

      DocumentSnapshot doc = await submissionRef.get();
      if (!doc.exists) {
        print("Submission document not found.");
        return;
      }

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      List<dynamic> submittedAssessments =
          List.from(data['submittedAssessments'] ?? []);
      int assessmentIndex = submission['assessmentIndex'];

      if (assessmentIndex >= 0 &&
          assessmentIndex < submittedAssessments.length) {
        submittedAssessments[assessmentIndex] = {
          ...submittedAssessments[assessmentIndex],
          'mark': mark,
          'comment': comment,
        };

        await submissionRef.update({
          'submittedAssessments': submittedAssessments,
        });

        // Update local state
        setState(() {
          submissions = submissions.map((s) {
            if (s['submissionId'] == submission['submissionId'] &&
                s['assessmentIndex'] == assessmentIndex) {
              return {
                ...s,
                'mark': mark,
                'comment': comment,
              };
            }
            return s;
          }).toList();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Grade updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("Error updating grade: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating grade: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.courseId.isNotEmpty && widget.moduleId.isNotEmpty) {
      fetchStudentSubmissions();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : submissions.isEmpty
            ? const Center(
                child: Text(
                  'No submissions found for this module.',
                  style: TextStyle(fontSize: 16),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Student Submissions - $moduleName',
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataTable(
                      columns: const [
                        DataColumn(label: Text('Student')),
                        DataColumn(label: Text('Submission Date')),
                        DataColumn(label: Text('Mark')),
                        DataColumn(label: Text('Comment')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: submissions.map((submission) {
                        return DataRow(
                          cells: [
                            DataCell(Text(submission['student'] ?? 'Unknown',
                                style: GoogleFonts.montserrat())),
                            DataCell(Text(submission['date'] ?? '',
                                style: GoogleFonts.montserrat())),
                            DataCell(Text(submission['mark'] ?? 'Not graded',
                                style: GoogleFonts.montserrat())),
                            DataCell(
                              Text(
                                submission['comment'] ?? 'No comment',
                                style: GoogleFonts.montserrat(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DataCell(
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  if (submission['fileUrl']?.isNotEmpty ??
                                      false)
                                    IconButton(
                                      icon: const Icon(Icons.visibility),
                                      onPressed: () async {
                                        final url = submission['fileUrl'];
                                        if (url != null && url.isNotEmpty) {
                                          if (await canLaunch(url)) {
                                            await launch(url);
                                          }
                                        }
                                      },
                                      tooltip: 'View Submission',
                                    ),
                                  IconButton(
                                    icon: Icon(
                                      submission['mark']?.isNotEmpty ?? false
                                          ? Icons.edit
                                          : Icons.grade,
                                      color: Mycolors().green,
                                    ),
                                    onPressed: () =>
                                        _openGradeDialog(submission),
                                    tooltip:
                                        submission['mark']?.isNotEmpty ?? false
                                            ? 'Edit Grade'
                                            : 'Grade Submission',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
  }
}
