import 'package:a4m/CommonComponents/displayCardIcons.dart';
import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CourseContainers extends StatelessWidget {
  final List<Map<String, dynamic>>? courses;
  const CourseContainers({super.key, this.courses});

  @override
  Widget build(BuildContext context) {
    if (courses == null) {
      return Center(
        child: CircularProgressIndicator(color: Mycolors().green),
      );
    }
    if (courses!.isEmpty) {
      return Center(
        child: Text(
          'No courses available',
          style: GoogleFonts.montserrat(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    // Responsive grid: 1-4 columns
    final screenWidth = MediaQuery.of(context).size.width;
    int columns = 1;
    if (screenWidth > 1200) {
      columns = 4;
    } else if (screenWidth > 900) {
      columns = 3;
    } else if (screenWidth > 600) {
      columns = 2;
    }
    return Center(
      child: Wrap(
        spacing: 24,
        runSpacing: 24,
        children: courses!.map((course) => _buildCourseCard(course)).toList(),
      ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
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
            Container(
              width: 320,
              height: 180,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                child: course['courseImageUrl'] != null &&
                        course['courseImageUrl'].toString().isNotEmpty
                    ? Image.network(
                        course['courseImageUrl'],
                        width: 320,
                        height: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset('images/course1.png',
                              width: 320, height: 180, fit: BoxFit.cover);
                        },
                      )
                    : Image.asset('images/course1.png',
                        width: 320, height: 180, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                course['courseName'] ?? 'Course Name',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 5, bottom: 5),
              child: Text(
                course['courseDescription'] ?? '',
                style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                width: 300,
                height: 2,
                color: const Color.fromARGB(255, 189, 189, 189),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      DisplayCardIcons(
                          icon: Icons.format_list_numbered,
                          count: (course['assessmentCount'] ?? '0').toString(),
                          tooltipText: 'Assessments'),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      DisplayCardIcons(
                          icon: Icons.library_books,
                          count: (course['moduleCount'] ?? '0').toString(),
                          tooltipText: 'Modules'),
                    ],
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
