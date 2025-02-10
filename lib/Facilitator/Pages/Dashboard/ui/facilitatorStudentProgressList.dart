import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../myutility.dart';
import 'studentProgressListItem.dart'; // Ensure correct import

class FacilitatorStudentProgressList extends StatefulWidget {
  const FacilitatorStudentProgressList({super.key});

  @override
  State<FacilitatorStudentProgressList> createState() =>
      _FacilitatorStudentProgressListState();
}

class _FacilitatorStudentProgressListState
    extends State<FacilitatorStudentProgressList> {
  final List<Map<String, dynamic>> dummyStudents = List.generate(
    10,
    (index) => {
      'name': 'Student ${index + 1}',
      'course': 'Course ${(index % 3) + 1}',
      'progress': (index + 1) * 0.1, // Progress from 0.1 to 1.0
    },
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MyUtility(context).height * 0.62 - 80,
      width: MyUtility(context).width * 0.78 - 310,
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
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Student Progress',
              style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: ListView.builder(
                itemCount: dummyStudents.length,
                itemBuilder: (context, index) {
                  final student = dummyStudents[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: StudentProgressListItem(
                      studentName: student['name'],
                      courseName: student['course'],
                      progress: student['progress'],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
