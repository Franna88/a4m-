import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_network/image_network.dart';
import '../../Themes/Constants/myColors.dart';

class LecturerCourseContainer extends StatefulWidget {
  final String courseName;
  final String courseImage;
  final String courseDescription;
  final String moduleCount;
  final String assessmentCount;
  final String studentCount;
  final String pendingAssessments;
  final VoidCallback onTap;
  final VoidCallback onMarkAssessments;
  final VoidCallback onViewAnalytics;

  const LecturerCourseContainer({
    super.key,
    required this.courseName,
    required this.courseImage,
    required this.courseDescription,
    required this.moduleCount,
    required this.assessmentCount,
    required this.studentCount,
    required this.pendingAssessments,
    required this.onTap,
    required this.onMarkAssessments,
    required this.onViewAnalytics,
  });

  @override
  State<LecturerCourseContainer> createState() =>
      _LecturerCourseContainerState();
}

class _LecturerCourseContainerState extends State<LecturerCourseContainer> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
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
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCourseImage(),
                  const SizedBox(height: 16),
                  _buildCourseHeader(),
                  const SizedBox(height: 8),
                  _buildCourseDescription(),
                  const SizedBox(height: 16),
                  if (isSmallScreen)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStats(),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: _buildActionButtons(),
                        ),
                      ],
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStats(),
                        Flexible(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: _buildActionButtons(),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseImage() {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[200],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
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
    );
  }

  Widget _buildCourseHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            widget.courseName,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${widget.moduleCount} Modules',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.orange[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCourseDescription() {
    return Text(
      widget.courseDescription,
      style: GoogleFonts.poppins(
        fontSize: 14,
        color: Colors.grey[600],
        height: 1.5,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(
          Icons.people_outline,
          widget.studentCount,
          'Students',
          Colors.blue,
        ),
        _buildStatItem(
          Icons.assignment_outlined,
          widget.assessmentCount,
          'Assessments',
          Colors.orange,
        ),
        _buildStatItem(
          Icons.pending_actions_outlined,
          widget.pendingAssessments,
          'Pending',
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildStatItem(
      IconData icon, String count, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            '$count $label',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildActionButton(
          icon: Icons.assessment_outlined,
          label: 'Mark',
          onTap: widget.onMarkAssessments,
        ),
        _buildActionButton(
          icon: Icons.analytics_outlined,
          label: 'Analytics',
          onTap: widget.onViewAnalytics,
        ),
        _buildActionButton(
          icon: Icons.visibility_outlined,
          label: 'View',
          onTap: widget.onTap,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
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
        ),
      ),
    );
  }
}
