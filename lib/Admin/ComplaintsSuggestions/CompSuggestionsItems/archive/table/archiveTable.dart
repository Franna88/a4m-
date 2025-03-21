import 'package:a4m/Admin/ComplaintsSuggestions/CompSuggestionsItems/new/table/ui/compSuggestionStatus.dart';
import 'package:a4m/CommonComponents/buttons/slimButtons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../Themes/Constants/myColors.dart';
import '../../../../../../TableWidgets/tableStructure.dart';

class ArchiveTable extends StatefulWidget {
  const ArchiveTable({super.key});

  @override
  State<ArchiveTable> createState() => _ArchiveTableState();
}

class _ArchiveTableState extends State<ArchiveTable> {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> archiveCompSuggestions = [
      {
        'from': 'James Harmse',
        'dateAdded': '2024-02-01',
      },
      {
        'from': 'Anton Clark',
        'dateAdded': '2024-02-01',
      },
      {
        'from': 'Kyle Arms',
        'dateAdded': '2024-02-01',
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
                  'From',
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
                  'Status',
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
        ...List.generate(archiveCompSuggestions.length, (index) {
          final course = archiveCompSuggestions[index];
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
                    course['from']!,
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
                    child: CompSuggestionStatus(
                  isResolved: true,
                )),
              ),
              TableStructure(
                child: TableCell(
                  child: SlimButtons(
                    buttonText: 'View',
                    buttonColor: Mycolors().peach,
                    onPressed: () {},
                    customWidth: 80,
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
