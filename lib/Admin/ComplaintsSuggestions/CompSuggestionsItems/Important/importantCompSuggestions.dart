import 'package:a4m/Admin/ComplaintsSuggestions/CompSuggestionsItems/Important/table/importantCompSuggestionTable.dart';

import 'package:flutter/material.dart';

import '../../../../myutility.dart';

class ImportantCompSuggestions extends StatefulWidget {
  const ImportantCompSuggestions({super.key});

  @override
  State<ImportantCompSuggestions> createState() => _ImportantCompSuggestionsState();
}

class _ImportantCompSuggestionsState extends State<ImportantCompSuggestions> {
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
        child:  ImportantCompSuggestionTable()) ;
  }
}