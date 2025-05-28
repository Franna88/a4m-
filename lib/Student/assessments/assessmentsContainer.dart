import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_network/image_network.dart';
import '../../Themes/Constants/myColors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AssessmentsContainer extends StatelessWidget {
  final String courseName;
  final String courseImage;
  final String courseDescription;
  final String moduleCount;
  final String assessmentCount;
  final String? completedAssessments;
  final bool? isCompleted;
  final VoidCallback onTap;

  const AssessmentsContainer({
    super.key,
    required this.courseName,
    required this.courseImage,
    required this.courseDescription,
    required this.moduleCount,
    required this.assessmentCount,
    this.completedAssessments,
    this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 800;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: isSmallScreen
                ? _buildMobileLayout(context)
                : _buildDesktopLayout(context),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCourseImage(),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCourseHeader(),
              const SizedBox(height: 12),
              _buildCourseDescription(),
              const SizedBox(height: 24),
              _buildCourseStats(),
              const SizedBox(height: 24),
              _buildContinueButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCourseImage(),
        const SizedBox(height: 16),
        _buildCourseHeader(),
        const SizedBox(height: 12),
        _buildCourseDescription(),
        const SizedBox(height: 16),
        _buildCourseStats(),
        const SizedBox(height: 16),
        _buildContinueButton(),
      ],
    );
  }

  Widget _buildCourseImage() {
    return Stack(
      children: [
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ImageNetwork(
              image: courseImage,
              height: 160,
              width: 160,
              fitAndroidIos: BoxFit.cover,
              fitWeb: BoxFitWeb.cover,
              onLoading: Container(
                color: Colors.grey[200],
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Mycolors().green),
                  ),
                ),
              ),
              onError: Container(
                color: Colors.grey[200],
                child: Icon(Icons.error, color: Colors.red),
              ),
            ),
          ),
        ),
        if (isCompleted != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: FractionallySizedBox(
                widthFactor: isCompleted! ? 1.0 : 0.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Mycolors().green,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCourseHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            courseName,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isCompleted != null)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: isCompleted!
                  ? Mycolors().green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isCompleted! ? 'Completed' : 'In Progress',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isCompleted! ? Mycolors().green : Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCourseDescription() {
    return Text(
      courseDescription,
      style: GoogleFonts.poppins(
        fontSize: 14,
        color: Colors.grey[600],
        height: 1.5,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildCourseStats() {
    return Wrap(
      spacing: 24,
      runSpacing: 12,
      children: [
        _buildStatItem(
          Icons.library_books_outlined,
          '$moduleCount Modules',
          Colors.blue,
        ),
        _buildStatItem(
          Icons.assignment_outlined,
          completedAssessments != null
              ? '$completedAssessments/$assessmentCount Assessments'
              : '$assessmentCount Assessments',
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return Builder(
      builder: (BuildContext context) => Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton.icon(
              onPressed: () => _showResultsSheet(context, courseName),
              style: OutlinedButton.styleFrom(
                foregroundColor: Mycolors().darkTeal,
                side: BorderSide(color: Mycolors().darkTeal),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.assessment, size: 18),
              label: Text(
                'Results',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Mycolors().green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Continue',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResultsSheet(BuildContext context, String courseName) {
    // This will be implemented as a separate widget
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700, maxHeight: 700),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Course Results: $courseName',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: _fetchStudentResults(courseName),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error loading results: ${snapshot.error}',
                            style: GoogleFonts.poppins(color: Colors.red),
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.assignment_late,
                                  size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'No results available yet',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // This is a placeholder, in a real implementation we would display
                      // the real results from snapshot.data
                      return _buildResultsContent(snapshot.data!);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchStudentResults(String courseName) async {
    try {
      // Get the current user ID
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Find the course ID by name
      final coursesQuery = await FirebaseFirestore.instance
          .collection('courses')
          .where('courseName', isEqualTo: courseName)
          .limit(1)
          .get();

      if (coursesQuery.docs.isEmpty) {
        throw Exception('Course not found');
      }

      final courseId = coursesQuery.docs.first.id;

      // Fetch all modules for this course
      final modulesSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('modules')
          .get();

      final modules = modulesSnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['moduleName'] ?? 'Unknown Module',
                'completed': false, // Will be updated based on assessments
                'assessments': <Map<String, dynamic>>[], // Will be populated
              })
          .toList();

      // Calculate overall course mark
      double totalMarks = 0;
      int totalAssessments = 0;
      int completedAssessments = 0;

      // For each module, fetch student submissions
      for (var moduleIndex = 0; moduleIndex < modules.length; moduleIndex++) {
        final moduleId = modules[moduleIndex]['id'];

        // Fetch student submissions for this module
        final submissionDoc = await FirebaseFirestore.instance
            .collection('courses')
            .doc(courseId)
            .collection('modules')
            .doc(moduleId)
            .collection('submissions')
            .doc(userId)
            .get();

        if (submissionDoc.exists && submissionDoc.data() != null) {
          final data = submissionDoc.data()!;

          // Get submitted assessments
          final submittedAssessments = List<Map<String, dynamic>>.from(
              data['submittedAssessments'] ?? []);

          // Process assessments
          for (var assessment in submittedAssessments) {
            final assessmentName =
                assessment['assessmentName'] ?? 'Unknown Assessment';
            final mark = assessment['mark'];
            final submittedAt = assessment['submittedAt'];

            // Only count graded assessments for the total
            if (mark != null &&
                (mark is double || (mark is String && mark.isNotEmpty))) {
              double markValue = 0;
              if (mark is double) {
                markValue = mark;
              } else if (mark is String) {
                markValue = double.tryParse(mark) ?? 0;
              }

              totalMarks += markValue;
              totalAssessments++;
              completedAssessments++;

              // Add to module's assessments
              modules[moduleIndex]['assessments'].add({
                'name': assessmentName,
                'mark': '$markValue%',
                'status': 'Completed',
                'submittedAt': submittedAt,
              });
            } else {
              // Assessment submitted but not yet graded
              modules[moduleIndex]['assessments'].add({
                'name': assessmentName,
                'mark': 'Pending',
                'status': 'Submitted',
                'submittedAt': submittedAt,
              });
            }
          }

          // Mark module as completed if all assessments are submitted
          if (submittedAssessments.isNotEmpty) {
            modules[moduleIndex]['completed'] = true;
          }
        }
      }

      // Calculate overall mark percentage
      final overallMark = totalAssessments > 0
          ? (totalMarks / totalAssessments).toStringAsFixed(1) + '%'
          : 'N/A';

      return {
        'overallMark': overallMark,
        'totalAssessments': totalAssessments,
        'completedAssessments': completedAssessments,
        'modules': modules,
      };
    } catch (e) {
      debugPrint('Error fetching student results: $e');
      return {};
    }
  }

  Widget _buildResultsContent(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overall mark
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Mycolors().green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.stars,
                color: Mycolors().green,
                size: 32,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overall Course Mark',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    data['overallMark'],
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Mycolors().darkTeal,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Assessments Completed',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '${data['completedAssessments']}/${data['totalAssessments']}',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Mycolors().darkTeal,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Module progress
        Text(
          'Module Progress',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),

        const SizedBox(height: 16),

        Expanded(
          child: ListView.builder(
            itemCount: data['modules']?.length ?? 0,
            itemBuilder: (context, index) {
              final module = data['modules'][index];
              return ExpansionTile(
                title: Text(
                  module['name'],
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  module['completed'] ? 'Completed' : 'In Progress',
                  style: GoogleFonts.poppins(
                    color:
                        module['completed'] ? Mycolors().green : Colors.orange,
                  ),
                ),
                leading: Icon(
                  module['completed'] ? Icons.check_circle : Icons.pending,
                  color: module['completed'] ? Mycolors().green : Colors.orange,
                ),
                children: [
                  ...List.generate(
                    module['assessments']?.length ?? 0,
                    (i) => ListTile(
                      title: Text(
                        module['assessments'][i]['name'],
                        style: GoogleFonts.poppins(),
                      ),
                      trailing: Text(
                        module['assessments'][i]['mark'],
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: module['assessments'][i]['mark'] != 'N/A' &&
                                  module['assessments'][i]['mark'] != 'Pending'
                              ? Mycolors().darkTeal
                              : Colors.grey,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            module['assessments'][i]['status'],
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: module['assessments'][i]['status'] ==
                                      'Completed'
                                  ? Mycolors().green
                                  : Colors.orange,
                            ),
                          ),
                          if (module['assessments'][i]['submittedAt'] != null)
                            Text(
                              'Submitted: ${_formatTimestamp(module['assessments'][i]['submittedAt'])}',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final dt = timestamp.toDate();
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return timestamp.toString();
  }

  Widget _buildStatItem(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
