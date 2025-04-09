import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_network/image_network.dart';

class StudentProgressListItem extends StatelessWidget {
  final String studentName;
  final String courseName;
  final double progress;

  const StudentProgressListItem({
    super.key,
    required this.studentName,
    required this.courseName,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Profile Image
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.grey.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: ImageNetwork(
                image: 'https://via.placeholder.com/150',
                height: 40,
                width: 40,
                fitAndroidIos: BoxFit.cover,
                fitWeb: BoxFitWeb.cover,
                onLoading: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                  ),
                ),
                onError: Container(
                  color: Colors.grey[100],
                  child: Icon(
                    Icons.person_outline,
                    size: 20,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Student Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studentName,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  courseName,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Progress Bar
          SizedBox(
            width: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${(progress * 100).toInt()}%',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress < 0.3
                          ? Colors.red[400]!
                          : progress < 0.7
                              ? Colors.orange[400]!
                              : Colors.green[400]!,
                    ),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
