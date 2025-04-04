import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../services/complaints_suggestions_service.dart';
import '../../../../../Themes/Constants/myColors.dart';
import '../../../../../../TableWidgets/tableStructure.dart';
import '../../../../../myutility.dart';

class CourseReviewTable extends StatefulWidget {
  const CourseReviewTable({super.key});

  @override
  State<CourseReviewTable> createState() => _CourseReviewTableState();
}

class _CourseReviewTableState extends State<CourseReviewTable> {
  final _service = ComplaintsSuggestionsService();
  bool _isLoading = false;

  void _showDetailedReview(Map<String, dynamic> reviewData) {
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
                      'Detailed Lecturer Review',
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
                    'Student', reviewData['studentName'] ?? 'Unknown'),
                _buildInfoRow(
                    'Lecturer', reviewData['lecturerName'] ?? 'Unknown'),
                _buildInfoRow(
                    'Date', _formatDate(reviewData['dateAdded'] as Timestamp)),
                const Divider(height: 32),
                _buildRatingSection(
                    'Overall Rating', reviewData['rating'] ?? 0),
                _buildRatingSection(
                    'Teaching Style', reviewData['teachingRating'] ?? 0),
                _buildRatingSection(
                    'Communication', reviewData['communicationRating'] ?? 0),
                _buildRatingSection(
                    'Support', reviewData['supportRating'] ?? 0),
                const Divider(height: 32),
                _buildFeedbackSection('Teaching Style Feedback',
                    reviewData['teachingFeedback'] ?? 'No feedback provided'),
                _buildFeedbackSection(
                    'Communication Feedback',
                    reviewData['communicationFeedback'] ??
                        'No feedback provided'),
                _buildFeedbackSection('Support and Availability Feedback',
                    reviewData['supportFeedback'] ?? 'No feedback provided'),
                _buildFeedbackSection('Strengths',
                    reviewData['strengths'] ?? 'No feedback provided'),
                _buildFeedbackSection('Areas for Improvement',
                    reviewData['improvements'] ?? 'No feedback provided'),
                _buildFeedbackSection(
                    'Additional Comments',
                    reviewData['additionalFeedback'] ??
                        'No additional comments'),
                const SizedBox(height: 24),
                if (reviewData['status'] != 'resolved')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showResponseDialog(reviewData['id']);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Mycolors().darkTeal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          'Respond to Review',
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

  Widget _buildRatingSection(String title, num rating) {
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
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 24,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackSection(String title, String content) {
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
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  void _showResponseDialog(String reviewId) {
    final responseController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Respond to Review',
          style: GoogleFonts.poppins(
            color: Mycolors().navyBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: responseController,
              decoration: InputDecoration(
                hintText: 'Enter your response',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (responseController.text.isNotEmpty) {
                _service.addAdminResponseToReview(
                  reviewId,
                  responseController.text,
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Mycolors().darkTeal,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
            ),
            child: Text(
              'Submit Response',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: StreamBuilder<QuerySnapshot>(
        stream: _service.getLecturerReviews(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading reviews: ${snapshot.error}',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final reviews = snapshot.data!.docs;

          if (reviews.isEmpty) {
            return Center(
              child: Text(
                'No lecturer reviews found',
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
                  'Student',
                  'Lecturer',
                  'Overall Rating',
                  'Teaching',
                  'Communication',
                  'Support',
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
                rows: reviews.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final date = (data['dateAdded'] as Timestamp).toDate();
                  final formattedDate =
                      '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';

                  return DataRow(
                    cells: [
                      DataCell(Text(data['studentName'] ?? 'Unknown')),
                      DataCell(Text(data['lecturerName'] ?? 'Unknown')),
                      DataCell(_buildRatingStars(data['rating'] ?? 0)),
                      DataCell(_buildRatingStars(data['teachingRating'] ?? 0)),
                      DataCell(
                          _buildRatingStars(data['communicationRating'] ?? 0)),
                      DataCell(_buildRatingStars(data['supportRating'] ?? 0)),
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
                      DataCell(Text(formattedDate)),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.visibility),
                              onPressed: () => _showDetailedReview(data),
                              tooltip: 'View Details',
                            ),
                            if (data['status'] != 'resolved')
                              IconButton(
                                icon: const Icon(Icons.reply),
                                onPressed: () => _showResponseDialog(doc.id),
                                tooltip: 'Respond',
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
