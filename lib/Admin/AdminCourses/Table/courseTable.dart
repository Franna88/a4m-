import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:a4m/Constants/myColors.dart';
import 'package:a4m/TableWidgets/tableStructure.dart';

class CourseTable extends StatefulWidget {
  const CourseTable({super.key});

  @override
  State<CourseTable> createState() => _CourseTableState();
}

class _CourseTableState extends State<CourseTable> {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> courses = [
      {
        'courseName': 'Tech Dev',
        'dateAdded': '2024-02-01',
        'totalStudents': '120',
        'currentPrice': 'R 1500.00',
        'totalSales': '500',
      },
      {
        'courseName': 'Production Management',
        'dateAdded': '2024-01-20',
        'totalStudents': '95',
        'currentPrice': 'R 1800.00',
        'totalSales': '345',
      },
      {
        'courseName': 'Product Management',
        'dateAdded': '2024-03-15',
        'totalStudents': '75',
        'currentPrice': 'R 1100.00',
        'totalSales': '290',
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
                  'Course Name',
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
                  'Date Added',
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
                  'Total Students',
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
                  'Current Price',
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
                  'Total Sales',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
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
                  : Color.fromRGBO(209, 210, 146, 0.50) ,
              border: Border(
                bottom: BorderSide(width: 1, color: Colors.black),
              ),
            ),
            children: [
              TableStructure(
                child: TableCell(
                  child: Text(
                    course['courseName']!,
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
                    course['dateAdded']!,
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_outline),
                      const SizedBox(width: 5),
                      Text(
                        course['totalStudents']!,
                        style: GoogleFonts.montserrat(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              TableStructure(
                child: TableCell(
                  child: Text(
                    course['currentPrice']!,
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
                    course['totalSales']!,
                    style: GoogleFonts.montserrat(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
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
