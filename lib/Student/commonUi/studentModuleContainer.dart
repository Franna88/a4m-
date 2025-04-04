import 'package:a4m/CommonComponents/displayCardIcons.dart';
import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_network/image_network.dart';

class StudentModuleContainer extends StatefulWidget {
  final String moduleName;
  final String moduleDescription;
  final String assessmentAmount;
  final String moduleImage;
  final VoidCallback studentGuidePdfUrl;
  final VoidCallback testSheetPdfUrl;
  final VoidCallback assessmentsPdfUrl;

  const StudentModuleContainer(
      {super.key,
      required this.assessmentAmount,
      required this.moduleName,
      required this.moduleDescription,
      required this.moduleImage,
      required this.studentGuidePdfUrl,
      required this.testSheetPdfUrl,
      required this.assessmentsPdfUrl});

  @override
  State<StudentModuleContainer> createState() => _StudentModuleContainerState();
}

class _StudentModuleContainerState extends State<StudentModuleContainer> {
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
            // Network Image with Gradient Overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  child: ImageNetwork(
                    image: widget.moduleImage,
                    height: 180,
                    width: 320,
                    fitAndroidIos: BoxFit.cover,
                    fitWeb: BoxFitWeb.cover,
                    onLoading: const CircularProgressIndicator(),
                    onError: const Icon(Icons.error, color: Colors.red),
                  ),
                ),
                Positioned.fill(
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
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.moduleName,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 5, bottom: 5),
              child: Text(
                widget.moduleDescription,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: InkWell(
                    onTap: widget.studentGuidePdfUrl,
                    child: DisplayCardIcons(
                      icon: Icons.school,
                      count: widget.assessmentAmount,
                      tooltipText: 'Student guide',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: InkWell(
                    onTap: widget.testSheetPdfUrl,
                    child: DisplayCardIcons(
                      icon: Icons.class_,
                      count: widget.assessmentAmount,
                      tooltipText: 'Test sheet',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: InkWell(
                    onTap: widget.assessmentsPdfUrl,
                    child: DisplayCardIcons(
                      icon: Icons.format_list_numbered,
                      count: widget.assessmentAmount,
                      tooltipText: 'Assessments',
                    ),
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
