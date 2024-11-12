import 'package:a4m/Admin/AdminMessaging/ui/adminMessagingItems/importantMessages/table/adminImportMessagesTable.dart';
import 'package:flutter/material.dart';

import '../../../../../myutility.dart';

class AdminImportantMessages extends StatefulWidget {
  const AdminImportantMessages({super.key});

  @override
  State<AdminImportantMessages> createState() => _AdminImportantMessagesState();
}

class _AdminImportantMessagesState extends State<AdminImportantMessages> {
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
        child: AdminImportMessagesTable());
  }
}
