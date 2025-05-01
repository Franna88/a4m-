import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_network/image_network.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../CommonComponents/displayCardIcons.dart';
import '../../../Themes/Constants/myColors.dart';

class MemberContainers extends StatefulWidget {
  final bool? isLecturer;
  final bool? isContentDev;
  final bool? isFacilitator;
  final bool? isStudent;
  final bool? isAdmin;
  final String image;
  final String name;
  final String number;
  final String? studentAmount;
  final String? contentTotal;
  final String? rating;
  final VoidCallback? onTap;
  final Widget? trailing;

  const MemberContainers({
    super.key,
    this.isLecturer,
    this.isContentDev,
    this.isFacilitator,
    this.isStudent,
    this.isAdmin,
    required this.image,
    required this.name,
    required this.number,
    this.studentAmount,
    this.contentTotal,
    this.rating,
    this.onTap,
    this.trailing,
  });

  @override
  State<MemberContainers> createState() => _MemberContainersState();
}

class _MemberContainersState extends State<MemberContainers> {
  Future<Map<String, dynamic>> _fetchLecturerStats() async {
    try {
      // Format phone number by removing spaces
      String formattedPhoneNumber = widget.number.replaceAll(' ', '');

      // First get the lecturer's document to get their ID
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('phoneNumber', isEqualTo: formattedPhoneNumber)
          .get();

      if (userSnapshot.docs.isEmpty) {
        // Try with original phone number format as fallback
        userSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .where('phoneNumber', isEqualTo: widget.number)
            .get();

        if (userSnapshot.docs.isEmpty) {
          return {
            'totalSubmissions': 0,
            'markedSubmissions': 0,
            'pendingSubmissions': 0,
            'averageRating': 0.0,
          };
        }
      }

      String lecturerId = userSnapshot.docs.first.id;
      Map<String, dynamic> lecturerData =
          userSnapshot.docs.first.data() as Map<String, dynamic>;
      String? alternativeId = lecturerData['alternativeId'] as String?;

      // Get all courses where this lecturer is assigned
      QuerySnapshot coursesSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .where('assignedLecturers', isNotEqualTo: null)
          .get();

      int totalSubmissions = 0;
      int markedSubmissions = 0;
      int pendingSubmissions = 0;

      // For each course, check if this lecturer is assigned
      for (var courseDoc in coursesSnapshot.docs) {
        final courseData = courseDoc.data() as Map<String, dynamic>;
        final assignedLecturers =
            courseData['assignedLecturers'] as List<dynamic>?;

        if (assignedLecturers != null) {
          bool isAssigned = false;
          for (var lecturer in assignedLecturers) {
            if (lecturer is Map<String, dynamic>) {
              String assignedId = lecturer['id'] as String;
              if (assignedId == lecturerId ||
                  (alternativeId != null && assignedId == alternativeId) ||
                  courseData['createdBy'] == lecturerId) {
                isAssigned = true;
                break;
              }
            }
          }

          if (isAssigned) {
            // Get all modules for this course
            QuerySnapshot modulesSnapshot =
                await courseDoc.reference.collection('modules').get();

            // For each module, get its submissions
            for (var moduleDoc in modulesSnapshot.docs) {
              QuerySnapshot submissionsSnapshot =
                  await moduleDoc.reference.collection('submissions').get();

              // Process each student's submission document
              for (var submissionDoc in submissionsSnapshot.docs) {
                final data = submissionDoc.data() as Map<String, dynamic>;
                List<dynamic> submittedAssessments =
                    data['submittedAssessments'] ?? [];

                // Process each assessment in the submission
                for (var assessment in submittedAssessments) {
                  if (assessment is Map<String, dynamic>) {
                    totalSubmissions++;
                    bool isGraded = assessment['gradedBy'] != null ||
                        assessment['gradedAt'] != null;
                    if (isGraded) {
                      markedSubmissions++;
                    } else {
                      pendingSubmissions++;
                    }
                  }
                }
              }
            }
          }
        }
      }

      double averageRating = lecturerData['rating']?.toDouble() ?? 0.0;

      return {
        'totalSubmissions': totalSubmissions,
        'markedSubmissions': markedSubmissions,
        'pendingSubmissions': pendingSubmissions,
        'averageRating': averageRating,
      };
    } catch (e) {
      return {
        'totalSubmissions': 0,
        'markedSubmissions': 0,
        'pendingSubmissions': 0,
        'averageRating': 0.0,
      };
    }
  }

