import 'package:a4m/Admin/ComplaintsSuggestions/CompSuggestionsItems/new/table/ui/compSuggestionStatus.dart';
import 'package:a4m/CommonComponents/buttons/slimButtons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../Themes/Constants/myColors.dart';
import '../../../../../../TableWidgets/tableStructure.dart';
import '../../../../../myutility.dart';

class ChatReviewTable extends StatefulWidget {
  const ChatReviewTable({super.key});

  @override
  State<ChatReviewTable> createState() => _ChatReviewTableState();
}

class _ChatReviewTableState extends State<ChatReviewTable> {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> reviewMessages = [
      {
        'from': 'James Harmse',
        'title': 'Student',
        'dateAdded': '2024-02-01',
      },
      {
        'from': 'Anton Clark',
        'title': 'Admin',
        'dateAdded': '2024-02-01',
      },
      {
        'from': 'Kyle Arms',
        'title': 'Lecturer',
        'dateAdded': '2024-02-01',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        border: Border.all(
          width: 2,
          color: Colors.black,
        ),
      ),
      width: MyUtility(context).width - 580,
      height: MyUtility(context).height - 110,
      child: Table(
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
                    'Person',
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
                    'Title',
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
                    'Chat Date',
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
                    'Messages',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          ...List.generate(reviewMessages.length, (index) {
            final course = reviewMessages[index];
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
                      course['title']!,
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
      ),
    );
  }
}
