import 'package:a4m/Constants/myColors.dart';
import 'package:a4m/Lecturers/LectureDashboard/dashboard_card.dart';
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

      // Use sets to track unique students
      final Set<String> uniqueStudentIds = {};
      final Set<String> uniqueMonthlyStudentIds = {};

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
              for (var student in students) {
                if (student is Map<String, dynamic> &&
                    student['studentId'] != null) {
                  uniqueStudentIds.add(student['studentId'].toString());

                  final registered = student['registered'];
                  if (registered != null) {
                    final registeredDate = registered is Timestamp
                        ? registered.toDate()
                        : registered is DateTime
                            ? registered
                            : null;

                    if (registeredDate != null &&
                        registeredDate.isAfter(startOfMonth)) {
                      uniqueMonthlyStudentIds
                          .add(student['studentId'].toString());
                    }
                  }
                }
              }
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          totalStudents = uniqueStudentIds.length;
          monthlyStudents = uniqueMonthlyStudentIds.length;
        });
      }
    } catch (e) {
      print('Error fetching student metrics: $e');
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
    return DashboardMetricCard(
      title: 'Total Students',
      value: totalStudents.toString(),
      subtitle: '$monthlyStudents new',
      icon: Icons.arrow_upward,
      iconColor: Mycolors().green,
      subtitleColor: Mycolors().green,
    );
  }
}
