import 'package:a4m/CommonComponents/buttons/onHoverButton.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_network/image_network.dart';

import '../../../CommonComponents/displayCardIcons.dart';

class ReviewAssessmentsItem extends StatelessWidget {
  final String moduleName;
  final String moduleImage;
  final String moduleDescription;
  final String moduleCount;
  final String assessmentCount;
  final Function() onTap;
  final bool isPassed;
  const ReviewAssessmentsItem(
      {super.key,
      required this.moduleName,
      required this.moduleImage,
      required this.moduleDescription,
      required this.moduleCount,
      required this.assessmentCount,
      required this.onTap,
      required this.isPassed});

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
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5),
                bottomLeft: Radius.circular(5),
              ),
            ),
            child: ImageNetwork(
              image: moduleImage,
              height: 200,
              width: 200,
              fitAndroidIos: BoxFit.cover,
              fitWeb: BoxFitWeb.cover,
              onLoading: const CircularProgressIndicator(), // Loading widget
              onError:
                  const Icon(Icons.error, color: Colors.red), // Error widget
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
                    moduleName,
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  Container(
                    width: MyUtility(context).width - 584,
                    child: Text(
                      moduleDescription,
                      style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w400, fontSize: 14),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          children: [
                            DisplayCardIcons(
                                icon: Icons.format_list_numbered,
                                count: assessmentCount,
                                tooltipText: 'Assessments'),
                          ],
                        ),
                      ),
                      Text(
                        isPassed ? 'Module Passed' : 'In Progress',
                        style: GoogleFonts.inter(
                            color: isPassed
                                ? Color.fromRGBO(7, 165, 55, 1)
                                : Colors.grey,
                            fontWeight: FontWeight.w600),
                      ),
                      OnHoverButton(
                        onTap: onTap,
                        buttonText: 'Review Assessments',
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
