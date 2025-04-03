import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:a4m/Constants/myColors.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'assessment_grading_view.dart';

class AssessmentSubmissionsView extends StatefulWidget {
  final String courseId;
  final String moduleId;

  const AssessmentSubmissionsView({
    super.key,
    required this.courseId,
    required this.moduleId,
  });

  @override
  State<AssessmentSubmissionsView> createState() =>
      _AssessmentSubmissionsViewState();
}

class _AssessmentSubmissionsViewState extends State<AssessmentSubmissionsView> {
  List<Map<String, dynamic>> submissions = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchSubmissions();
  }

  Future<void> fetchSubmissions() async {
    try {
      print('\n=== Starting Detailed Submission Fetch Process ===');
      print('Course ID: ${widget.courseId}');
      print('Module ID: ${widget.moduleId}');

      // First verify the module exists and log its data
      final moduleDoc = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('modules')
          .doc(widget.moduleId)
          .get();

      if (!moduleDoc.exists) {
        print('❌ ERROR: Module document not found!');
        print('Path: courses/${widget.courseId}/modules/${widget.moduleId}');
        setState(() {
          error = 'Module not found';
          isLoading = false;
        });
        return;
      }

      print('✅ Module document exists');
      print('Module Data: ${moduleDoc.data()}');

      print('\n=== Fetching Submissions ===');
      print(
          'Path: courses/${widget.courseId}/modules/${widget.moduleId}/submissions');

      // Get all submissions
      final submissionsSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('modules')
          .doc(widget.moduleId)
          .collection('submissions')
          .get();

      print('\nFound ${submissionsSnapshot.docs.length} submission documents');

      final List<Map<String, dynamic>> tempSubmissions = [];

      for (var doc in submissionsSnapshot.docs) {
        print('\n--- Processing Submission Document ---');
        print('Document ID: ${doc.id}');
        final data = doc.data();
        print('Raw Document Data: $data');

        if (!data.containsKey('submittedAssessments')) {
          print(
              '⚠️ WARNING: Document ${doc.id} has no submittedAssessments field');
          continue;
        }

        final submittedAssessments =
            data['submittedAssessments'] as List<dynamic>? ?? [];
        print(
            'Found ${submittedAssessments.length} assessments in this submission');

        for (var assessment in submittedAssessments) {
          print('\nProcessing Assessment:');
          print('Assessment Data: $assessment');

          if (assessment is Map<String, dynamic>) {
            final submissionData = {
              'id': doc.id,
              'studentName': assessment['studentName'] ?? 'Unknown Student',
              'assessmentName':
                  assessment['assessmentName'] ?? 'Unnamed Assessment',
              'fileUrl': assessment['fileUrl'] ?? '',
              'submittedAt': assessment['submittedAt'] ?? data['lastUpdated'],
              'mark': assessment['mark'],
              'comment': assessment['comment'],
              'status': _getSubmissionStatus(assessment),
              'gradedAt': assessment['gradedAt'],
              'gradedBy': assessment['gradedBy'],
            };
            print('Processed Submission Data: $submissionData');
            tempSubmissions.add(submissionData);
          } else {
            print(
                '⚠️ WARNING: Assessment is not a Map: ${assessment.runtimeType}');
          }
        }
      }

      print('\n=== Final Results ===');
      print('Total processed submissions: ${tempSubmissions.length}');
      print('Submission Details:');
      for (var submission in tempSubmissions) {
        print(
            '- ${submission['studentName']}: ${submission['assessmentName']} (${submission['status']})');
      }

      setState(() {
        submissions = tempSubmissions;
        isLoading = false;
      });
    } catch (e, stackTrace) {
      print('\n❌ ERROR in fetchSubmissions:');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        error = 'Error loading submissions: $e';
        isLoading = false;
      });
    }
  }

  String _getSubmissionStatus(Map<String, dynamic> assessment) {
    print('\n=== Determining Submission Status ===');
    print('Assessment Data: $assessment');

    final mark = assessment['mark'];
    final comment = assessment['comment'];
    final gradedAt = assessment['gradedAt'];

    print('Mark: $mark');
    print('Comment: $comment');
    print('Graded At: $gradedAt');

    if (mark == null || mark.toString().isEmpty) {
      print('Status: Pending Review (No mark)');
      return 'Pending Review';
    }

    if (comment == null || comment.toString().isEmpty) {
      print('Status: Partially Graded (No comment)');
      return 'Partially Graded';
    }

    if (gradedAt != null) {
      print('Status: Graded (Complete)');
      return 'Graded';
    }

    print('Status: In Progress');
    return 'In Progress';
  }

  Future<void> _openGradingView(Map<String, dynamic> submission) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssessmentGradingView(
          courseId: widget.courseId,
          moduleId: widget.moduleId,
          studentId: submission['id'],
          assessmentName: submission['assessmentName'],
          fileUrl: submission['fileUrl'],
          currentMark: submission['mark']?.toDouble(),
          currentComment: submission['comment'],
        ),
      ),
    );
    fetchSubmissions(); // Refresh after grading
  }

  Future<void> _viewSubmission(String fileUrl) async {
    if (await canLaunch(fileUrl)) {
      await launch(fileUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open the file'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const Divider(height: 1),
          _buildTableHeader(),
          if (isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (error != null)
            Expanded(
              child: Center(
                child: Text(
                  error!,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
              ),
            )
          else if (submissions.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  'No submissions found',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: _buildSubmissionsTable(),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[700],
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 16),
          Text(
            'Assessment Submissions',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Student Name',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Assessment',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Submitted At',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Status',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          const SizedBox(width: 100), // Fixed width for actions column
        ],
      ),
    );
  }

  Widget _buildSubmissionsTable() {
    return ListView.builder(
      itemCount: submissions.length,
      itemBuilder: (context, index) {
        final submission = submissions[index];
        return _buildSubmissionRow(submission);
      },
    );
  }

  Widget _buildSubmissionRow(Map<String, dynamic> submission) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openGradingView(submission),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    submission['studentName'] ?? 'Unknown Student',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    submission['assessmentName'] ?? 'Unnamed Assessment',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    submission['submittedAt'] is Timestamp
                        ? DateFormat('MMM d, y HH:mm')
                            .format(submission['submittedAt'].toDate())
                        : 'Unknown Date',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    submission['status'] ?? 'Unknown',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: _getStatusColor(submission['status']),
                    ),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility_outlined),
                        onPressed: () => _viewSubmission(submission['fileUrl']),
                        color: Colors.grey[700],
                        tooltip: 'View Submission',
                      ),
                      IconButton(
                        icon: const Icon(Icons.grade_outlined),
                        onPressed: () => _openGradingView(submission),
                        color: Colors.grey[700],
                        tooltip: 'Grade Submission',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'graded':
        return Colors.green;
      case 'pending review':
        return Colors.orange;
      case 'partially graded':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
