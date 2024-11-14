import 'package:a4m/Admin/ComplaintsSuggestions/CompSuggestionsItems/Important/table/importantCompSuggestionTable.dart';
import 'package:a4m/Admin/ComplaintsSuggestions/CompSuggestionsItems/archive/table/archiveTable.dart';

import 'package:flutter/material.dart';

import '../../../../myutility.dart';

class CompSuggestionArchive extends StatefulWidget {
  const CompSuggestionArchive({super.key});

  @override
  State<CompSuggestionArchive> createState() => _CompSuggestionArchiveState();
}

class _CompSuggestionArchiveState extends State<CompSuggestionArchive> {
  @override
  Widget build(BuildContext context) {
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
      child: ArchiveTable(),
    );
  }
}
