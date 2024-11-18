import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddContentButton extends StatefulWidget {
  final String buttonText;
  final Function() onTap;
  final double width;
  final double height;

  const AddContentButton(
      {super.key,
      required this.buttonText,
      required this.onTap,
      this.width = 125,
      this.height = 40});

  @override
  State<AddContentButton> createState() => _AddContentButtonState();
}

class _AddContentButtonState extends State<AddContentButton> {
  bool isSelected = false;

  void _handleTap() {
    setState(() {
      isSelected = !isSelected;
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _handleTap,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: isSelected ? Mycolors().darkTeal : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? null
              : Border.all(
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
