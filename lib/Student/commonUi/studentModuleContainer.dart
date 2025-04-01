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
  final bool isCompleted;

  const StudentModuleContainer({
    super.key,
    required this.assessmentAmount,
    required this.moduleName,
    required this.moduleDescription,
    required this.moduleImage,
    required this.studentGuidePdfUrl,
    required this.testSheetPdfUrl,
    required this.assessmentsPdfUrl,
    this.isCompleted = false,
  });

  @override
  State<StudentModuleContainer> createState() => _StudentModuleContainerState();
}

class _StudentModuleContainerState extends State<StudentModuleContainer> {
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
            onTap: widget.studentGuidePdfUrl,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildModuleImage(),
                  const SizedBox(height: 16),
                  _buildModuleHeader(),
                  const SizedBox(height: 8),
                  _buildModuleDescription(),
                  const SizedBox(height: 16),
                  if (isSmallScreen)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAssessmentCount(),
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
                        _buildAssessmentCount(),
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

  Widget _buildModuleImage() {
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
          image: widget.moduleImage,
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

  Widget _buildModuleHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            widget.moduleName,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (!widget.isCompleted)
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
              'In Progress',
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

  Widget _buildModuleDescription() {
    return Text(
      widget.moduleDescription,
      style: GoogleFonts.poppins(
        fontSize: 14,
        color: Colors.grey[600],
        height: 1.5,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildAssessmentCount() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 16,
            color: Colors.orange[700],
          ),
          const SizedBox(width: 6),
          Text(
            '${widget.assessmentAmount} Assessments',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.orange[700],
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
          icon: Icons.description_outlined,
          label: 'Guide',
          onTap: widget.studentGuidePdfUrl,
        ),
        _buildActionButton(
          icon: Icons.quiz_outlined,
          label: 'Test',
          onTap: widget.testSheetPdfUrl,
        ),
        _buildActionButton(
          icon: Icons.assignment_turned_in_outlined,
          label: 'Submit',
          onTap: widget.assessmentsPdfUrl,
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
