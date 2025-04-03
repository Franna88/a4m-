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
    print('\n=== Fetching Marked Assessments ===');
    print('Course ID: ${widget.courseId}');
    print('Module ID: ${widget.moduleId}');
    print('Student ID: ${widget.studentId}');

    try {
      final moduleRef = FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('modules')
          .doc(widget.moduleId)
          .collection('submissions')
          .doc(widget.studentId);

      print('\nFetching submission document...');
      final submissionDoc = await moduleRef.get();

      if (!submissionDoc.exists) {
        print('❌ ERROR: Submission document not found');
        throw Exception('Submission document not found');
      }

      print('✅ Submission document found');
      final data = submissionDoc.data();
      print('Submission Data: $data');

      if (data == null) {
        print('❌ ERROR: Submission data is null');
        throw Exception('Submission data is null');
      }

      final submittedAssessments =
          List<Map<String, dynamic>>.from(data['submittedAssessments'] ?? []);
      print('Found ${submittedAssessments.length} submitted assessments');

      final tempMarkedAssessments = <Map<String, dynamic>>[];

      for (var assessment in submittedAssessments) {
        print('\nProcessing assessment:');
        print('Assessment Data: $assessment');

        final mark = assessment['mark'];
        print('Mark value: $mark (Type: ${mark.runtimeType})');

        // Check if assessment is graded (has a mark)
        if (mark != null &&
            (mark is double || (mark is String && mark.isNotEmpty))) {
          print('✅ Assessment is graded');

          final markedAssessment = {
            'name': assessment['assessmentName'],
            'submittedAt': assessment['submittedAt'],
            'mark': mark.toString(),
            'comment': assessment['comment'] ?? '',
            'fileUrl': assessment['fileUrl'],
            'gradedAt': assessment['gradedAt'],
            'gradedBy': assessment['gradedBy'],
          };
          print('Processed marked assessment: $markedAssessment');

          tempMarkedAssessments.add(markedAssessment);
        } else {
          print('❌ Assessment is not graded');
        }
      }

      print(
          '\nTotal marked assessments found: ${tempMarkedAssessments.length}');

      if (mounted) {
        setState(() {
          markedAssessments = tempMarkedAssessments;
          isLoading = false;
        });
      }
    } catch (e) {
      print('\n❌ ERROR in fetchMarkedAssessments:');
      print('Error: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching marked assessments: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _viewSubmission(String fileUrl) async {
    print('\n=== Attempting to View Submission ===');
    print('File URL: $fileUrl');

    try {
      if (await canLaunch(fileUrl)) {
        print('✅ Launching file URL');
        await launch(fileUrl);
      } else {
        print('❌ Could not launch file URL');
        throw 'Could not open the file';
      }
    } catch (e) {
      print('❌ Error opening file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening file: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
                      await _viewSubmission(assessment['fileUrl']);
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
