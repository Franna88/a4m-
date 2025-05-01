import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../Themes/Constants/myColors.dart';
import '../../../../../../TableWidgets/tableStructure.dart';
import '../../../../../services/complaints_suggestions_service.dart';

class LecturerEvaluationTable extends StatefulWidget {
  const LecturerEvaluationTable({super.key});

  @override
  State<LecturerEvaluationTable> createState() =>
      _LecturerEvaluationTableState();
}

class _LecturerEvaluationTableState extends State<LecturerEvaluationTable> {
  final _service = ComplaintsSuggestionsService();
  final Map<String, String> _studentNames = {};

  Future<String> _getStudentName(String studentId) async {
    if (_studentNames.containsKey(studentId)) {
      return _studentNames[studentId]!;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(studentId)
          .get();

      final name = doc.data()?['name'] ?? 'Unknown Student';
      _studentNames[studentId] = name;
      return name;
    } catch (e) {
      print('Error fetching student name: $e');
      return 'Unknown Student';
    }
  }

  void _showDetailedEvaluation(Map<String, dynamic> evaluationData) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 800,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Lecturer Evaluation Details',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Mycolors().navyBlue,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildInfoRow(
                    'Course', evaluationData['courseName'] ?? 'Unknown'),
                _buildInfoRow('Student',
                    evaluationData['studentName'] ?? 'Unknown Student'),
                _buildInfoRow('Date',
                    _formatDate(evaluationData['submittedAt'] as Timestamp)),
                const Divider(height: 32),

                // Display ratings
                Text(
                  'Ratings:',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Mycolors().navyBlue,
                  ),
                ),
                const SizedBox(height: 16),
                ..._buildRatingsSection(
                    evaluationData['ratings'] as Map<String, dynamic>),

                const Divider(height: 32),

                // Display text responses
                _buildResponseSection('Positive Feedback',
                    evaluationData['feedback'] ?? 'No response provided'),
                _buildResponseSection('Areas for Improvement',
                    evaluationData['improvements'] ?? 'No response provided'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Mycolors().navyBlue,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRatingsSection(Map<String, dynamic> ratings) {
    return ratings.entries.map((entry) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.key,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ...List.generate(5, (index) {
                  return Icon(
                    index < (entry.value as num)
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 20,
                  );
                }),
                const SizedBox(width: 8),
                Text(
                  _getRatingText(entry.value as num),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }

  String _getRatingText(num rating) {
    switch (rating) {
      case 5:
        return 'Strongly Agree';
      case 4:
        return 'Agree';
      case 2:
        return 'Disagree';
      case 1:
        return 'Strongly Disagree';
      case 0:
        return 'Not relevant';
      default:
        return 'Unknown';
    }
  }

  Widget _buildResponseSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Mycolors().navyBlue,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              content,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('course_evaluations')
          .where('type', isEqualTo: 'lecturer')
          .orderBy('submittedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading evaluations: ${snapshot.error}',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final evaluations = snapshot.data!.docs;

        if (evaluations.isEmpty) {
          return Center(
            child: Text(
              'No lecturer evaluations found',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.white),
                dataRowColor: MaterialStateProperty.all(Colors.white),
                columnSpacing: 40,
                horizontalMargin: 0,
                columns: [
                  'Course',
                  'Student Name',
                  'Overall Rating',
                  'Date',
                  'Actions',
                ]
                    .map((column) => DataColumn(
                          label: Text(
                            column,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.grey[800],
                            ),
                          ),
                        ))
                    .toList(),
                rows: evaluations.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final ratings = data['ratings'] as Map<String, dynamic>;
                  final averageRating =
                      ratings.values.reduce((a, b) => a + b) / ratings.length;

                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          data['courseName'] ?? 'Unknown',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      DataCell(
                        FutureBuilder<String>(
                          future: _getStudentName(data['studentId']),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              );
                            }
                            return Text(
                              snapshot.data ?? 'Unknown Student',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[800],
                              ),
                            );
                          },
                        ),
                      ),
                      DataCell(_buildRatingStars(averageRating)),
                      DataCell(
                        Text(
                          _formatDate(data['submittedAt'] as Timestamp),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      DataCell(
                        IconButton(
                          icon: const Icon(
                            Icons.visibility_outlined,
                            color: Colors.grey,
                          ),
                          onPressed: () => _showDetailedEvaluation(data),
                          tooltip: 'View Details',
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRatingStars(num rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 18,
        );
      }),
    );
  }
}
