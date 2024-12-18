import 'package:a4m/Constants/myColors.dart';
import 'package:a4m/myutility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LectureDashboardTotalStudents extends StatefulWidget {
  final String lecturerId;

  const LectureDashboardTotalStudents({Key? key, required this.lecturerId})
      : super(key: key);

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

      // Fetch all courses
      final coursesSnapshot =
          await FirebaseFirestore.instance.collection('courses').get();

      print("Fetched ${coursesSnapshot.docs.length} courses.");

      for (var courseDoc in coursesSnapshot.docs) {
        final courseData = courseDoc.data();

        // Check if the lecturer is assigned
        final assignedLecturers =
            courseData['assignedLecturers'] as List<dynamic>?;
        if (assignedLecturers != null) {
          bool lecturerFound = assignedLecturers.any((lecturer) =>
              lecturer is Map<String, dynamic> &&
              lecturer['id'] == widget.lecturerId);

          if (lecturerFound) {
            print("Lecturer assigned to course: ${courseData['courseName']}");

            // Fetch students
            final students = courseData['students'] as List<dynamic>?;
            if (students != null) {
              print(
                  "Course '${courseData['courseName']}' has ${students.length} students.");

              tempTotalStudents += students.length;

              for (var student in students) {
                final registered =
                    (student['registered'] as Timestamp?)?.toDate();

                if (registered != null && registered.isAfter(startOfMonth)) {
                  tempMonthlyStudents += 1;
                }
              }
            } else {
              print("Course '${courseData['courseName']}' has no students.");
            }
          }
        }
      }

      setState(() {
        totalStudents = tempTotalStudents;
        monthlyStudents = tempMonthlyStudents;
      });

      print("Total Students: $totalStudents");
      print("Monthly Students: $monthlyStudents");
    } catch (e) {
      print("Error fetching student metrics: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MyUtility(context).width * 0.22,
        height: MyUtility(context).height * 0.4,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              blurRadius: 2.0,
              spreadRadius: 2.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  'Total Students',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  totalStudents.toString(),
                  style: const TextStyle(
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_upward,
                      color: Mycolors().green,
                      size: 24.0,
                    ),
                    Text(
                      monthlyStudents.toString(),
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              ],
            ),
            const Spacer(),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Current Month',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
