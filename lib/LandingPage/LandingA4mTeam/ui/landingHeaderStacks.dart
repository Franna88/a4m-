import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../Themes/Constants/myColors.dart';

class LandingHeaderStacks extends StatelessWidget {
  final double customWidth;
  final double boxWidth;
  final String text;
  const LandingHeaderStacks(
      {super.key,
      required this.text,
      required this.customWidth,
      required this.boxWidth});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: boxWidth,
        height: 80,
        child: Stack(
          children: [
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: customWidth,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                width: customWidth,
                height: 70,
                decoration: BoxDecoration(
                  color: Mycolors().navyBlue,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                  child: Text(
                    text,
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 33,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
