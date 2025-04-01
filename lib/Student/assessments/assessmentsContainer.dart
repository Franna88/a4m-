import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_network/image_network.dart';
import '../../Themes/Constants/myColors.dart';

class AssessmentsContainer extends StatelessWidget {
  final String courseName;
  final String courseImage;
  final String courseDescription;
  final String moduleCount;
  final String assessmentCount;
  final String? completedAssessments;
  final bool? isCompleted;
  final VoidCallback onTap;

  const AssessmentsContainer({
    super.key,
    required this.courseName,
    required this.courseImage,
    required this.courseDescription,
    required this.moduleCount,
    required this.assessmentCount,
    this.completedAssessments,
    this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 800;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: isSmallScreen
                ? _buildMobileLayout(context)
                : _buildDesktopLayout(context),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCourseImage(),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCourseHeader(),
              const SizedBox(height: 12),
              _buildCourseDescription(),
              const SizedBox(height: 24),
              _buildCourseStats(),
              const SizedBox(height: 24),
              _buildContinueButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCourseImage(),
        const SizedBox(height: 16),
        _buildCourseHeader(),
        const SizedBox(height: 12),
        _buildCourseDescription(),
        const SizedBox(height: 16),
        _buildCourseStats(),
        const SizedBox(height: 16),
        _buildContinueButton(),
      ],
    );
  }

  Widget _buildCourseImage() {
    return Stack(
      children: [
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ImageNetwork(
              image: courseImage,
              height: 160,
              width: 160,
              fitAndroidIos: BoxFit.cover,
              fitWeb: BoxFitWeb.cover,
              onLoading: Container(
                color: Colors.grey[200],
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Mycolors().green),
                  ),
                ),
              ),
              onError: Container(
                color: Colors.grey[200],
                child: Icon(Icons.error, color: Colors.red),
              ),
            ),
          ),
        ),
        if (isCompleted != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: FractionallySizedBox(
                widthFactor: isCompleted! ? 1.0 : 0.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Mycolors().green,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCourseHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            courseName,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isCompleted != null)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: isCompleted!
                  ? Mycolors().green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isCompleted! ? 'Completed' : 'In Progress',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isCompleted! ? Mycolors().green : Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCourseDescription() {
    return Text(
      courseDescription,
      style: GoogleFonts.poppins(
        fontSize: 14,
        color: Colors.grey[600],
        height: 1.5,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildCourseStats() {
    return Wrap(
      spacing: 24,
      runSpacing: 12,
      children: [
        _buildStatItem(
          Icons.library_books_outlined,
          '$moduleCount Modules',
          Colors.blue,
        ),
        _buildStatItem(
          Icons.assignment_outlined,
          completedAssessments != null
              ? '$completedAssessments/$assessmentCount Assessments'
              : '$assessmentCount Assessments',
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Mycolors().green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Continue',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
