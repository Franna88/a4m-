import 'package:a4m/CommonComponents/displayCardIcons.dart';
import 'package:a4m/Constants/myColors.dart';
import 'package:a4m/Lecturers/commonUi/lecturerPdfViewer.dart';
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
  final String moduleId;
  final String courseId;
  final Function(String moduleId, String courseName) onAssessmentMarkingTap;

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
    required this.moduleId,
    required this.courseId,
    required this.onAssessmentMarkingTap,
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
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                      child: ImageNetwork(
                        image: widget.courseImage,
                        height: 180,
                        width: 320,
                        fitWeb: BoxFitWeb.cover,
                        onLoading: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 10,
                      right: 10,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.courseName,
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
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
                  ],
                ),
              ),
              // Course Description
              Padding(
                padding: const EdgeInsets.all(8.0),
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
              // Action Buttons
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      icon: Icons.assignment,
                      label: 'Activities',
                      onTap: widget.onActivitiesTap,
                    ),
                    _buildActionButton(
                      icon: Icons.assessment,
                      label: 'Assessments',
                      onTap: widget.onAssessmentsTap,
                    ),
                    _buildActionButton(
                      icon: Icons.quiz,
                      label: 'Test Sheet',
                      onTap: widget.onTestSheetTap,
                    ),
                    _buildActionButton(
                      icon: Icons.check_circle,
                      label: 'Answer Sheet',
                      onTap: widget.onAnswerSheetTap,
                    ),
                    _buildActionButton(
                      icon: Icons.grade,
                      label: 'Mark',
                      onTap: () => widget.onAssessmentMarkingTap(
                          widget.moduleId, widget.courseName),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Mycolors().darkTeal.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Mycolors().darkTeal,
              size: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 10,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
