import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CompSuggestionStatus extends StatefulWidget {
  final bool isResolved;
  const CompSuggestionStatus({super.key, required this.isResolved});

  @override
  State<CompSuggestionStatus> createState() => _CompSuggestionStatusState();
}

class _CompSuggestionStatusState extends State<CompSuggestionStatus> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: 110,
      color: const Color.fromARGB(255, 141, 141, 141),
      child: Center(
        child: Text(
          widget.isResolved == true ? 'Resolved' : 'Pending',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: widget.isResolved == true
                ? Color.fromRGBO(15, 255, 67, 1)
                : const Color.fromARGB(255, 252, 231, 42),
          ),
        ),
      ),
    );
  }
}
