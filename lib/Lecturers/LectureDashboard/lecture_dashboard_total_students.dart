import 'package:a4m/Constants/myColors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LectureDashboardTotalStudents extends StatefulWidget {
  final String lecturerId;

  const LectureDashboardTotalStudents({super.key, required this.lecturerId});

  @override
  State<LectureDashboardTotalStudents> createState() =>
      _LectureDashboardTotalStudentsState();
}

class _LectureDashboardTotalStudentsState
    extends State<LectureDashboardTotalStudents> {
  int totalStudents = 0;
  int monthlyStudents = 0;

  @override
  void initState() {
    super.initState();
    fetchStudentMetrics();
  }

  Future<void> fetchStudentMetrics() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      int tempTotalStudents = 0;
      int tempMonthlyStudents = 0;

      final coursesSnapshot =
          await FirebaseFirestore.instance.collection('courses').get();

      for (var courseDoc in coursesSnapshot.docs) {
        final courseData = courseDoc.data();
        final assignedLecturers =
            courseData['assignedLecturers'] as List<dynamic>?;

        if (assignedLecturers != null) {
          bool lecturerFound = assignedLecturers.any((lecturer) =>
              lecturer is Map<String, dynamic> &&
              lecturer['id'] == widget.lecturerId);

          if (lecturerFound) {
            final students = courseData['students'] as List<dynamic>?;
            if (students != null) {
              tempTotalStudents += students.length;

              for (var student in students) {
                final registered =
                    (student['registered'] as Timestamp?)?.toDate();
                if (registered != null && registered.isAfter(startOfMonth)) {
                  tempMonthlyStudents += 1;
                }
              }
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          totalStudents = tempTotalStudents;
          monthlyStudents = tempMonthlyStudents;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          totalStudents = 0;
          monthlyStudents = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200, // Fixed height
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4.0,
            spreadRadius: 2.0,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Students',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Center(
            child: Text(
              totalStudents.toString(),
              style: const TextStyle(
                fontSize: 48.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Mycolors().green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_upward,
                    color: Mycolors().green,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$monthlyStudents new',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      color: Mycolors().green,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: Text(
              'Current Month',
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                color: Colors.grey[400],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
