import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;

  const CustomTabBar({
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Color(0xFFEAF1FF), // Background color for the tab bar
        borderRadius: BorderRadius.circular(8), // Rounded corners
      ),
      child: Row(
        children: [
          _buildTab('All', 0),
          _buildTab('Active', 1),
          _buildTab('Completed', 2),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    bool isSelected = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          onTabSelected(index); // Call the callback to update the selected index
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF1A8CF0) : Colors.transparent, // Tab background color
            borderRadius: BorderRadius.circular(8), // Rounded corners for the tab
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Color(0xFF002A6A), // Text color
              fontWeight: FontWeight.w600, // Bold text for better visibility
            ),
          ),
        ),
      ),
    );
  }
}
