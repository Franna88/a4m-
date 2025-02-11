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
      final submissionRef = FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('modules')
          .doc(widget.moduleId)
          .collection('submissions')
          .doc(widget.studentId);

      final submissionDoc = await submissionRef.get();

      if (submissionDoc.exists) {
        final data = submissionDoc.data();
        if (data != null && data.containsKey('submittedAssessments')) {
          List<dynamic> allAssessments = data['submittedAssessments'];

          // Filter out assessments that have been marked
          List<Map<String, dynamic>> marked = allAssessments
              .where((assessment) => assessment.containsKey('mark'))
              .map((assessment) => {
                    'assessmentName': assessment['assessmentName'],
                    'fileUrl': assessment['fileUrl'],
                    'mark': assessment['mark'],
                    'comment': assessment['comment'],
                  })
              .toList();

          setState(() {
            markedAssessments = marked;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching marked assessments: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Module 2: $moduleName',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: markedAssessments.isEmpty
                      ? const Center(child: Text('No marked assessments yet.'))
                      : ListView.builder(
                          itemCount: markedAssessments.length,
                          itemBuilder: (context, index) {
                            final assessment = markedAssessments[index];
                            return _buildMarkedAssessmentCard(assessment);
                          },
                        ),
                ),
              ],
            ),
          );
  }

  /// 🔹 Build the marked assessment card with **Score, Download & Popup**
  Widget _buildMarkedAssessmentCard(Map<String, dynamic> assessment) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                assessment['assessmentName'],
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            Text(
              '${assessment['mark']}/100', // 🔹 Display score on the container
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            IconButton(
              onPressed: () => _showAssessmentPopup(assessment),
              icon: const Icon(Icons.info, color: Colors.blue),
            ),
            IconButton(
              onPressed: () => _downloadAssessment(assessment['fileUrl']),
              icon: const Icon(Icons.download, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 **Show Popup with Mark & Comment**
  void _showAssessmentPopup(Map<String, dynamic> assessment) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Assessment Details", style: GoogleFonts.montserrat()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Assessment: ${assessment['assessmentName']}",
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              Text("Score: ${assessment['mark']}/100",
                  style: GoogleFonts.montserrat(fontSize: 16)),
              const SizedBox(height: 10),
              Text("Comment: ${assessment['comment']}",
                  style: GoogleFonts.montserrat(fontSize: 16)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  /// 🔹 **Download File**
  void _downloadAssessment(String fileUrl) async {
    if (await canLaunch(fileUrl)) {
      await launch(fileUrl);
    } else {
      debugPrint('Could not open file: $fileUrl');
    }
  }
}
