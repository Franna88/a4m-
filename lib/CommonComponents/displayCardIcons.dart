import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DisplayCardIcons extends StatefulWidget {
  final IconData icon;
  final String count;
  final String tooltipText;
  final Color? iconColor;
  const DisplayCardIcons({
    super.key,
    required this.icon,
    required this.count,
    required this.tooltipText,
    this.iconColor,
  });

  @override
  State<DisplayCardIcons> createState() => _DisplayCardIconsState();
}

class _DisplayCardIconsState extends State<DisplayCardIcons> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Tooltip(
          message: widget.tooltipText,
          child: Icon(
            widget.icon,
            color: widget.iconColor ?? Mycolors().green,
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        Text(
          widget.count,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }
}
