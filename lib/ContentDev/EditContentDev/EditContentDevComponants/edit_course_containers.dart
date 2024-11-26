import 'package:a4m/CommonComponents/displayCardIcons.dart';
import 'package:a4m/ContentDev/EditContentDev/EditContentDevComponants/delete_course_popup.dart';
import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditCourseContainers extends StatefulWidget {
  final String courseName;
  final String price;
  final String courseDescription;
  final String totalStudents;
  final String moduleAmount;
  final String assessmentAmount;
  final String courseImage;
  final Function() onTap;
  final Function() editOnTap;

  const EditCourseContainers({
    super.key,
    required this.courseName,
    required this.price,
    required this.courseDescription,
    required this.totalStudents,
    required this.moduleAmount,
    required this.assessmentAmount,
    required this.courseImage,
    required this.onTap,
    required this.editOnTap,
  });

  @override
  State<EditCourseContainers> createState() => _EditCourseContainersState();
}

class _EditCourseContainersState extends State<EditCourseContainers> {
  Future openDeleteCoursePopup() => showDialog(
      context: context,
      builder: (context) {
        return const Dialog(
          child: DeleteCoursePopup(),
        );
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Container(
                            height: 30,
                            width: 80,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Mycolors().darkTeal),
                            child: Center(
                              child: Text(
                                widget.price,
                                style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: InkWell(
                            onTap: widget.onTap,
                            child: Container(
                              height: 30,
                              width: 80,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Mycolors().peach),
                              child: Center(
                                child: Text(
                                  'Modules',
                                  style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Text(
                    widget.courseName,
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: Mycolors().green,
                      size: 20,
                    ),
                    onPressed: widget.editOnTap,
                  ),
                  SizedBox(width: 2),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Mycolors().peach,
                      size: 20,
                    ),
                    onPressed: () {
                      openDeleteCoursePopup();
                    },
                  ),
                ],
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
