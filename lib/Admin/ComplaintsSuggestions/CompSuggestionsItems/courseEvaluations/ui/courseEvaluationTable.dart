import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../Themes/Constants/myColors.dart';
import '../../../../../../TableWidgets/tableStructure.dart';
import '../../../../../services/complaints_suggestions_service.dart';

class CourseEvaluationTable extends StatefulWidget {
  const CourseEvaluationTable({super.key});

  @override
  State<CourseEvaluationTable> createState() => _CourseEvaluationTableState();
}

class _CourseEvaluationTableState extends State<CourseEvaluationTable> {
  final _service = ComplaintsSuggestionsService();

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
                      'Course Evaluation Details',
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
                _buildInfoRow(
                    'Student ID', evaluationData['studentId'] ?? 'Unknown'),
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
                _buildResponseSection('Most Useful Aspects',
                    evaluationData['mostUseful'] ?? 'No response provided'),
                _buildResponseSection('Suggestions for Improvement',
                    evaluationData['suggestions'] ?? 'No response provided'),
                _buildResponseSection('Would Recommend?',
                    '${evaluationData['recommendation'] ?? 'No response'}\nReason: ${evaluationData['recommendationReason'] ?? 'No reason provided'}'),

                const SizedBox(height: 24),
                if (evaluationData['status'] != 'resolved')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _service
                              .markEvaluationAsResolved(evaluationData['id']);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Mycolors().darkTeal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          'Mark as Reviewed',
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
    return SingleChildScrollView(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('course_evaluations')
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
                'No course evaluations found',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            );
          }

          return TableStructure(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  'Course',
                  'Student ID',
                  'Overall Rating',
                  'Status',
                  'Date',
                  'Actions',
                ]
                    .map((column) => DataColumn(
                          label: Text(
                            column,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Mycolors().navyBlue,
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
                      DataCell(Text(data['courseName'] ?? 'Unknown')),
                      DataCell(Text(data['studentId'] ?? 'Unknown')),
                      DataCell(_buildRatingStars(averageRating)),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: data['status'] == 'resolved'
                                ? Colors.green[100]
                                : Colors.orange[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            data['status'] ?? 'pending',
                            style: GoogleFonts.poppins(
                              color: data['status'] == 'resolved'
                                  ? Colors.green[800]
                                  : Colors.orange[800],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                          Text(_formatDate(data['submittedAt'] as Timestamp))),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.visibility),
                              onPressed: () => _showDetailedEvaluation(data),
                              tooltip: 'View Details',
                            ),
                            if (data['status'] != 'resolved')
                              IconButton(
                                icon: const Icon(Icons.check_circle_outline),
                                onPressed: () =>
                                    _service.markEvaluationAsResolved(doc.id),
                                tooltip: 'Mark as Reviewed',
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRatingStars(num rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 16,
        );
      }),
    );
  }
}
