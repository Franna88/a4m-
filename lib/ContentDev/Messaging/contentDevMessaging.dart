import 'package:a4m/CommonComponents/messaging/messaging_page.dart';
import 'package:a4m/CommonComponents/messaging/simple_messaging.dart';
import 'package:flutter/material.dart';

class ContentDevMessaging extends StatefulWidget {
  final String contentDevId;

  const ContentDevMessaging({
    Key? key,
    required this.contentDevId,
  }) : super(key: key);

  @override
  State<ContentDevMessaging> createState() => _ContentDevMessagingState();
}

class _ContentDevMessagingState extends State<ContentDevMessaging> {
  bool _useSimpleMessaging = true; // Set to true to use the simple version

  @override
  Widget build(BuildContext context) {
    // Debug print to verify the ID is passed correctly
    print('ContentDevMessaging: Building with ID ${widget.contentDevId}');

    // If the ID is empty, show a meaningful error
    if (widget.contentDevId.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Error: Missing content developer ID',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Please log in again to fix this issue',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Use simple messaging UI for now to ensure something displays
    return _useSimpleMessaging
        ? SimpleMessagingPage(
            userId: widget.contentDevId,
            userRole: 'contentdev',
          )
        : MessagingPage(
            userId: widget.contentDevId,
            userRole: 'contentdev',
          );
  }
}
