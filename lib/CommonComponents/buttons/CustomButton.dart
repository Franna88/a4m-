import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatelessWidget {
  final String buttonText;
  final Color buttonColor;
  final VoidCallback? onPressed; // Allow null
  final double width;

  const CustomButton({
    super.key,
    required this.buttonText,
    required this.buttonColor,
    this.onPressed, // Nullable
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed, // Null-safe handling
      child: Container(
        height: 60,
        width: width,
        decoration: BoxDecoration(
          color: onPressed == null ? Colors.grey : buttonColor, // Disable color
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Text(
            buttonText,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
