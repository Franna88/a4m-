import 'package:a4m/Admin/ComplaintsSuggestions/CompSuggestionsItems/new/table/newCompSuggestionTable.dart';
import 'package:flutter/material.dart';

import '../../../../myutility.dart';

class NewCompSuggestionsList extends StatefulWidget {
  const NewCompSuggestionsList({super.key});

  @override
  State<NewCompSuggestionsList> createState() => _NewCompSuggestionsListState();
}

class _NewCompSuggestionsListState extends State<NewCompSuggestionsList> {
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
        child:  NewCompSuggestionTable()) ;
  }
}