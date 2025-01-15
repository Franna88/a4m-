import 'package:flutter/material.dart';
import 'package:a4m/myutility.dart';

class ReusableCourseContainer extends StatelessWidget {
  final String courseName;
  final String courseDescription;
  final String imagePath;

  const ReusableCourseContainer({
    Key? key,
    required this.courseName,
    required this.courseDescription,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600, // Smaller width for the container
      height: 300, // Smaller height for the container
      margin: const EdgeInsets.all(8.0), // Add spacing between containers
      padding: const EdgeInsets.all(8.0), // Internal padding
      decoration: BoxDecoration(
        color: Colors.white, // Background color
        borderRadius: BorderRadius.circular(8.0), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black26, // Shadow color
            blurRadius: 4.0, // Blur effect
            offset: Offset(0, 2), // Shadow offset
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.asset(
              imagePath,
              width: 100.0, // Set the width of the image
              height: 100.0, // Set the height of the image
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course Name (Heading)
                Text(
                  courseName,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0), // Spacing between heading and description

                // Course Description (Paragraph)
                Text(
                  courseDescription,
                  maxLines: 5, // Limit to 3 lines
                  overflow: TextOverflow.ellipsis, // Add ellipsis for overflow
                  style: const TextStyle(fontSize: 14.0),
                ),
              ],
            ),
      ),
        ],
      ),
    );
  }
}
