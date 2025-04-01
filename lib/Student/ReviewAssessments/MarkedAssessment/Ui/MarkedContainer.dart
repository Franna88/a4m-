import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class MarkedContainer extends StatefulWidget {
  final String courseId;
  final String moduleId;
  final String studentId;

  const MarkedContainer({
    super.key,
    required this.courseId,
    required this.moduleId,
    required this.studentId,
  });

  @override
  State<MarkedContainer> createState() => _MarkedContainerState();
}

class _MarkedContainerState extends State<MarkedContainer> {
  List<Map<String, dynamic>> markedAssessments = [];
  String moduleName = 'Production Technology';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMarkedAssessments();
  }

  /// 🔹 Fetch only **marked** assessments from Firestore
  Future<void> fetchMarkedAssessments() async {
    try {
      print("Fetching marked assessments for student: ${widget.studentId}");
      print("Course ID: ${widget.courseId}");
      print("Module ID: ${widget.moduleId}");

      // First get the module name
      final moduleDoc = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('modules')
          .doc(widget.moduleId)
          .get();

      if (moduleDoc.exists) {
        setState(() {
          moduleName = moduleDoc.data()?['moduleName'] ?? 'Unknown Module';
        });
      }

      // Then get the student's submissions
      final submissionRef = FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('modules')
          .doc(widget.moduleId)
          .collection('submissions')
          .doc(widget.studentId);

      final submissionDoc = await submissionRef.get();
      print("Found submission document: ${submissionDoc.exists}");

      List<Map<String, dynamic>> tempMarkedAssessments = [];

      if (submissionDoc.exists) {
        final data = submissionDoc.data();
        if (data != null && data.containsKey('submittedAssessments')) {
          List<dynamic> allAssessments = data['submittedAssessments'];
          print("Found ${allAssessments.length} submitted assessments");

          for (var assessment in allAssessments) {
            if (assessment is Map<String, dynamic> &&
                (assessment['mark']?.toString().isNotEmpty ?? false)) {
              tempMarkedAssessments.add({
                'name': assessment['assessmentName'] ?? 'Unknown Assessment',
                'submittedAt': assessment['submittedAt'] != null
                    ? (assessment['submittedAt'] as Timestamp)
                        .toDate()
                        .toString()
                        .split(' ')[0]
                    : 'Unknown Date',
                'mark': assessment['mark'] ?? 'Not Graded',
                'comment': assessment['comment'] ?? 'No Comment',
                'fileUrl': assessment['fileUrl'] ?? '',
              });
              print("Added marked assessment: ${assessment['assessmentName']}");
            }
          }
        }
      }

      setState(() {
        markedAssessments = tempMarkedAssessments;
        isLoading = false;
      });
      print("Total marked assessments: ${markedAssessments.length}");
    } catch (e) {
      print("Error fetching marked assessments: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (markedAssessments.isEmpty) {
      return Center(
        child: Text(
          'No marked assessments found',
          style: GoogleFonts.montserrat(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: markedAssessments.length,
      itemBuilder: (context, index) {
        final assessment = markedAssessments[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            title: Text(
              assessment['name'],
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Submitted: ${assessment['submittedAt']}',
                  style: GoogleFonts.montserrat(),
                ),
                Text(
                  'Mark: ${assessment['mark']}',
                  style: GoogleFonts.montserrat(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (assessment['comment'].isNotEmpty)
                  Text(
                    'Comment: ${assessment['comment']}',
                    style: GoogleFonts.montserrat(),
                  ),
              ],
            ),
            trailing: assessment['fileUrl'].isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.visibility),
                    onPressed: () async {
                      if (await canLaunch(assessment['fileUrl'])) {
                        await launch(assessment['fileUrl']);
                      }
                    },
                    tooltip: 'View Submission',
                  )
                : null,
          ),
        );
      },
    );
  }
}
