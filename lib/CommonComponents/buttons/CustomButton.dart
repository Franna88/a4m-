import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatelessWidget {
  final String buttonText;
  final Color buttonColor;
  final Function() onPressed;
  final double width;
  const CustomButton(
      {super.key,
      required this.buttonText,
      required this.buttonColor,
      required this.onPressed, required this.width});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: 40,
        width: width,
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Text(
            buttonText,
            style: GoogleFonts.inter(color: const Color.fromARGB(255, 10, 10, 10), fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
