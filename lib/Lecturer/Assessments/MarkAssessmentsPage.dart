import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Themes/Constants/myColors.dart';

class MarkAssessmentsPage extends StatefulWidget {
  final String courseId;
  final String moduleId;

  const MarkAssessmentsPage({
    super.key,
    required this.courseId,
    required this.moduleId,
  });

  @override
  State<MarkAssessmentsPage> createState() => _MarkAssessmentsPageState();
}

class _MarkAssessmentsPageState extends State<MarkAssessmentsPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const Divider(height: 1),
          _buildTableHeader(),
          Expanded(
            child: _buildSubmissionsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[700],
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              // Handle back navigation
            },
          ),
          const SizedBox(width: 16),
          Text(
            'Assessment Submissions',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Student Name',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Assessment',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Submitted At',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Status',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          const SizedBox(width: 100), // Fixed width for actions column
        ],
      ),
    );
  }

  Widget _buildSubmissionsList() {
    // TODO: Replace with actual data from Firebase
    final submissions = [
      {
        'studentName': 'student1',
        'assessment': 'pdfs/1742394460125_assessments.pdf',
        'submittedAt': 'Apr 1, 2025 13:52',
        'status': 'Pending Review',
      },
      // Add more submissions as needed
    ];

    return ListView.builder(
      itemCount: submissions.length,
      itemBuilder: (context, index) {
        final submission = submissions[index];
        return _buildSubmissionRow(submission);
      },
    );
  }

  Widget _buildSubmissionRow(Map<String, dynamic> submission) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Handle row tap
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    submission['studentName'],
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    submission['assessment'],
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    submission['submittedAt'],
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    submission['status'],
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.orange,
                    ),
                  ),
                ),
                SizedBox(
                  width: 100, // Fixed width for actions column
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility_outlined),
                        onPressed: () {
                          // Handle view action
                        },
                        color: Colors.grey[700],
                        tooltip: 'View Submission',
                      ),
                      IconButton(
                        icon: const Icon(Icons.star_outline),
                        onPressed: () {
                          // Handle mark action
                        },
                        color: Colors.grey[700],
                        tooltip: 'Mark Submission',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
