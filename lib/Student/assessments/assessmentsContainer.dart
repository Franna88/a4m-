import 'package:a4m/CommonComponents/buttons/onHoverButton.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../CommonComponents/displayCardIcons.dart';

class AssessmentsContainer extends StatefulWidget {
  final String courseName;
  final String courseImage;
  final String courseDescription;
  final String moduleCount;
  final String assessmentCount;
  final Function() onTap;
  const AssessmentsContainer(
      {super.key,
      required this.courseName,
      required this.courseImage,
      required this.courseDescription,
      required this.moduleCount,
      required this.assessmentCount,
      required this.onTap});

  @override
  State<AssessmentsContainer> createState() => _AssessmentsContainerState();
}

class _AssessmentsContainerState extends State<AssessmentsContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MyUtility(context).width - 360,
      height: 200,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(width: 2),
          color: Colors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 200,
            width: 200,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(widget.courseImage), fit: BoxFit.fill),
            ),
          ),
          Container(
            width: MyUtility(context).width - 564,
            height: 200,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.courseName,
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  Container(
                    width: MyUtility(context).width - 584,
                    child: Text(
                      widget.courseDescription,
                      style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w400, fontSize: 14),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          children: [
                            DisplayCardIcons(
                                icon: Icons.format_list_numbered,
                                count: widget.assessmentCount,
                                tooltipText: 'Assessments'),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          children: [
                            Text(
                              'Score Available 100',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      OnHoverButton(
                        onTap: () {},
                        buttonText: 'Continue',
                      )
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
