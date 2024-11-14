import 'package:a4m/Admin/AdminMessaging/adminMessaging.dart';
import 'package:a4m/Admin/AdminMessaging/ui/adminMessagingItems/adminInbox.dart';
import 'package:a4m/Admin/ComplaintsSuggestions/CompSuggestionsItems/Important/importantCompSuggestions.dart';
import 'package:a4m/Admin/ComplaintsSuggestions/CompSuggestionsItems/archive/compSuggestionArchive.dart';
import 'package:a4m/Admin/ComplaintsSuggestions/CompSuggestionsItems/chatReview/ui/chatReviewMessageBox.dart';
import 'package:a4m/Admin/ComplaintsSuggestions/CompSuggestionsItems/chatReview/ui/chatReviewTable.dart';
import 'package:a4m/Admin/ComplaintsSuggestions/CompSuggestionsItems/new/newCompSuggestionsList.dart';
import 'package:a4m/Admin/ComplaintsSuggestions/compSuggestionsNav.dart';
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
    ImportantCompSuggestions(),
    CompSuggestionArchive(),
    ChatReviewTable()
  ];

  void changePage(int value) {
    setState(() {
      pageIndex = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CompSuggestionsNav(
      changePage: changePage,
      child: pages[pageIndex],
    );
  }
}
