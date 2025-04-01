import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:a4m/Constants/myColors.dart';

class AssessmentGradingView extends StatefulWidget {
  final String courseId;
  final String moduleId;
  final String studentId;
  final String assessmentName;
  final String fileUrl;
  final double? currentMark;
  final String? currentComment;

  const AssessmentGradingView({
    Key? key,
    required this.courseId,
    required this.moduleId,
    required this.studentId,
    required this.assessmentName,
    required this.fileUrl,
    this.currentMark,
    this.currentComment,
  }) : super(key: key);

  @override
  State<AssessmentGradingView> createState() => _AssessmentGradingViewState();
}

class _AssessmentGradingViewState extends State<AssessmentGradingView> {
  final _markController = TextEditingController();
  final _commentController = TextEditingController();
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _markController.text = widget.currentMark?.toString() ?? '';
    _commentController.text = widget.currentComment ?? '';
  }

  Future<void> _gradeSubmission() async {
    if (_markController.text.isEmpty) {
      setState(() => error = 'Please enter a mark');
      return;
    }

    final mark = double.tryParse(_markController.text);
    if (mark == null) {
      setState(() => error = 'Please enter a valid mark');
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final submissionRef = FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('modules')
          .doc(widget.moduleId)
          .collection('submissions')
          .doc(widget.studentId);

      final doc = await submissionRef.get();
      if (!doc.exists) {
        throw Exception('Submission document not found');
      }

      final data = doc.data()!;
      final submittedAssessments =
          List<dynamic>.from(data['submittedAssessments'] ?? []);

      // Find and update the assessment
      final assessmentIndex = submittedAssessments.indexWhere(
        (assessment) => assessment['name'] == widget.assessmentName,
      );

      if (assessmentIndex == -1) {
        throw Exception('Assessment not found in submission');
      }

      submittedAssessments[assessmentIndex] = {
        ...submittedAssessments[assessmentIndex],
        'mark': mark,
        'comment': _commentController.text,
        'gradedAt': FieldValue.serverTimestamp(),
      };

      await submissionRef.update({
        'submittedAssessments': submittedAssessments,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Grade saved successfully')),
        );
      }
    } catch (e) {
      print('Error grading submission: $e');
      if (mounted) {
        setState(() => error = 'Failed to save grade: $e');
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Grade Assessment',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.assessmentName,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          if (error != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      error!,
                      style: GoogleFonts.poppins(
                        color: Colors.red[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Submission',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 400,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: widget.fileUrl.endsWith('.pdf')
                            ? const Center(
                                child:
                                    Text('PDF Viewer will be implemented here'),
                              )
                            : Image.network(
                                widget.fileUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          color: Colors.red[700],
                                          size: 48,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Failed to load image',
                                          style: GoogleFonts.poppins(
                                            color: Colors.red[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Grading',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _markController,
                      decoration: InputDecoration(
                        labelText: 'Mark',
                        hintText: 'Enter mark',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.grade),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        labelText: 'Comment',
                        hintText: 'Enter feedback',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.comment),
                      ),
                      maxLines: 5,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _gradeSubmission,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Mycolors().green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text(
                                'Save Grade',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
