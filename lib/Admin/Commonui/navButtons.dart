import 'package:a4m/Constants/myColors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NavButtons extends StatefulWidget {
  final String buttonText;
  final Function() onTap;
  const NavButtons({super.key, required this.buttonText, required this.onTap});

  @override
  State<NavButtons> createState() => _NavButtonsState();
}

class _NavButtonsState extends State<NavButtons> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        width: 220,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? Mycolors().green : Colors.white,
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
                color: isSelected ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }
}
