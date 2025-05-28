import 'package:a4m/Constants/myColors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_network/image_network.dart';

class LectureCourseContainers extends StatefulWidget {
  final String courseName;
  final String modulesComplete;
  final String courseDescription;
  final String totalStudents;
  final String moduleAmount;
  final String assessmentAmount;
  final String courseImage;
  final String courseId;
  final Function() onTap;
  final Function(int, {String courseId, String moduleId}) changePage;
  const LectureCourseContainers({
    super.key,
    required this.courseName,
    required this.modulesComplete,
    required this.courseDescription,
    required this.totalStudents,
    required this.moduleAmount,
    required this.assessmentAmount,
    required this.courseImage,
    required this.courseId,
    required this.onTap,
    required this.changePage,
  });

  @override
  State<LectureCourseContainers> createState() =>
      _LectureCourseContainersState();
}

class _LectureCourseContainersState extends State<LectureCourseContainers> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            widget.changePage(6, courseId: widget.courseId, moduleId: '');
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: isHovered ? 2 : 1,
                  blurRadius: isHovered ? 15 : 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course Image
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    color: Colors.grey[200],
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: ImageNetwork(
                          image: widget.courseImage,
                          height: 160,
                          width: 400,
                          duration: 100,
                          fitAndroidIos: BoxFit.cover,
                          fitWeb: BoxFitWeb.cover,
                          onLoading: Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          onError: Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                      // This InkWell is on top of the image and will always catch taps
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            onTap: () {
                              widget.changePage(6,
                                  courseId: widget.courseId, moduleId: '');
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Course Name
                      Text(
                        widget.courseName,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Course Description
                      SizedBox(
                        height: 50,
                        child: Text(
                          'Courseware',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),

                      // Stats in two rows
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // First row with two stats
                          Row(
                            children: [
                              _buildActionButton(
                                icon: Icons.person_outline,
                                label: '${widget.totalStudents} Students',
                              ),
                              const SizedBox(width: 8),
                              _buildActionButton(
                                icon: Icons.assignment_outlined,
                                label: '${widget.assessmentAmount} Assessments',
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Second row with one stat
                          _buildActionButton(
                            icon: Icons.library_books_outlined,
                            label: '${widget.moduleAmount} Modules',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Mycolors().green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Mycolors().green,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Mycolors().green,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
