import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SlimButtons extends StatelessWidget {
  final String buttonText;
  final Color buttonColor;
  final Function() onPressed;
  final double customWidth;
  final double customHeight;
  final Color? borderColor;
  final Color? textColor;

  const SlimButtons(
      {super.key,
      required this.buttonText,
      required this.buttonColor,
      required this.onPressed,
      required this.customWidth,
      this.customHeight = 50,
      this.borderColor,
      this.textColor});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: customHeight,
        width: customWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: buttonColor,
          border: borderColor != null ? Border.all(color: borderColor!) : null,
        ),
        child: Center(
          child: Text(
            buttonText,
            style: GoogleFonts.montserrat(
              color: textColor ?? Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
