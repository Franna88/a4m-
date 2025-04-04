import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../Themes/Constants/myColors.dart';

class CourseEvaluationForm extends StatefulWidget {
  final String courseId;
  final String studentId;
  final String courseName;

  const CourseEvaluationForm({
    Key? key,
    required this.courseId,
    required this.studentId,
    required this.courseName,
  }) : super(key: key);

  @override
  State<CourseEvaluationForm> createState() => _CourseEvaluationFormState();
}

class _CourseEvaluationFormState extends State<CourseEvaluationForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, int> _ratings = {};
  final TextEditingController _mostUsefulController = TextEditingController();
  final TextEditingController _suggestionsController = TextEditingController();
  final TextEditingController _recommendationController =
      TextEditingController();
  bool _isSubmitting = false;

  final List<String> _evaluationCriteria = [
    'The objectives of the training were met',
    'The presenters were engaging',
    'The presentation materials were relevant',
    'The content of the course was organised and easy to follow',
    'The trainers were well prepared and able to answer any questions',
    'The course length was appropriate',
    'The pace of the course was appropriate to the content and attendees',
    'The exercises/role play were helpful and relevant',
    'The venue was appropriate for the event',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Course Evaluation - ${widget.courseName}',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Mycolors().darkTeal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please rate your level of agreement with the following statements:',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              ...buildEvaluationItems(),
              const SizedBox(height: 30),
              buildTextQuestion(
                'What was most useful?',
                _mostUsefulController,
              ),
              const SizedBox(height: 20),
              buildTextQuestion(
                'What else would you like to see included in this event? Are there any other topics that you would like to be offered training courses in?',
                _suggestionsController,
              ),
              const SizedBox(height: 20),
              buildRecommendationSection(),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitEvaluation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Mycolors().darkTeal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                  ),
                  child: Text(
                    _isSubmitting ? 'Submitting...' : 'Submit Evaluation',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> buildEvaluationItems() {
    return _evaluationCriteria.map((criteria) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              criteria,
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                buildRatingOption(criteria, 'Strongly Agree', 5),
                buildRatingOption(criteria, 'Agree', 4),
                buildRatingOption(criteria, 'Disagree', 2),
                buildRatingOption(criteria, 'Strongly Disagree', 1),
                buildRatingOption(criteria, 'Not relevant', 0),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget buildRatingOption(String criteria, String label, int value) {
    return Column(
      children: [
        Radio<int>(
          value: value,
          groupValue: _ratings[criteria],
          onChanged: (int? value) {
            setState(() {
              _ratings[criteria] = value!;
            });
          },
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget buildTextQuestion(String question, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            hintText: 'Enter your response here',
          ),
        ),
      ],
    );
  }

  Widget buildRecommendationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Would you recommend this course to colleagues?',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Radio<String>(
              value: 'Yes',
              groupValue: _recommendationController.text,
              onChanged: (value) {
                setState(() {
                  _recommendationController.text = value!;
                });
              },
            ),
            const Text('Yes'),
            const SizedBox(width: 20),
            Radio<String>(
              value: 'No',
              groupValue: _recommendationController.text,
              onChanged: (value) {
                setState(() {
                  _recommendationController.text = value!;
                });
              },
            ),
            const Text('No'),
          ],
        ),
        const SizedBox(height: 10),
        TextFormField(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            hintText: 'Why?',
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  Future<void> _submitEvaluation() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        await FirebaseFirestore.instance.collection('course_evaluations').add({
          'courseId': widget.courseId,
          'courseName': widget.courseName,
          'studentId': widget.studentId,
          'ratings': _ratings,
          'mostUseful': _mostUsefulController.text,
          'suggestions': _suggestionsController.text,
          'recommendation': _recommendationController.text,
          'submittedAt': FieldValue.serverTimestamp(),
          'status': 'pending',
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Evaluation submitted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error submitting evaluation: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }
}
