import 'package:a4m/CommonComponents/buttons/alternateNavButtons.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminMessaging extends StatefulWidget {
  final Function(int) changePage;
  final Widget child;
  final List<String>? availablePageNames;
  final String? currentUserRole;

  const AdminMessaging({
    super.key,
    required this.child,
    required this.changePage,
    this.availablePageNames,
    this.currentUserRole,
  });

  @override
  State<AdminMessaging> createState() => _AdminMessagingState();
}

class _AdminMessagingState extends State<AdminMessaging> {
  int activeIndex = 0;

  void _handleItemClick(int index) {
    setState(() {
      activeIndex = index;
    });
    widget.changePage(index);
  }

  @override
  Widget build(BuildContext context) {
    // Default button labels if no page names are provided
    final List<String> pageNames = widget.availablePageNames ??
        [
          'Inbox',
          'Important',
          'Content Devs',
          'Lecturers',
          'Students',
          'Facilitators'
        ];

    // Get screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Padding around the entire component
    const double padding = 15.0;
    // Height for the horizontal tab bar
    const double tabBarHeight = 60.0;

    // Calculate content height (total - tabbar - padding)
    final contentHeight = screenHeight - tabBarHeight - (padding * 3);

    return Container(
      height: screenHeight - 110, // Adjust for navbar/header height
      padding: const EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Horizontal Tab Bar
          Container(
            width: double.infinity,
            height: tabBarHeight,
            margin: const EdgeInsets.only(bottom: padding),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.black,
                width: 1.5,
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const SizedBox(width: 20),
                  for (int i = 0; i < pageNames.length; i++) ...[
                    if (i > 0) const SizedBox(width: 20),
                    AlternateNavButtons(
                      buttonText: pageNames[i],
                      onTap: () => _handleItemClick(i),
                      isActive: activeIndex == i,
                    ),
                  ],
                  const SizedBox(width: 20),
                ],
              ),
            ),
          ),
          // Main Content Area
          Expanded(
            child: Container(
              width: double.infinity,
              height: contentHeight,
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}
