import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../Constants/myColors.dart';
import '../../../../myutility.dart';

class FacilitatorTotalStudents extends StatefulWidget {
  const FacilitatorTotalStudents({super.key});

  @override
  State<FacilitatorTotalStudents> createState() =>
      _FacilitatorTotalStudentsState();
}

class _FacilitatorTotalStudentsState extends State<FacilitatorTotalStudents> {
  int _totalStudents = 0;
  int _monthlyStudents = 0;
  bool _isLoading = true;
  final String _facilitatorId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }

  Future<void> _fetchStudentData() async {
    if (_facilitatorId.isEmpty) return;

    try {
      setState(() => _isLoading = true);

      // Get all students from facilitatorStudents subcollection
      QuerySnapshot studentsSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(_facilitatorId)
          .collection('facilitatorStudents')
          .get();

      // Get current month's students
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      QuerySnapshot monthlySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(_facilitatorId)
          .collection('facilitatorStudents')
          .where('createdAt', isGreaterThanOrEqualTo: startOfMonth)
          .get();

      setState(() {
        _totalStudents = studentsSnapshot.docs.length;
        _monthlyStudents = monthlySnapshot.docs.length;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching student data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MyUtility(context).height * 0.45 - 95,
      width: MyUtility(context).width < 1300
          ? MyUtility(context).width * 0.45 - 280
          : MyUtility(context).width * 0.38 - 280,
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
              Text(
                'Total Students',
                style: GoogleFonts.kanit(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Spacer(),
          _isLoading
              ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Mycolors().green),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _totalStudents.toString(),
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
                          _monthlyStudents.toString(),
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
                style: GoogleFonts.kanit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color.fromARGB(255, 189, 189, 189),
                    letterSpacing: 1.2),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
