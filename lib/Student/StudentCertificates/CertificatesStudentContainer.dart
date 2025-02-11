import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:a4m/CommonComponents/displayCardIcons.dart';
import 'package:a4m/Themes/Constants/myColors.dart';

class CertificatesStudentContainer extends StatefulWidget {
  final String imagePath;
  final String courseName;
  final String description;
  final String price;
  final int assessmentCount;
  final int moduleCount;

  const CertificatesStudentContainer({
    super.key,
    required this.imagePath,
    required this.courseName,
    required this.description,
    required this.price,
    required this.assessmentCount,
    required this.moduleCount,
  });

  @override
  State<CertificatesStudentContainer> createState() =>
      _CertificatesStudentContainerState();
}

class _CertificatesStudentContainerState
    extends State<CertificatesStudentContainer> {
  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(15),
      elevation: 5,
      child: Container(
        height: 340,
        width: 320,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Image
            Container(
              width: 320,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                image: DecorationImage(
                  image: AssetImage(widget.imagePath),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [
                  const Spacer(),
                  // Price Tag
                  Container(
                    height: 60,
                    width: 320,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Mycolors().green,
                          const Color.fromARGB(0, 255, 255, 255),
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Container(
                          height: 30,
                          width: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Mycolors().darkTeal,
                          ),
                          child: Center(
                            child: Text(
                              widget.price,
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Course Name
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.courseName,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            // Description
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 5, bottom: 5),
              child: Text(
                widget.description,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(),
            // Divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                width: 300,
                height: 2,
                color: const Color.fromARGB(255, 189, 189, 189),
              ),
            ),
            // Icons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: DisplayCardIcons(
                    icon: Icons.format_list_numbered,
                    count: widget.assessmentCount.toString(),
                    tooltipText: 'Assessments',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: DisplayCardIcons(
                    icon: Icons.library_books,
                    count: widget.moduleCount.toString(),
                    tooltipText: 'Modules',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
