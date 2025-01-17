import 'package:a4m/CommonComponents/buttons/CustomButton.dart';
import 'package:a4m/CommonComponents/displayCardIcons.dart';
import 'package:flutter/material.dart';

class ReusableCourseContainer extends StatelessWidget {
  final String courseName;
  final String courseDescription;
  final String imagePath;
  final int? contentTotal; // Add contentTotal as a parameter

  const ReusableCourseContainer({
    Key? key,
    required this.courseName,
    required this.courseDescription,
    required this.imagePath,
    this.contentTotal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 800, // Smaller width for the container
      height: 200, // Smaller height for the container
      margin: const EdgeInsets.all(8.0), // Add spacing between containers

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
        border: Border.all(
          color: Colors.black, // Black border color
          width: 2.0, // Border width
        ),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(6.0),
              bottomLeft: Radius.circular(6.0),
            ),
            child: Image.asset(
              imagePath,
              fit: BoxFit.fill,
              width: 175,
              height: 200,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
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
                  const SizedBox(
                      height: 8.0), // Spacing between heading and description

                  // Course Description (Paragraph)
                  Text(
                    courseDescription,
                    maxLines: 5, // Limit to 5 lines
                    overflow:
                        TextOverflow.ellipsis, // Add ellipsis for overflow
                    style: const TextStyle(fontSize: 14.0),
                  ),
                  const Spacer(), // Push buttons/icons to the bottom
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DisplayCardIcons(
                        icon: Icons.library_books_outlined,
                        count: contentTotal?.toString() ?? '',
                        tooltipText: 'Courses',
                      ),
                      CustomButton(
                        buttonText: "Continue",
                        buttonColor: const Color.fromARGB(255, 212, 208, 208),
                        onPressed: () {},
                        width: 90,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
