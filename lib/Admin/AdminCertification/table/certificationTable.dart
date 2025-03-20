import 'package:a4m/Admin/AdminCertification/ui/statusIndicators.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:a4m/TableWidgets/tableStructure.dart';

import '../../../CommonComponents/buttons/slimButtons.dart';

class CertificationTable extends StatefulWidget {
  const CertificationTable({super.key});

  @override
  State<CertificationTable> createState() => _CertificationTableState();
}

class _CertificationTableState extends State<CertificationTable> {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> courses = [
      {
        'student': 'James Harmse',
        'date': '2024-02-01',
        'course': 'Production Management',
      },
      {
        'student': 'James Harmse',
        'date': '2024-02-01',
        'course': 'Production Management',
      },
      {
        'student': 'James Harmse',
        'date': '2024-02-01',
        'course': 'Production Management',
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
              child: Text(
                'Student',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TableStructure(
              child: Text(
                'Date Added',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TableStructure(
              child: Text(
                'Course',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TableStructure(
              child: Text(
                'Payment Status',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TableStructure(
              child: Text(
                'Student Details',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        ...List.generate(courses.length, (index) {
          final course = courses[index];
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
                child: Text(
                  course['student']!,
                  style: GoogleFonts.montserrat(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              TableStructure(
                child: Text(
                  course['date']!,
                  style: GoogleFonts.montserrat(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              TableStructure(
                child: Text(
                  course['course']!,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.montserrat(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              TableStructure(
                child: StatusIndicators(isApproved: true),
              ),
              TableStructure(
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
            ],
          );
        }),
      ],
    );
  }
}
