import 'package:a4m/CommonComponents/messaging/messaging_page.dart';
import 'package:a4m/CommonComponents/messaging/simple_messaging.dart';
import 'package:flutter/material.dart';

class FacilitatorMessaging extends StatefulWidget {
  final String facilitatorId;

  const FacilitatorMessaging({
    Key? key,
    required this.facilitatorId,
  }) : super(key: key);

  @override
  State<FacilitatorMessaging> createState() => _FacilitatorMessagingState();
}

class _FacilitatorMessagingState extends State<FacilitatorMessaging> {
  bool _useSimpleMessaging = true; // Set to true to use the simple version

  @override
  Widget build(BuildContext context) {
    // Debug print to verify the ID is passed correctly
    print('FacilitatorMessaging: Building with ID ${widget.facilitatorId}');

    // If the ID is empty, show a meaningful error
    if (widget.facilitatorId.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Error: Missing facilitator ID',
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
            userId: widget.facilitatorId,
            userRole: 'facilitator',
          )
        : MessagingPage(
            userId: widget.facilitatorId,
            userRole: 'facilitator',
          );
  }
}
