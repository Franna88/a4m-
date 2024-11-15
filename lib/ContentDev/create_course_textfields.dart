import 'package:flutter/material.dart';

class CreateCourseTextfields extends StatelessWidget {
  final String title;
  final double widthFactor;
  final double heightFactor;
  final TextEditingController controller;
  final int maxLines; // Added to support multiple lines

  CreateCourseTextfields({
    required this.title,
    this.widthFactor = 0.3,
    this.heightFactor = 0.05,
    required this.controller,
    this.maxLines = 1, // Default to single line
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Container(
          width: width * widthFactor,
          child: TextField(
            controller: controller,
            maxLines: null, // Set the maxLines for multiline text
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }
}
