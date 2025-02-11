import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../Constants/myColors.dart';
import '../../../../myutility.dart';

class FacilitatorTotalStudents extends StatefulWidget {
  const FacilitatorTotalStudents({super.key});

  @override
  State<FacilitatorTotalStudents> createState() =>
      _FacilitatorTotalStudentsState();
}

class _FacilitatorTotalStudentsState extends State<FacilitatorTotalStudents> {
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '120',
                // totalStudents.toString(),
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
                    '4',
                    // monthlyStudents.toString(),
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
