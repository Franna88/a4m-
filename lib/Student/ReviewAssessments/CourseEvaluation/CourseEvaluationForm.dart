import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../Themes/Constants/myColors.dart';

class CourseEvaluationForm extends StatefulWidget {
  final String courseId;
  final String studentId;
  final String courseName;

  const CourseEvaluationForm({
    super.key,
    required this.courseId,
    required this.studentId,
    required this.courseName,
  });

  @override
  State<CourseEvaluationForm> createState() => _CourseEvaluationFormState();
}

class _CourseEvaluationFormState extends State<CourseEvaluationForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, int> _courseRatings = {};
  final Map<String, int> _lecturerRatings = {};
  final TextEditingController _courseMostUsefulController =
      TextEditingController();
  final TextEditingController _courseSuggestionsController =
      TextEditingController();
  final TextEditingController _courseRecommendationController =
      TextEditingController();
  final TextEditingController _lecturerFeedbackController =
      TextEditingController();
  final TextEditingController _lecturerImprovementController =
      TextEditingController();
  bool _isSubmitting = false;

  final List<String> _courseEvaluationCriteria = [
    'The objectives of the training were met',
    'The presentation materials were relevant',
    'The content of the course was organised and easy to follow',
    'The course length was appropriate',
    'The pace of the course was appropriate to the content and attendees',
    'The exercises/role play were helpful and relevant',
    'The venue was appropriate for the event',
  ];

  final List<String> _lecturerEvaluationCriteria = [
    'The lecturer was well prepared for classes',
    'The lecturer explained concepts clearly',
    'The lecturer was engaging and enthusiastic',
    'The lecturer encouraged student participation',
    'The lecturer was available for consultation',
    'The lecturer provided helpful feedback',
    'The lecturer demonstrated thorough knowledge of the subject',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Evaluate - ${widget.courseName}',
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
              // Course Evaluation Section
              Text(
                'Course Evaluation',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Mycolors().darkTeal,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Please rate your level of agreement with the following statements about the course:',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              ...buildEvaluationItems(
                  _courseEvaluationCriteria, _courseRatings),
              const SizedBox(height: 30),
              buildTextQuestion(
                'What aspects of the course were most useful?',
                _courseMostUsefulController,
              ),
              const SizedBox(height: 20),
              buildTextQuestion(
                'What improvements would you suggest for the course?',
                _courseSuggestionsController,
              ),
              const SizedBox(height: 20),
              buildRecommendationSection(),

              const Divider(height: 60),

              // Lecturer Evaluation Section
              Text(
                'Lecturer Evaluation',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Mycolors().darkTeal,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Please rate your level of agreement with the following statements about the lecturer:',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              ...buildEvaluationItems(
                  _lecturerEvaluationCriteria, _lecturerRatings),
              const SizedBox(height: 30),
              buildTextQuestion(
                'What did the lecturer do particularly well?',
                _lecturerFeedbackController,
              ),
              const SizedBox(height: 20),
              buildTextQuestion(
                'What could the lecturer improve on?',
                _lecturerImprovementController,
              ),

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

  List<Widget> buildEvaluationItems(
      List<String> criteria, Map<String, int> ratings) {
    return criteria.map((criteria) {
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
                buildRatingOption(criteria, 'Strongly Agree', 5, ratings),
                buildRatingOption(criteria, 'Agree', 4, ratings),
                buildRatingOption(criteria, 'Disagree', 2, ratings),
                buildRatingOption(criteria, 'Strongly Disagree', 1, ratings),
                buildRatingOption(criteria, 'Not relevant', 0, ratings),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget buildRatingOption(
      String criteria, String label, int value, Map<String, int> ratings) {
    return Column(
      children: [
        Radio<int>(
          value: value,
          groupValue: ratings[criteria],
          onChanged: (int? value) {
            setState(() {
              ratings[criteria] = value!;
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
              groupValue: _courseRecommendationController.text,
              onChanged: (value) {
                setState(() {
                  _courseRecommendationController.text = value!;
                });
              },
            ),
            const Text('Yes'),
            const SizedBox(width: 20),
            Radio<String>(
              value: 'No',
              groupValue: _courseRecommendationController.text,
              onChanged: (value) {
                setState(() {
                  _courseRecommendationController.text = value!;
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
        // Get student name from Users collection
        final userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(widget.studentId)
            .get();
        final studentName = userDoc.data()?['name'] ?? 'Unknown Student';

        // Submit course evaluation
        await FirebaseFirestore.instance.collection('course_evaluations').add({
          'courseId': widget.courseId,
          'courseName': widget.courseName,
          'studentId': widget.studentId,
          'studentName': studentName,
          'ratings': _courseRatings,
          'mostUseful': _courseMostUsefulController.text,
          'suggestions': _courseSuggestionsController.text,
          'recommendation': _courseRecommendationController.text,
          'submittedAt': FieldValue.serverTimestamp(),
          'type': 'course',
        });

        // Submit lecturer evaluation
        await FirebaseFirestore.instance.collection('course_evaluations').add({
          'courseId': widget.courseId,
          'courseName': widget.courseName,
          'studentId': widget.studentId,
          'studentName': studentName,
          'ratings': _lecturerRatings,
          'feedback': _lecturerFeedbackController.text,
          'improvements': _lecturerImprovementController.text,
          'submittedAt': FieldValue.serverTimestamp(),
          'type': 'lecturer',
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
