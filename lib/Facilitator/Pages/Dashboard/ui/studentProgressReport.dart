import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../Constants/myColors.dart';

class StudentProgressReport extends StatefulWidget {
  final String studentId;
  final String studentName;
  final String courseId;
  final String courseName;

  const StudentProgressReport({
    Key? key,
    required this.studentId,
    required this.studentName,
    required this.courseId,
    required this.courseName,
  }) : super(key: key);

  @override
  State<StudentProgressReport> createState() => _StudentProgressReportState();
}

class _StudentProgressReportState extends State<StudentProgressReport> {
  bool isLoading = true;
  List<Map<String, dynamic>> moduleResults = [];
  Map<String, dynamic> overallStats = {
    'totalAssessments': 0,
    'completedAssessments': 0,
    'totalMarks': 0,
    'averageMark': 0.0,
  };

  @override
  void initState() {
    super.initState();
    _fetchStudentProgress();
  }

  Future<void> _fetchStudentProgress() async {
    try {
      // Use batch fetching to improve performance
      final moduleSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('modules')
          .get();

      int totalAssessments = 0;
      int completedAssessments = 0;
      double totalMarks = 0;

      // Create a list of future submission queries for batch execution
      final moduleIds = moduleSnapshot.docs.map((doc) => doc.id).toList();
      final results = <Map<String, dynamic>>[];

      if (moduleIds.isEmpty) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        return;
      }

      // Process modules in batches for better performance
      const batchSize = 5;
      for (var i = 0; i < moduleIds.length; i += batchSize) {
        final end = (i + batchSize < moduleIds.length)
            ? i + batchSize
            : moduleIds.length;
        final batch = moduleIds.sublist(i, end);

        final moduleBatchResults =
            await Future.wait(batch.map((moduleId) async {
          final moduleDoc =
              moduleSnapshot.docs.firstWhere((doc) => doc.id == moduleId);
          final moduleData = moduleDoc.data();
          final moduleName = moduleData['moduleName'] ?? 'Unknown Module';

          // Check if assessments exist
          final hasAssessment = moduleData['assessmentsPdfUrl'] != null &&
              moduleData['assessmentsPdfUrl'].toString().isNotEmpty;
          final hasTest = moduleData['testSheetPdfUrl'] != null &&
              moduleData['testSheetPdfUrl'].toString().isNotEmpty;

          if (hasAssessment) totalAssessments++;
          if (hasTest) totalAssessments++;

          // Get submission for this module
          final submissionDoc = await FirebaseFirestore.instance
              .collection('courses')
              .doc(widget.courseId)
              .collection('modules')
              .doc(moduleId)
              .collection('submissions')
              .doc(widget.studentId)
              .get();

          final moduleResult = {
            'moduleId': moduleId,
            'moduleName': moduleName,
            'hasAssessment': hasAssessment,
            'hasTest': hasTest,
            'assessmentCompleted': false,
            'testCompleted': false,
            'assessmentMark': 'N/A',
            'testMark': 'N/A',
            'assessmentComment': '',
            'testComment': '',
          };

          if (submissionDoc.exists) {
            final submissionData = submissionDoc.data() as Map<String, dynamic>;
            final submittedAssessments =
                submissionData['submittedAssessments'] as List<dynamic>? ?? [];

            for (var assessment in submittedAssessments) {
              if (assessment is Map<String, dynamic>) {
                final assessmentName = assessment['assessmentName'] ?? '';
                if (assessmentName.toLowerCase().contains('assessment') &&
                    hasAssessment) {
                  moduleResult['assessmentCompleted'] = true;
                  moduleResult['assessmentMark'] =
                      assessment['mark'] ?? 'No Mark';
                  moduleResult['assessmentComment'] =
                      assessment['comment'] ?? '';
                  completedAssessments++;

                  // Add to total marks if a mark exists
                  if (assessment['mark'] != null &&
                      assessment['mark'].toString().isNotEmpty) {
                    try {
                      final mark =
                          double.tryParse(assessment['mark'].toString()) ?? 0;
                      totalMarks += mark;
                    } catch (e) {
                      print('Error parsing mark: ${assessment['mark']}');
                    }
                  }
                } else if (assessmentName.toLowerCase().contains('test') &&
                    hasTest) {
                  moduleResult['testCompleted'] = true;
                  moduleResult['testMark'] = assessment['mark'] ?? 'No Mark';
                  moduleResult['testComment'] = assessment['comment'] ?? '';
                  completedAssessments++;

                  // Add to total marks if a mark exists
                  if (assessment['mark'] != null &&
                      assessment['mark'].toString().isNotEmpty) {
                    try {
                      final mark =
                          double.tryParse(assessment['mark'].toString()) ?? 0;
                      totalMarks += mark;
                    } catch (e) {
                      print('Error parsing mark: ${assessment['mark']}');
                    }
                  }
                }
              }
            }
          }

          return moduleResult;
        }));

        results.addAll(moduleBatchResults);
      }

      // Calculate average mark
      final averageMark =
          completedAssessments > 0 ? totalMarks / completedAssessments : 0;

      if (mounted) {
        setState(() {
          moduleResults = results;
          overallStats = {
            'totalAssessments': totalAssessments,
            'completedAssessments': completedAssessments,
            'totalMarks': totalMarks,
            'averageMark': averageMark,
          };
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching student progress: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 700,
        height: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with student info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progress Report',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.studentName,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      widget.courseName,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const Divider(height: 32),

            // Progress summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  '${overallStats['completedAssessments']}/${overallStats['totalAssessments']}',
                  'Assessments Completed',
                  Icons.assignment_turned_in,
                ),
                _buildStatCard(
                  '${overallStats['averageMark'].toStringAsFixed(1)}%',
                  'Average Mark',
                  Icons.grade,
                ),
                _buildStatCard(
                  '${(overallStats['completedAssessments'] / (overallStats['totalAssessments'] > 0 ? overallStats['totalAssessments'] : 1) * 100).toStringAsFixed(0)}%',
                  'Course Progress',
                  Icons.show_chart,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Module Results
            Text(
              'Module Results',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 10),

            // Table of results
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : moduleResults.isEmpty
                      ? Center(
                          child: Text(
                            'No modules found for this course',
                            style: GoogleFonts.poppins(color: Colors.grey[600]),
                          ),
                        )
                      : SingleChildScrollView(
                          child: DataTable(
                            columnSpacing: 16,
                            horizontalMargin: 12,
                            headingRowHeight: 40,
                            columns: [
                              DataColumn(
                                label: Text(
                                  'Module',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Assessment',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Test',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                            rows: moduleResults.map((module) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      module['moduleName'],
                                      style: GoogleFonts.poppins(fontSize: 14),
                                    ),
                                  ),
                                  DataCell(
                                    module['hasAssessment']
                                        ? _buildAssessmentStatus(
                                            module['assessmentCompleted'],
                                            module['assessmentMark'],
                                          )
                                        : Text(
                                            'N/A',
                                            style: GoogleFonts.poppins(
                                              color: Colors.grey[400],
                                            ),
                                          ),
                                  ),
                                  DataCell(
                                    module['hasTest']
                                        ? _buildAssessmentStatus(
                                            module['testCompleted'],
                                            module['testMark'],
                                          )
                                        : Text(
                                            'N/A',
                                            style: GoogleFonts.poppins(
                                              color: Colors.grey[400],
                                            ),
                                          ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Mycolors().green, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentStatus(bool completed, String mark) {
    if (!completed) {
      return Row(
        children: [
          Icon(Icons.pending, size: 16, color: Colors.orange[400]),
          const SizedBox(width: 4),
          Text(
            'Pending',
            style: GoogleFonts.poppins(
              color: Colors.orange[400],
              fontSize: 14,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Icon(Icons.check_circle, size: 16, color: Mycolors().green),
        const SizedBox(width: 4),
        Text(
          mark != 'No Mark' ? '$mark%' : 'Submitted',
          style: GoogleFonts.poppins(
            color: Mycolors().green,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
