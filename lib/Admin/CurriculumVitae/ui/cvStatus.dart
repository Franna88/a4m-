import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CvStatus extends StatefulWidget {
  final String status; // Changed from bool to String to allow more status types
  const CvStatus({super.key, required this.status});

  @override
  State<CvStatus> createState() => _CvStatusState();
}

class _CvStatusState extends State<CvStatus> {
  @override
  Widget build(BuildContext context) {
    Color statusColor;

    // Determine the color based on the status value
    switch (widget.status.toLowerCase()) {
      case 'seen':
        statusColor = const Color.fromRGBO(15, 255, 67, 1); // Green
        break;
      case 'pending':
        statusColor = const Color.fromARGB(255, 252, 231, 42); // Yellow
        break;
      default:
        statusColor = const Color.fromARGB(255, 141, 141, 141); // Default Grey
    }

    return Container(
      height: 30,
      width: 110,
      color: const Color.fromARGB(255, 141, 141, 141),
      child: Center(
        child: Text(
          widget.status,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: statusColor,
          ),
        ),
      ),
    );
  }
}
