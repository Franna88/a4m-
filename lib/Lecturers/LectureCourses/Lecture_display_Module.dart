import 'package:a4m/CommonComponents/displayCardIcons.dart';
import 'package:a4m/Constants/myColors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_network/image_network.dart';

class LectureDisplayModule extends StatefulWidget {
  final String courseName;
  final String modulesComplete;
  final String courseDescription;
  final String totalStudents;
  final String moduleAmount;
  final String assessmentAmount;
  final String courseImage;
  final VoidCallback onTap;

  final Function(int) changePage;
  final VoidCallback onActivitiesTap;
  final VoidCallback onAssessmentsTap;
  final VoidCallback onTestSheetTap;
  final VoidCallback onAnswerSheetTap;

  const LectureDisplayModule({
    super.key,
    required this.courseName,
    required this.modulesComplete,
    required this.courseDescription,
    required this.totalStudents,
    required this.moduleAmount,
    required this.assessmentAmount,
    required this.courseImage,
    required this.onTap,
    required this.changePage,
    required this.onActivitiesTap,
    required this.onAssessmentsTap,
    required this.onTestSheetTap,
    required this.onAnswerSheetTap,
  });

  @override
  State<LectureDisplayModule> createState() => _LectureDisplayModuleState();
}

class _LectureDisplayModuleState extends State<LectureDisplayModule> {
  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(15),
      elevation: 5,
      child: InkWell(
        onTap: widget.onTap,
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
              // Image with overlay
              Container(
                width: 320,
                height: 180,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
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
                      Positioned.fill(
                        child: ImageNetwork(
                          image: widget.courseImage,
                          fitWeb: BoxFitWeb.cover,
                          fitAndroidIos: BoxFit.cover,
                          onLoading: const Center(
                            child: CircularProgressIndicator(),
                          ),
                          width: 320,
                          height: 180,
                        ),
                      ),
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
                                onTap: () {},
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
              // Course Title
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
              // Course Description
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 5, bottom: 5),
                child: Text(
                  widget.courseDescription,
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
              // Divider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  width: 300,
                  height: 2,
                  color: const Color.fromARGB(255, 189, 189, 189),
                ),
              ),
              // Footer Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildFooterButton(
                    icon: Icons.directions_run_outlined,
                    tooltip: 'Activities',
                    onTap: widget.onActivitiesTap,
                  ),
                  _buildFooterButton(
                    icon: Icons.assignment_outlined,
                    tooltip: 'Assessments',
                    onTap: widget.onAssessmentsTap,
                  ),
                  _buildFooterButton(
                    icon: Icons.format_list_numbered,
                    tooltip: 'Test Sheet',
                    onTap: widget.onTestSheetTap,
                  ),
                  _buildFooterButton(
                    icon: Icons.library_books_outlined,
                    tooltip: 'Answer Sheet',
                    onTap: widget.onAnswerSheetTap,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Footer Button
  Widget _buildFooterButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Mycolors().darkTeal, size: 24),
          const SizedBox(height: 4),
          Text(
            tooltip,
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
