import 'package:a4m/CommonComponents/buttons/slimButtons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:a4m/Constants/myColors.dart';
import 'package:a4m/TableWidgets/tableStructure.dart';

class ModuleCompleteList extends StatefulWidget {
  const ModuleCompleteList({super.key});

  @override
  State<ModuleCompleteList> createState() => _ModuleCompleteListState();
}

class _ModuleCompleteListState extends State<ModuleCompleteList> {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> reviewMarks = [
      {
        'student': 'James Harmse',
        'date': '2024-02-02',
        'course': 'Manufacturing Level 1',
        'module': 'Module 1',
      },
      {
        'student': 'Carla Owens',
        'date': '2024-02-04',
        'course': 'Manufacturing Level 1',
        'module': 'Module 1',
      },
      {
        'student': 'Kurt Armes',
        'date': '2024-02-10',
        'course': 'Manufacturing Level 1',
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
                  'Download',
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
                    overflow: TextOverflow.ellipsis,
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
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade500,
                          Colors.blue.shade700,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: IconButton(
                      onPressed: () {
                        // Add your action here
                        print("Download button pressed");
                      },
                      icon:
                          const Icon(Icons.download_sharp, color: Colors.white),
                      iconSize: 20,
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
