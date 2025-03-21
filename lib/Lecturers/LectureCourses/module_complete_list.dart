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
    try {
      // Fetch course details
      var courseDoc = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .get();

      courseName = courseDoc.data()?['courseName'] ?? 'No Course Name';

      // Fetch module details
      var moduleDoc = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('modules')
          .doc(widget.moduleId)
          .get();

      moduleName = moduleDoc.data()?['moduleName'] ?? 'No Module Name';

      // Fetch submissions from the `submissions` subcollection
      var submissionsSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('modules')
          .doc(widget.moduleId)
          .collection('submissions')
          .get();

      List<Map<String, dynamic>> tempSubmissions = [];

      for (var doc in submissionsSnapshot.docs) {
        final submissionData = doc.data();

        String studentName = submissionData['studentName'] ?? 'Unknown Student';
        Timestamp submittedDate =
            submissionData['submitted'] ?? Timestamp.now();

        List<dynamic> submittedAssessments =
            submissionData['submittedAssessments'] ?? [];

        for (var assessment in submittedAssessments) {
          tempSubmissions.add({
            'student': studentName,
            'date': submittedDate.toDate().toString().split(' ')[0],
            'course': courseName,
            'module': moduleName,
            'assessment': assessment['assessmentName'] ?? '',
            'fileUrl': assessment['fileUrl'] ?? '',
            'mark': assessment['mark'] ?? '',
            'comment': assessment['comment'] ?? '',
            'submissionDocId': doc.id, // Reference to submission doc
          });
        }
      }

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
          .doc(submission['submissionDocId']);

      DocumentSnapshot doc = await submissionRef.get();
      if (!doc.exists) {
        print("Submission document not found.");
        return;
      }

      List<dynamic> submittedAssessments = doc['submittedAssessments'] ?? [];

      for (var assessment in submittedAssessments) {
        if (assessment['assessmentName'] == submission['assessment']) {
          assessment['mark'] = mark;
          assessment['comment'] = comment;
        }
      }

      await submissionRef.update({
        'submittedAssessments': submittedAssessments,
      });

      setState(() {
        submissions = submissions.map((s) {
          if (s['assessment'] == submission['assessment'] &&
              s['student'] == submission['student']) {
            return {...s, 'mark': mark, 'comment': comment};
          }
          return s;
        }).toList();
      });

      print("Grade updated successfully!");
    } catch (e) {
      print("Error updating grade: $e");
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
              ...submissions.map((submission) {
                return TableRow(
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
                      onPressed: () => _openGradeDialog(submission),
                    ),
                  ],
                );
              }).toList(),
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
    if (url.isNotEmpty && await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      print("Failed to launch URL: $url");
    }
  }
}
