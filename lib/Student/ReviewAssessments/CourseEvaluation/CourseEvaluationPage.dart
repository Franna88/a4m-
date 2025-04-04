import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../Themes/Constants/myColors.dart';
import '../../../myutility.dart';
import 'CourseEvaluationForm.dart';

class CourseEvaluationPage extends StatefulWidget {
  const CourseEvaluationPage({super.key});

  @override
  State<CourseEvaluationPage> createState() => _CourseEvaluationPageState();
}

class _CourseEvaluationPageState extends State<CourseEvaluationPage> {
  final String studentId = FirebaseAuth.instance.currentUser?.uid ?? '';
  late Future<List<Map<String, dynamic>>> _enrolledCoursesFuture;

  @override
  void initState() {
    super.initState();
    _enrolledCoursesFuture = _fetchEnrolledCourses();
  }

  Future<List<Map<String, dynamic>>> _fetchEnrolledCourses() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('courses').get();

      List<Map<String, dynamic>> enrolledCourses = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        if (data.containsKey('students') && data['students'] is List) {
          final students = data['students'] as List<dynamic>;

          // Check if student is enrolled in this course
          if (students.any((student) =>
              student is Map<String, dynamic> &&
              student['studentId'] == studentId)) {
            // Check if student has already evaluated this course
            bool hasEvaluated = false;
            try {
              QuerySnapshot evaluations = await FirebaseFirestore.instance
                  .collection('course_evaluations')
                  .where('courseId', isEqualTo: doc.id)
                  .where('studentId', isEqualTo: studentId)
                  .get();

              hasEvaluated = evaluations.docs.isNotEmpty;
            } catch (e) {
              print('Error checking evaluations: $e');
            }

            enrolledCourses.add({
              'id': doc.id,
              'courseName': data['courseName'] ?? 'Unnamed Course',
              'courseDescription':
                  data['courseDescription'] ?? 'No description available',
              'courseImageUrl': data['courseImageUrl'] ?? 'images/course1.png',
              'hasEvaluated': hasEvaluated,
            });
          }
        }
      }

      return enrolledCourses;
    } catch (e) {
      print('Error fetching enrolled courses: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MyUtility(context).width - 320,
      height: MyUtility(context).height - 80,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MyUtility(context).height * 0.78,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(width: 0.8),
            ),
            width: MyUtility(context).width,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Course Evaluations',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Mycolors().navyBlue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Divider(
                    color: Mycolors().green,
                    thickness: 6,
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: _enrolledCoursesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error loading courses: ${snapshot.error}',
                              style: GoogleFonts.poppins(color: Colors.red),
                            ),
                          );
                        }

                        final courses = snapshot.data ?? [];

                        if (courses.isEmpty) {
                          return Center(
                            child: Text(
                              'You are not enrolled in any courses yet',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: courses.length,
                          itemBuilder: (context, index) {
                            final course = courses[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    course['courseImageUrl'],
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.image),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  course['courseName'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  course['courseDescription'],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                trailing: course['hasEvaluated']
                                    ? Chip(
                                        label: Text(
                                          'Evaluated',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                          ),
                                        ),
                                        backgroundColor: Colors.green,
                                      )
                                    : ElevatedButton.icon(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => Dialog(
                                              child: CourseEvaluationForm(
                                                courseId: course['id'],
                                                courseName:
                                                    course['courseName'],
                                                studentId: studentId,
                                              ),
                                            ),
                                          ).then((_) {
                                            // Refresh the list after evaluation
                                            setState(() {
                                              _enrolledCoursesFuture =
                                                  _fetchEnrolledCourses();
                                            });
                                          });
                                        },
                                        icon: const Icon(Icons.rate_review),
                                        label: const Text('Evaluate'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Mycolors().darkTeal,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
