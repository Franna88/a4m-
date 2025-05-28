import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../commonUi/pdfViewer.dart';
import '../../../../Constants/myColors.dart';

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
            'markedPdfUrl': assessment['markedPdfUrl'] ?? '',
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

  String _inferType(String fileUrl) {
    final lower = fileUrl.toLowerCase();
    if (lower.contains('assessment')) return 'Assessment';
    if (lower.contains('assignment')) return 'Assignment';
    if (lower.contains('test')) return 'Test PDF';
    return 'Submission';
  }

  Future<void> _viewSubmission(String fileUrl,
      {String type = 'Submission', bool isGradedPdf = false}) async {
    print('\n=== Attempting to View Submission ===');
    print('File URL: $fileUrl');

    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text(
                isGradedPdf ? 'Graded $type' : type,
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              backgroundColor: Mycolors().darkGrey,
            ),
            body: StudentPdfViewer(
              pdfUrl: fileUrl,
              title: isGradedPdf ? 'Graded $type' : type,
              showDownloadButton: true,
            ),
          ),
        ),
      );
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

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final dt = timestamp.toDate();
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return timestamp.toString();
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
                  'Submitted: ${_formatTimestamp(assessment['submittedAt'])}',
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
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (assessment['fileUrl'].isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.visibility),
                    onPressed: () async {
                      await _viewSubmission(
                        assessment['fileUrl'],
                        type: _inferType(assessment['fileUrl']),
                      );
                    },
                    tooltip: 'View Submission',
                  ),
                if (assessment['markedPdfUrl']?.isNotEmpty == true)
                  IconButton(
                    icon: const Icon(Icons.grade),
                    onPressed: () async {
                      await _viewSubmission(
                        assessment['markedPdfUrl'],
                        type: _inferType(assessment['markedPdfUrl']),
                        isGradedPdf: true,
                      );
                    },
                    tooltip: 'View Graded PDF',
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
