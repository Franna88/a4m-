import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:a4m/Constants/myColors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:a4m/TableWidgets/tableStructure.dart';
import 'package:url_launcher/url_launcher.dart';

class SubmitComplete extends StatefulWidget {
  final String courseId;
  final String moduleId;
  final String studentId;

  const SubmitComplete({
    super.key,
    required this.courseId,
    required this.moduleId,
    required this.studentId,
  });

  @override
  State<SubmitComplete> createState() => _SubmitCompleteState();
}

class _SubmitCompleteState extends State<SubmitComplete> {
  List<Map<String, dynamic>> submissions = [];
  String courseName = '';
  String moduleName = '';
  bool isLoading = true;

  Future<void> fetchStudentSubmissions() async {
    try {
      // Fetch course details
      var courseDoc = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .get();

      courseName = courseDoc.data()?['courseName'] ?? 'No Course Name';

      // Fetch specific module using moduleId
      var moduleDoc = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('modules')
          .doc(widget.moduleId)
          .get();

      if (moduleDoc.exists) {
        final moduleData = moduleDoc.data() as Map<String, dynamic>;
        moduleName = moduleData['moduleName'] ?? 'No Module Name';

        // Get submissions from the submissions subcollection
        var submissionDoc = await FirebaseFirestore.instance
            .collection('courses')
            .doc(widget.courseId)
            .collection('modules')
            .doc(widget.moduleId)
            .collection('submissions')
            .doc(widget.studentId)
            .get();

        List<Map<String, dynamic>> tempSubmissions = [];

        if (submissionDoc.exists) {
          final submissionData = submissionDoc.data() as Map<String, dynamic>;
          final submittedAssessments =
              submissionData['submittedAssessments'] as List<dynamic>?;

          if (submittedAssessments != null) {
            for (var assessment in submittedAssessments) {
              if (assessment is Map<String, dynamic>) {
                tempSubmissions.add({
                  'student': assessment['studentName'] ?? 'Unknown Student',
                  'date': assessment['submittedAt'] != null &&
                          assessment['submittedAt'] is Timestamp
                      ? (assessment['submittedAt'] as Timestamp)
                          .toDate()
                          .toString()
                          .split(' ')[0]
                      : 'Unknown Date',
                  'course': courseName,
                  'module': moduleName,
                  'assessment': assessment['assessmentName'] ?? '',
                  'fileUrl': assessment['fileUrl'] ?? '',
                  'mark': assessment['mark']?.toString() ?? '',
                  'comment': assessment['comment'] ?? '',
                });
              }
            }
          }
        }

        setState(() {
          submissions = tempSubmissions;
          isLoading = false;
        });
      } else {
        print("Module not found for ID: ${widget.moduleId}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching submissions: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _openGradeDialog(Map<String, dynamic> submission, int index) {
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
                      await _updateGrade(
                          index, markController.text, commentController.text);
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

  Future<void> _updateGrade(int index, String mark, String comment) async {
    try {
      final submissionRef = FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('modules')
          .doc(widget.moduleId)
          .collection('submissions')
          .doc(widget.studentId);

      final submissionDoc = await submissionRef.get();
      if (!submissionDoc.exists) {
        throw Exception('Submission document not found');
      }

      final data = submissionDoc.data()!;
      final submittedAssessments =
          List<Map<String, dynamic>>.from(data['submittedAssessments'] ?? []);

      // Find the assessment to update
      final assessmentToUpdate = submissions[index];
      final assessmentIndex = submittedAssessments.indexWhere(
          (a) => a['assessmentName'] == assessmentToUpdate['assessment']);

      if (assessmentIndex == -1) {
        throw Exception('Assessment not found in submission document');
      }

      // Update the assessment
      submittedAssessments[assessmentIndex] = {
        ...submittedAssessments[assessmentIndex],
        'mark': mark,
        'comment': comment,
        'gradedAt': FieldValue.serverTimestamp(),
      };

      // Update Firestore
      await submissionRef.update({
        'submittedAssessments': submittedAssessments,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Update local state
      setState(() {
        submissions[index]['mark'] = mark;
        submissions[index]['comment'] = comment;
      });

      print("Grade updated successfully!");
    } catch (e) {
      print("Error updating grade: $e");
      throw e; // Re-throw to be caught by the calling function
    }
  }

  @override
  void initState() {
    super.initState();
    fetchStudentSubmissions();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              // Table Header
              TableRow(
                decoration: BoxDecoration(
                  color: Mycolors().green,
                  border: const Border(bottom: BorderSide(color: Colors.black)),
                ),
                children: [
                  _buildHeaderCell('Student'),
                  _buildHeaderCell('Date'),
                  _buildHeaderCell('Course'),
                  _buildHeaderCell('Module'),
                  _buildHeaderCell('Download'),
                  _buildHeaderCell('Grade'),
                ],
              ),
              // Table Rows
              ...List.generate(submissions.length, (index) {
                final submission = submissions[index];
                return TableRow(
                  decoration: BoxDecoration(
                    color: index % 2 == 0
                        ? Colors.white
                        : const Color.fromRGBO(209, 210, 146, 0.50),
                    border: const Border(
                      bottom: BorderSide(width: 1, color: Colors.black),
                    ),
                  ),
                  children: [
                    _buildCell(submission['student']),
                    _buildCell(submission['date']),
                    _buildCell(submission['course']),
                    _buildCell(submission['module']),
                    _buildButtonCell(
                      icon: Icons.download_sharp,
                      color: Colors.blue.shade700,
                      onPressed: () => _downloadFile(submission['fileUrl']),
                    ),
                    _buildButtonCell(
                      icon: Icons.grade,
                      color: Colors.green.shade700,
                      onPressed: () => _openGradeDialog(submission, index),
                    ),
                  ],
                );
              }),
            ],
          );
  }

  Widget _buildHeaderCell(String text) {
    return TableStructure(
      child: Text(
        text,
        style: GoogleFonts.montserrat(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCell(String text) {
    return TableStructure(
      child: Text(
        text,
        style: GoogleFonts.montserrat(
          color: Colors.black,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildButtonCell({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return TableStructure(
      child: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.white),
          iconSize: 20,
        ),
      ),
    );
  }

  Future<void> _downloadFile(String url) async {
    if (url.isNotEmpty && await canLaunch(url)) {
      await launch(url);
    } else {
      print("Failed to launch URL: $url");
    }
  }
}
