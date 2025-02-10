import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../CommonComponents/displayCardIcons.dart';
import '../../../../Constants/myColors.dart';

class FacilitatorCourseContainers extends StatefulWidget {
  final bool isAssignStudent;
  final String courseName;
  final String courseDescription;
  final String totalStudents;
  final String totalAssesments;
  final String totalModules;
  final String courseImage;
  final String coursePrice;
  const FacilitatorCourseContainers(
      {super.key,
      required this.isAssignStudent,
      required this.courseName,
      required this.courseDescription,
      required this.totalStudents,
      required this.totalAssesments,
      required this.totalModules,
      required this.courseImage,
      required this.coursePrice});

  @override
  State<FacilitatorCourseContainers> createState() =>
      _FacilitatorCourseContainersState();
}

class _FacilitatorCourseContainersState
    extends State<FacilitatorCourseContainers> {
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
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                image: DecorationImage(
                  image: AssetImage(widget.courseImage),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [
                  const Spacer(),
                  Container(
                    height: 60,
                    width: 320,
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
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Container(
                          height: 30,
                          width: widget.isAssignStudent == true ? 150 : 80,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: widget.isAssignStudent == true
                                  ? Mycolors().blue
                                  : Mycolors().darkTeal),
                          child: Center(
                            child: Text(
                              widget.isAssignStudent == true
                                  ? 'Assign Student'
                                  : widget.coursePrice,
                              style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
                //'This learnership provides a solid foundation in operations, quality, maintenance and safety aspects of a business. ',
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
                      count: widget.totalAssesments,
                      tooltipText: 'Assessments'),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: DisplayCardIcons(
                      icon: Icons.library_books,
                      count: widget.totalModules,
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