  void _showStatsDialog() async {
    showDialog(
      context: context,
      builder: (context) => FutureBuilder<Map<String, dynamic>>(
        future: _fetchLecturerStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AlertDialog(
              content: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasError) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Failed to load statistics'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close'),
                ),
              ],
            );
          }

          final stats = snapshot.data!;
          return AlertDialog(
            title: Text(
              'Assessment Statistics',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lecturer: ${widget.name}',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 20),
                _buildStatRow(
                  'Total Submissions',
                  stats['totalSubmissions'].toString(),
                  Icons.assignment,
                ),
                SizedBox(height: 12),
                _buildStatRow(
                  'Marked',
                  stats['markedSubmissions'].toString(),
                  Icons.check_circle,
                  color: Colors.green,
                ),
                SizedBox(height: 12),
                _buildStatRow(
                  'Pending',
                  stats['pendingSubmissions'].toString(),
                  Icons.pending,
                  color: Colors.orange,
                ),
                SizedBox(height: 12),
                _buildStatRow(
                  'Average Rating',
                  stats['averageRating'].toStringAsFixed(1),
                  Icons.star,
                  color: Colors.amber,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon,
      {Color? color}) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (color ?? Colors.blue).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color ?? Colors.blue),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              color: color ?? Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Material(
        borderRadius: BorderRadius.circular(15),
        elevation: 5,
        child: Container(
          height: 300,
          width: 250,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  // Profile Image
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    child: widget.image.startsWith('http') ||
                            widget.image.startsWith('https')
                        ? ImageNetwork(
                            key: ValueKey(widget.image),
                            image: widget.image,
                            height: 180,
                            width: 250,
                            fitAndroidIos: BoxFit.cover,
                            fitWeb: BoxFitWeb.cover,
                            onLoading: const Center(
                              child: CircularProgressIndicator(),
                            ),
                            onError: Image.asset(
                              'images/person1.png',
                              height: 180,
                              width: 250,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            widget.image,
                            height: 180,
                            width: 250,
                            fit: BoxFit.cover,
                          ),
                  ),
                  // Green Gradient Overlay
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Mycolors().green.withOpacity(0.7),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Rating Tag for Lecturers
                  if (widget.isLecturer == true) ...[
                    if (widget.rating != null)
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Mycolors().darkTeal,
                          ),
                          child: Text(
                            widget.rating!,
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(Icons.assessment,
                              color: Mycolors().darkTeal),
                          onPressed: _showStatsDialog,
                          tooltip: 'View Assessment Statistics',
                          padding: EdgeInsets.all(8),
                          constraints: BoxConstraints(),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.name,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 5, bottom: 5),
                child: Text(
                  widget.number,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  width: 300,
                  height: 2,
                  color: const Color.fromARGB(255, 189, 189, 189),
                ),
              ),
              if (widget.isContentDev == true)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: DisplayCardIcons(
                        icon: Icons.library_books_outlined,
                        count: widget.contentTotal ?? '',
                        tooltipText: 'Courses',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.edit_outlined,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Content Dev',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              if (widget.isLecturer == true)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: DisplayCardIcons(
                        icon: Icons.person_outline,
                        count: widget.studentAmount ?? '',
                        tooltipText: 'Students',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        children: [
                          Image.asset('images/hatIcon.png'),
                          const SizedBox(width: 8),
                          Text(
                            'Lecturer',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (widget.trailing != null) ...[
                            const SizedBox(width: 8),
                            widget.trailing!,
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              if (widget.isFacilitator == true)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: DisplayCardIcons(
                        icon: Icons.person_outline,
                        count: widget.studentAmount ?? '',
                        tooltipText: 'Students',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.groups,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Facilitator',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              // Add bottom section for students
              if (widget.isLecturer == false &&
                  widget.isContentDev != true &&
                  widget.isFacilitator != true)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: DisplayCardIcons(
                        icon: Icons.book_outlined,
                        count: widget.studentAmount ?? '0',
                        tooltipText: 'Courses',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.school_outlined,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Student',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (widget.trailing != null) ...[
                            const SizedBox(width: 8),
                            widget.trailing!,
                          ],
                        ],
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
