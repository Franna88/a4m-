import 'package:a4m/CommonComponents/displayCardIcons.dart';
import 'package:a4m/Constants/myColors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_network/image_network.dart';

class DevelopedCourseEdit extends StatefulWidget {
  final String courseName;
  final String modulesComplete;
  final String courseDescription;
  final String totalStudents;
  final String moduleAmount;
  final String assessmentAmount;
  final String courseImage;
  final Function() onTap;
  final Function(int) changePage;
  const DevelopedCourseEdit(
      {super.key,
      required this.courseName,
      required this.modulesComplete,
      required this.courseDescription,
      required this.totalStudents,
      required this.moduleAmount,
      required this.assessmentAmount,
      required this.courseImage,
      required this.onTap,
      required this.changePage});

  @override
  State<DevelopedCourseEdit> createState() => _DevelopedCourseEditState();
}

class _DevelopedCourseEditState extends State<DevelopedCourseEdit> {
  var pageIndex = 0;

  void changePage(int index) {
    setState(() {
      pageIndex = index;
    });
    changePage(5);
  }

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
            Container(
              width: 320,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                child: Stack(
                  children: [
                    // Background Image using ImageNetwork
                    Positioned.fill(
                      child: ImageNetwork(
                        image: widget
                            .courseImage, // Firebase URL for the course image
                        fitWeb: BoxFitWeb.cover, // Adjust for web compatibility
                        fitAndroidIos: BoxFit.cover, // Adjust for mobile
                        height: 180,
                        width: 320,
                        duration: 500,

                        onLoading: const Center(
                          child:
                              CircularProgressIndicator(), // Loading indicator
                        ),
                      ),
                    ),
                    // Gradient Overlay
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Mycolors().green,
                              const Color.fromARGB(0, 255, 255, 255),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {
                                widget
                                    .changePage(5); // Navigate to modules page
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Container(
                                  height: 45,
                                  width: 45,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Mycolors().darkTeal,
                                  ),
                                  child: Center(
                                    child: Text(
                                      widget.modulesComplete,
                                      style: GoogleFonts.montserrat(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.courseName,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 5, bottom: 5),
              child: Text(
                widget.courseDescription,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: DisplayCardIcons(
                      icon: Icons.person_outline,
                      count: widget.totalStudents,
                      tooltipText: 'Students'),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: DisplayCardIcons(
                      icon: Icons.format_list_numbered,
                      count: widget.assessmentAmount,
                      tooltipText: 'Assessments'),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: DisplayCardIcons(
                      icon: Icons.library_books,
                      count: widget.moduleAmount,
                      tooltipText: 'Modules'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
