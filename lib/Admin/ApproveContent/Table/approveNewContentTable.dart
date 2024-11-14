import 'package:a4m/CommonComponents/buttons/slimButtons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:a4m/TableWidgets/tableStructure.dart';

class ApproveNewContentTable extends StatefulWidget {
  const ApproveNewContentTable({super.key});

  @override
  State<ApproveNewContentTable> createState() => _ApproveNewContentTableState();
}

class _ApproveNewContentTableState extends State<ApproveNewContentTable> {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> reviewMarks = [
      {
        'courseModuleName': 'Production Tech',
        'date': '2024-02-04',
      },
      {
        'courseModuleName': 'Manufacturing',
        'date': '2024-02-04',
      },
      {
        'courseModuleName': 'Health & Safety',
        'date': '2024-02-04',
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
                  'Course/Module Name',
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
                  'Review',
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
                  'Approve',
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
                    course['courseModuleName']!,
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
              TableStructure(
                child: TableCell(
                  child: Container(
                    constraints: BoxConstraints(
                      minWidth: 350, // Minimum width to fit both buttons
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 100,
                          child: SlimButtons(
                            buttonText: 'Approve',
                            buttonColor: Mycolors().blue,
                            onPressed: () {},
                            customWidth: 100,
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        SizedBox(
                          width: 100,
                          child: SlimButtons(
                            buttonText: 'Decline',
                            buttonColor: Mycolors().red,
                            onPressed: () {},
                            customWidth: 100,
                          ),
                        ),
                      ],
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
