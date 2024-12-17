import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatContainers extends StatefulWidget {
  final String header;
  final String count;
  const StatContainers({super.key, required this.header, required this.count});

  @override
  State<StatContainers> createState() => _StatContainersState();
}

class _StatContainersState extends State<StatContainers> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Color.fromRGBO(138, 183, 71, 0.29),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.header,
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                shadows: [
                  Shadow(
                    color: const Color.fromARGB(85, 0, 0, 0),
                    offset: Offset(3, 3),
                    blurRadius: 2,
                  ),
                ]),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            widget.count,
            style: GoogleFonts.inter(
                color: Mycolors().green,
                fontWeight: FontWeight.bold,
                fontSize: 30),
          )
        ],
      ),
    );
  }
}
