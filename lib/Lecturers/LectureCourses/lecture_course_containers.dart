import 'package:a4m/Admin/ApproveContent/approveContent.dart';
import 'package:a4m/CommonComponents/displayCardIcons.dart';
import 'package:a4m/Constants/myColors.dart';
import 'package:a4m/Lecturers/LectureCourses/view_modules_complete.dart';
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
    required this.onTap,
    required this.changePage,
  });

  @override
  State<LectureCourseContainers> createState() =>
      _LectureCourseContainersState();
}

class _LectureCourseContainersState extends State<LectureCourseContainers> {
  var pageIndex = 0;
  bool isHovered = false;

  void changePage(int index) {
    setState(() {
      pageIndex = index;
    });
    changePage(5);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(isHovered ? 0.2 : 0.1),
              spreadRadius: isHovered ? 2 : 1,
              blurRadius: isHovered ? 15 : 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => widget.changePage(5, courseId: '', moduleId: ''),
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: ImageNetwork(
                          image: widget.courseImage,
                          fitWeb: BoxFitWeb.cover,
                          fitAndroidIos: BoxFit.cover,
                          height: 180,
                          width: 320,
                          duration: 100,
                          onLoading: Container(
                            color: Colors.grey[200],
                            height: 180,
                            width: 320,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          onError: Container(
                            color: Colors.grey[200],
                            height: 180,
                            width: 320,
                            child: const Icon(Icons.error, color: Colors.red),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.8),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Mycolors().green.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${widget.modulesComplete} Modules',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.courseName,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.courseDescription,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(Icons.person_outline,
                              widget.totalStudents, 'Students'),
                          _buildStatItem(Icons.assignment_outlined,
                              widget.assessmentAmount, 'Assessments'),
                          _buildStatItem(Icons.library_books_outlined,
                              widget.moduleAmount, 'Modules'),
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

  Widget _buildStatItem(IconData icon, String count, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Mycolors().green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Mycolors().green,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          count,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
