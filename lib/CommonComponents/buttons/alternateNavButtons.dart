import 'package:a4m/Constants/myColors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AlternateNavButtons extends StatefulWidget {
  final String buttonText;
  final Function() onTap;
  final bool isActive;
  const AlternateNavButtons({super.key, required this.buttonText, required this.onTap, required this.isActive});

  @override
  State<AlternateNavButtons> createState() => _AlternateNavButtonsState();
}

class _AlternateNavButtonsState extends State<AlternateNavButtons> {
  

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        width: 220,
        height: 40,
        decoration: BoxDecoration(
          color: widget.isActive ? Mycolors().darkTeal : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            width: 2,
            color: Colors.black,
          ),
        ),
        child: Center(
          child: Text(
            widget.buttonText,
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                color: widget.isActive ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }
}
