import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/complaints_suggestions_service.dart';
import '../../Themes/Constants/myColors.dart';

class SubmitCourseReviewDialog extends StatefulWidget {
  final String userId;
  final String userName;
  final String userType;

  const SubmitCourseReviewDialog({
    super.key,
    required this.userId,
    required this.userName,
    required this.userType,
  });

  @override
  State<SubmitCourseReviewDialog> createState() =>
      _SubmitCourseReviewDialogState();
}

class _SubmitCourseReviewDialogState extends State<SubmitCourseReviewDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCourse = '';
  String _selectedLecturer = '';
  double _courseRating = 0;
  double _lecturerRating = 0;
  bool _isSubmitting = false;
  final List<Map<String, dynamic>> _courses = [];
  final List<Map<String, dynamic>> _lecturers = [];

  @override
  void initState() {
    super.initState();
    _loadUserCourses();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadUserCourses() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final enrolledCourses = userData['courses'] as List<dynamic>? ?? [];

        for (var courseId in enrolledCourses) {
          final courseDoc = await FirebaseFirestore.instance
              .collection('courses')
              .doc(courseId)
              .get();

          if (courseDoc.exists) {
            final courseData = courseDoc.data() as Map<String, dynamic>;
            _courses.add({
              'id': courseId,
              'name': courseData['courseName'] ?? 'Unknown Course',
              'lecturers':
                  courseData['assignedLecturers'] as List<dynamic>? ?? [],
            });
          }
        }

        setState(() {});
      }
    } catch (e) {
      print('Error loading courses: $e');
    }
  }

  Future<void> _loadLecturers(String courseId) async {
    try {
      final courseDoc = await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .get();

      if (courseDoc.exists) {
        final courseData = courseDoc.data() as Map<String, dynamic>;
        final lecturerIds =
            courseData['assignedLecturers'] as List<dynamic>? ?? [];

        _lecturers.clear();
        for (var lecturerId in lecturerIds) {
          final lecturerDoc = await FirebaseFirestore.instance
              .collection('Users')
              .doc(lecturerId)
              .get();

          if (lecturerDoc.exists) {
            final lecturerData = lecturerDoc.data() as Map<String, dynamic>;
            _lecturers.add({
              'id': lecturerId,
              'name': lecturerData['name'] ?? 'Unknown Lecturer',
            });
          }
        }

        setState(() {});
      }
    } catch (e) {
      print('Error loading lecturers: $e');
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;

        await FirebaseFirestore.instance.collection('courseReviews').add({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'courseId': _selectedCourse,
          'lecturerId': _selectedLecturer,
          'studentId': widget.userId,
          'studentName': userData['name'] ?? 'Unknown',
          'courseRating': _courseRating,
          'lecturerRating': _lecturerRating,
          'status': 'pending',
          'dateAdded': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Review submitted successfully',
                style: GoogleFonts.montserrat(),
              ),
              backgroundColor: Mycolors().darkTeal,
            ),
          );
        }
      }
    } catch (e) {
      print('Error submitting review: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error submitting review. Please try again.',
              style: GoogleFonts.montserrat(),
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Submit Course Review',
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Mycolors().navyBlue,
                ),
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: _selectedCourse.isEmpty ? null : _selectedCourse,
                decoration: InputDecoration(
                  labelText: 'Select Course',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: _courses.map((course) {
                  return DropdownMenuItem<String>(
                    value: course['id'],
                    child: Text(course['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCourse = value ?? '';
                    _selectedLecturer = '';
                    _lecturers.clear();
                  });
                  if (value != null) {
                    _loadLecturers(value);
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a course';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_selectedCourse.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: _selectedLecturer.isEmpty ? null : _selectedLecturer,
                  decoration: InputDecoration(
                    labelText: 'Select Lecturer',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: _lecturers.map((lecturer) {
                    return DropdownMenuItem<String>(
                      value: lecturer['id'],
                      child: Text(lecturer['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedLecturer = value ?? '';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a lecturer';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 16),
              Text(
                'Course Rating',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _courseRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () {
                      setState(() {
                        _courseRating = index + 1;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              Text(
                'Lecturer Rating',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _lecturerRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () {
                      setState(() {
                        _lecturerRating = index + 1;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Review Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Review Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.montserrat(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Mycolors().darkTeal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
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
                            'Submit Review',
                            style: GoogleFonts.montserrat(
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
    );
  }
}
