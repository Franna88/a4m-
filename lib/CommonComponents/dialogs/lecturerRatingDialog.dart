import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/complaints_suggestions_service.dart';
import '../../Themes/Constants/myColors.dart';

class LecturerRatingDialog extends StatefulWidget {
  final String lecturerId;
  final String lecturerName;

  const LecturerRatingDialog({
    super.key,
    required this.lecturerId,
    required this.lecturerName,
  });

  @override
  State<LecturerRatingDialog> createState() => _LecturerRatingDialogState();
}

class _LecturerRatingDialogState extends State<LecturerRatingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();
  final _strengthsController = TextEditingController();
  final _improvementsController = TextEditingController();
  final _teachingStyleController = TextEditingController();
  final _communicationController = TextEditingController();
  final _supportController = TextEditingController();
  double _rating = 0;
  double _teachingRating = 0;
  double _communicationRating = 0;
  double _supportRating = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    _strengthsController.dispose();
    _improvementsController.dispose();
    _teachingStyleController.dispose();
    _communicationController.dispose();
    _supportController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final service = ComplaintsSuggestionsService();
      await service.addComplaint(
        title: 'Lecturer Evaluation: ${widget.lecturerName}',
        description: '''
Overall Rating: $_rating/5
Teaching Style Rating: $_teachingRating/5
Communication Rating: $_communicationRating/5
Support Rating: $_supportRating/5

Teaching Style Feedback:
${_teachingStyleController.text}

Communication Feedback:
${_communicationController.text}

Support and Availability Feedback:
${_supportController.text}

What you enjoyed most about the lecturer:
${_strengthsController.text}

Areas for improvement:
${_improvementsController.text}

Additional feedback:
${_feedbackController.text}
''',
        type: 'Lecturer: Evaluation',
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Evaluation submitted successfully',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Mycolors().green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error submitting evaluation: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Widget _buildRatingSection(
      String title, double rating, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                index < rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
              ),
              onPressed: () => onChanged(index + 1.0),
            );
          }),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFeedbackSection(
      String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please provide feedback';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rate Your Lecturer',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Lecturer: ${widget.lecturerName}',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                _buildRatingSection('Overall Rating', _rating,
                    (value) => setState(() => _rating = value)),
                const Divider(),
                _buildRatingSection('Teaching Style Rating', _teachingRating,
                    (value) => setState(() => _teachingRating = value)),
                _buildFeedbackSection(
                  'Teaching Style Feedback',
                  'How effective was the teaching method? Was the content well-organized and clearly presented?',
                  _teachingStyleController,
                ),
                const Divider(),
                _buildRatingSection(
                    'Communication Rating',
                    _communicationRating,
                    (value) => setState(() => _communicationRating = value)),
                _buildFeedbackSection(
                  'Communication Feedback',
                  'How clear and effective was the lecturer\'s communication? Were instructions and expectations clearly conveyed?',
                  _communicationController,
                ),
                const Divider(),
                _buildRatingSection('Support Rating', _supportRating,
                    (value) => setState(() => _supportRating = value)),
                _buildFeedbackSection(
                  'Support and Availability',
                  'How accessible was the lecturer for questions and additional help? How responsive were they to student needs?',
                  _supportController,
                ),
                const Divider(),
                _buildFeedbackSection(
                  'What did you enjoy most about this lecturer?',
                  'Share specific examples of what made this lecturer effective',
                  _strengthsController,
                ),
                _buildFeedbackSection(
                  'What could the lecturer improve?',
                  'Provide constructive suggestions for improvement',
                  _improvementsController,
                ),
                _buildFeedbackSection(
                  'Additional Comments',
                  'Any other feedback you would like to share',
                  _feedbackController,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Mycolors().green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Submit Evaluation',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
