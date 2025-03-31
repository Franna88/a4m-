import 'package:flutter/material.dart';
import '../../../../myutility.dart';
import 'table/newCompSuggestionTable.dart';

class NewCompSuggestionsList extends StatelessWidget {
  const NewCompSuggestionsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
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
      child: const NewCompSuggestionTable(),
    );
  }
}
