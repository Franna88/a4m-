import 'package:a4m/CommonComponents/buttons/alternateNavButtons.dart';

import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';

class CompSuggestionsNav extends StatefulWidget {
  final Function(int) changePage;
  final Widget child;
  const CompSuggestionsNav(
      {super.key, required this.child, required this.changePage});

  @override
  State<CompSuggestionsNav> createState() => _CompSuggestionsNavState();
}

class _CompSuggestionsNavState extends State<CompSuggestionsNav> {
  int activeIndex = 0;

  void _handleItemClick(int index) {
    setState(() {
      activeIndex = index;
    });
    widget.changePage(index); // Notify the parent widget to change the page
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Container(
            width: 250,
            height: MyUtility(context).height - 110,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                const SizedBox(
                  height: 40,
                ),
                AlternateNavButtons(
                  buttonText: 'New',
                  onTap: () => _handleItemClick(0),
                  isActive: activeIndex == 0,
                ),
                const SizedBox(
                  height: 20,
                ),
                AlternateNavButtons(
                  buttonText: 'Important',
                  onTap: () => _handleItemClick(1),
                  isActive: activeIndex == 1,
                ),
                const SizedBox(
                  height: 20,
                ),
                AlternateNavButtons(
                  buttonText: 'Archive',
                  onTap: () => _handleItemClick(2),
                  isActive: activeIndex == 2,
                ),
                const SizedBox(
                  height: 20,
                ),
                AlternateNavButtons(
                  buttonText: 'Chat Reviews',
                  onTap: () => _handleItemClick(3),
                  isActive: activeIndex == 3,
                ),
                const SizedBox(
                  height: 20,
                ),
                AlternateNavButtons(
                  buttonText: 'Course Reviews',
                  onTap: () => _handleItemClick(4),
                  isActive: activeIndex == 4,
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          widget.child
        ],
      ),
    );
  }
}
