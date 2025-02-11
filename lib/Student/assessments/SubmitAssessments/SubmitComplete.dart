import 'package:a4m/CommonComponents/buttons/slimButtons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:a4m/Constants/myColors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:a4m/TableWidgets/tableStructure.dart';
import 'package:url_launcher/url_launcher.dart';

class SubmitComplete extends StatefulWidget {
  final String courseId;
  final String moduleId; // Added moduleId parameter

  const SubmitComplete({
    super.key,
    required this.courseId,
    required this.moduleId,
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

        // Safely handle studentAssessment data
        final studentAssessments =
            moduleData['studentAssessment'] as List<dynamic>?;

        List<Map<String, dynamic>> tempSubmissions = [];

        if (studentAssessments != null) {
          for (var submission in studentAssessments) {
            tempSubmissions.add({
              'student': submission['name']?.toString() ?? 'Unknown Student',
              'date': submission['submitted'] != null &&
                      submission['submitted'] is Timestamp
                  ? (submission['submitted'] as Timestamp)
                      .toDate()
                      .toString()
                      .split(' ')[0]
                  : 'Unknown Date',
              'course': courseName,
              'module': moduleName,
              'assessment': submission['assessment']?.toString() ?? '',
              'mark': submission['mark']?.toString() ?? '',
              'comment': submission['comment']?.toString() ?? '',
            });
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
      final moduleRef = FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('modules')
          .doc(widget.moduleId);

      final moduleDoc = await moduleRef.get();
      final moduleData = moduleDoc.data() as Map<String, dynamic>;
      final studentAssessments =
          List<Map<String, dynamic>>.from(moduleData['studentAssessment']);

      studentAssessments[index]['mark'] = mark;
      studentAssessments[index]['comment'] = comment;

      await moduleRef.update({'studentAssessment': studentAssessments});

      setState(() {
        submissions[index]['mark'] = mark;
        submissions[index]['comment'] = comment;
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
                      onPressed: () => _downloadFile(submission['assessment']),
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
