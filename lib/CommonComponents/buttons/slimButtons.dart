import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SlimButtons extends StatelessWidget {
  final String buttonText;
  final Color buttonColor;
  final Function() onPressed;
  final double customWidth;
  const SlimButtons(
      {super.key,
      required this.buttonText,
      required this.buttonColor,
      required this.onPressed, required this.customWidth});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: 30,
        width: customWidth,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5), color: buttonColor),
        child: Center(
          child: Text(
            buttonText,
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12
            ),
          ),
        ),
      ),
    );
  }
}
