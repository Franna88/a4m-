import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../myutility.dart';
import 'circularPercentageIndicator.dart';

class FacilitatorStudentPassRate extends StatefulWidget {
  final double percentage;
  const FacilitatorStudentPassRate({super.key, required this.percentage});

  @override
  State<FacilitatorStudentPassRate> createState() =>
      _FacilitatorStudentPassRateState();
}

class _FacilitatorStudentPassRateState
    extends State<FacilitatorStudentPassRate> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MyUtility(context).height * 0.45 - 95,
      width: MyUtility(context).width < 1300
          ? MyUtility(context).width * 0.45 - 280
          : MyUtility(context).width * 0.38 - 280,
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
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Student Pass Rate',
                style:
                    GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            CircularPercentageIndicator(percentage: widget.percentage),
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
      ),
    );
  }
}
