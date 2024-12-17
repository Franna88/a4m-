import 'package:a4m/CommonComponents/buttons/slimButtons.dart';
import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:a4m/TableWidgets/tableStructure.dart';

class ReviewMarksTable extends StatefulWidget {
  const ReviewMarksTable({super.key});

  @override
  State<ReviewMarksTable> createState() => _ReviewMarksTableState();
}

class _ReviewMarksTableState extends State<ReviewMarksTable> {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> reviewMarks = [
      {
        'lecturer': 'James Harmse',
        'student': 'Albert Okley',
        'date': '2024-02-04',
        'course': 'Production Technology',
        'module': 'Module 1',
      },
      {
        'lecturer': 'Carla Owens',
        'student': 'Albert Okley',
        'date': '2024-02-04',
        'course': 'Production Technology',
        'module': 'Module 2',
      },
      {
        'lecturer': 'Kurt Armes',
        'student': 'Simon Sanders',
        'date': '2024-02-04',
        'course': 'Production Technology',
        'module': 'Module 1',
      },
    ];

    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            color: Mycolors().green,
            border: Border(
              bottom: BorderSide(color: Colors.black),
            ),
          ),
          children: [
            TableStructure(
              child: TableCell(
                child: Text(
                  'Lecturer',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            TableStructure(
              child: TableCell(
                child: Text(
                  'Student',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            TableStructure(
              child: TableCell(
                child: Text(
                  'Date',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            TableStructure(
              child: TableCell(
                child: Text(
                  'Course',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            TableStructure(
              child: TableCell(
                child: Text(
                  'Module',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            TableStructure(
              child: TableCell(
                child: Text(
                  'Details',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        ...List.generate(reviewMarks.length, (index) {
          final course = reviewMarks[index];
          return TableRow(
            decoration: BoxDecoration(
              color: index % 2 == 1
                  ? Colors.white
                  : Color.fromRGBO(209, 210, 146, 0.50),
              border: Border(
                bottom: BorderSide(width: 1, color: Colors.black),
              ),
            ),
            children: [
              TableStructure(
                child: TableCell(
                  child: Text(
                    course['lecturer']!,
                    style: GoogleFonts.montserrat(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              TableStructure(
                child: TableCell(
                  child: Text(
                    course['student']!,
                    style: GoogleFonts.montserrat(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              TableStructure(
                child: TableCell(
                  child: Text(
                    course['date']!,
                    style: GoogleFonts.montserrat(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              TableStructure(
                child: TableCell(
                  child: Text(
                    overflow: TextOverflow.ellipsis,
                    course['course']!,
                    style: GoogleFonts.montserrat(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              TableStructure(
                child: TableCell(
                  child: Text(
                    course['module']!,
                    style: GoogleFonts.montserrat(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              TableStructure(
                child: TableCell(
                  child: SizedBox(
                    width: 80,
                    child: SlimButtons(
                      buttonText: 'View',
                      buttonColor: Mycolors().peach,
                      onPressed: () {},
                      customWidth: 100,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}
