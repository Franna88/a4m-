import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:a4m/Constants/myColors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AssessmentGradingView extends StatefulWidget {
  final String courseId;
  final String moduleId;
  final String studentId;
  final String assessmentName;
  final String fileUrl;
  final double? currentMark;
  final String? currentComment;

  const AssessmentGradingView({
    super.key,
    required this.courseId,
    required this.moduleId,
    required this.studentId,
    required this.assessmentName,
    required this.fileUrl,
    this.currentMark,
    this.currentComment,
  });

  @override
  State<AssessmentGradingView> createState() => _AssessmentGradingViewState();
}

class _AssessmentGradingViewState extends State<AssessmentGradingView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _markController;
  late TextEditingController _commentController;
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _markController =
        TextEditingController(text: widget.currentMark?.toString() ?? '');
    _commentController =
        TextEditingController(text: widget.currentComment ?? '');
  }

  @override
  void dispose() {
    _markController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitGrade() async {
    print('\n=== Starting Grade Submission Process ===');
    print('Course ID: ${widget.courseId}');
    print('Module ID: ${widget.moduleId}');
    print('Student ID: ${widget.studentId}');
    print('Assessment Name: ${widget.assessmentName}');

    if (!_formKey.currentState!.validate()) {
      print('❌ Form validation failed');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      // Validate mark is a valid number
      final mark = double.tryParse(_markController.text);
      print('Mark Input: ${_markController.text}');
      print('Parsed Mark: $mark');

      if (mark == null || mark < 0 || mark > 100) {
        throw Exception('Please enter a valid mark between 0 and 100');
      }

      final submissionRef = FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('modules')
          .doc(widget.moduleId)
          .collection('submissions')
          .doc(widget.studentId);

      print('\nFetching submission document...');
      final submissionDoc = await submissionRef.get();

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

      final assessmentIndex = submittedAssessments.indexWhere(
        (a) => a['assessmentName'] == widget.assessmentName,
      );

      if (assessmentIndex == -1) {
        print('❌ ERROR: Assessment not found in submission document');
        throw Exception('Assessment not found in submission document');
      }

      print('Found assessment at index: $assessmentIndex');
      print(
          'Current assessment data: ${submittedAssessments[assessmentIndex]}');

      final updatedAssessment = {
        ...submittedAssessments[assessmentIndex],
        'mark': mark,
        'comment': _commentController.text,
        'gradedAt': FieldValue.serverTimestamp(),
        'gradedBy': FirebaseAuth.instance.currentUser?.uid,
      };
      print('Updated assessment data: $updatedAssessment');

      submittedAssessments[assessmentIndex] = updatedAssessment;

      print('\nUpdating Firestore document...');
      await submissionRef.update({
        'submittedAssessments': submittedAssessments,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      print('✅ Firestore update successful');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Grade submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('\n❌ ERROR in _submitGrade:');
      print('Error: $e');
      setState(() {
        _error = e.toString();
        _isSubmitting = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting grade: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _viewSubmission() async {
    print('\n=== Attempting to View Submission ===');
    print('File URL: ${widget.fileUrl}');

    try {
      if (await canLaunch(widget.fileUrl)) {
        print('✅ Launching file URL');
        await launch(widget.fileUrl);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Grade Assessment',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Mycolors().darkGrey,
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Assessment Info Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assessment Details',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('Assessment:', widget.assessmentName),
                      const SizedBox(height: 12),
                      _buildInfoRow('Student ID:', widget.studentId),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _viewSubmission,
                        icon: const Icon(Icons.visibility),
                        label: const Text('View Submission'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Mycolors().darkGrey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Grading Form Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Grade Assessment',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _markController,
                        decoration: InputDecoration(
                          labelText: 'Mark',
                          hintText: 'Enter mark (0-100)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a mark';
                          }
                          final mark = double.tryParse(value);
                          if (mark == null) {
                            return 'Please enter a valid number';
                          }
                          if (mark < 0 || mark > 100) {
                            return 'Mark must be between 0 and 100';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          labelText: 'Feedback',
                          hintText: 'Enter feedback for the student',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please provide feedback';
                          }
                          return null;
                        },
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitGrade,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Mycolors().green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text('Submit Grade'),
                        ),
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
