import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_network/image_network.dart';
import 'package:a4m/CommonComponents/displayCardIcons.dart';
import 'package:a4m/Themes/Constants/myColors.dart';

class BrowseCourseContainer extends StatelessWidget {
  final String imagePath; // URL for the course image
  final String courseName;
  final String description;
  final String price;
  final int moduleCount; // Static or fetched value for modules
  final int assessmentCount; // Static or fetched value for assessments
  final int studentCount; // Static or fetched value for students

  const BrowseCourseContainer({
    super.key,
    required this.imagePath,
    required this.courseName,
    required this.description,
    required this.price,
    required this.moduleCount,
    required this.assessmentCount,
    required this.studentCount,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(15),
      elevation: 5,
      child: Container(
        height: 340,
        width: 320,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Gradient and Price Tag
            Stack(
              children: [
                // Course Image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  child: ImageNetwork(
                    image: imagePath, // URL for the image
                    height: 180, // Preserves your UI dimensions
                    width: 320,
                    fitAndroidIos: BoxFit.cover,
                    fitWeb: BoxFitWeb.cover,
                  ),
                ),
                // Green Gradient Overlay
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0x00ECF5DE), // Transparent green
                            Color(0x8F8AB747), // Visible green
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                ),
                // Price Tag
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Mycolors().darkTeal,
                    ),
                    child: Text(
                      price,
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Course Name
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                courseName,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            // Description
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
              child: Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(),
            // Divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                width: 300,
                height: 2,
                color: const Color.fromARGB(255, 189, 189, 189),
              ),
            ),
            // Icons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Student Count
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: DisplayCardIcons(
                    icon: Icons.person,
                    count: studentCount.toString(),
                    tooltipText: 'Students',
                  ),
                ),
                // Assessment Count
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: DisplayCardIcons(
                    icon: Icons.format_list_numbered,
                    count: assessmentCount.toString(),
                    tooltipText: 'Assessments',
                  ),
                ),
                // Module Count
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: DisplayCardIcons(
                    icon: Icons.library_books,
                    count: moduleCount.toString(),
                    tooltipText: 'Modules',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
