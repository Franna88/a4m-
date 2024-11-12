import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatusIndicators extends StatefulWidget {
  final bool isApproved;
  const StatusIndicators({super.key, required this.isApproved});

  @override
  State<StatusIndicators> createState() => _StatusIndicatorsState();
}

class _StatusIndicatorsState extends State<StatusIndicators> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: 110,
      color: const Color.fromARGB(255, 141, 141, 141),
      child: Center(
        child: Text(
          widget.isApproved == true ? 'Approved' : 'Pending',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: widget.isApproved == true
                ? Color.fromRGBO(15, 255, 67, 1)
                : const Color.fromARGB(255, 252, 231, 42),
          ),
        ),
      ),
    );
  }
}
