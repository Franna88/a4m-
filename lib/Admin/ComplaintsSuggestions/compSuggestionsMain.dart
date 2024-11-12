import 'package:a4m/Admin/AdminMessaging/adminMessaging.dart';
import 'package:a4m/Admin/AdminMessaging/ui/adminMessagingItems/adminInbox.dart';
import 'package:a4m/Admin/ComplaintsSuggestions/CompSuggestionsItems/new/newCompSuggestionsList.dart';
import 'package:flutter/material.dart';



class CompSuggestionsMain extends StatefulWidget {
  const CompSuggestionsMain({super.key});

  @override
  State<CompSuggestionsMain> createState() => _CompSuggestionsMainState();
}

class _CompSuggestionsMainState extends State<CompSuggestionsMain> {
  var pageIndex = 0;

  var pages = [
   NewCompSuggestionsList(),
  ];

  void changePage(int value) {
    setState(() {
      pageIndex = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminMessaging(changePage: changePage, child: pages[pageIndex]);
  }
}
