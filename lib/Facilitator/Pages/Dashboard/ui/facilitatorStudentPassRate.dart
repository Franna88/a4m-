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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Student Pass Rate',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          Expanded(
            child: Center(
              child: SizedBox(
                height: 80, // Even smaller circle
                width: 80,
                child:
                    CircularPercentageIndicator(percentage: widget.percentage),
              ),
            ),
          ),
          Center(
            child: Text(
              'Current Month',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[500],
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
