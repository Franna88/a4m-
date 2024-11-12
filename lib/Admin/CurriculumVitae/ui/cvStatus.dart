import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CvStatus extends StatefulWidget {
  final bool isSeen;
  const CvStatus({super.key, required this.isSeen});

  @override
  State<CvStatus> createState() => _CvStatusState();
}

class _CvStatusState extends State<CvStatus> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: 110,
      color: const Color.fromARGB(255, 141, 141, 141),
      child: Center(
        child: Text(
          widget.isSeen == true ? 'Seen' : 'Pending',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: widget.isSeen == true
                ? Color.fromRGBO(15, 255, 67, 1)
                : const Color.fromARGB(255, 252, 231, 42),
          ),
        ),
      ),
    );
  }
}
