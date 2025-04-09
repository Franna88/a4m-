import 'package:a4m/Constants/myColors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_network/image_network.dart';

class FacilitatorModuleContainer extends StatefulWidget {
  final String moduleName;
  final String moduleDescription;
  final String assessmentAmount;
  final String moduleImage;
  final VoidCallback facilitatorGuidePdfUrl;
  final VoidCallback testSheetPdfUrl;
  final VoidCallback assessmentsPdfUrl;
  final VoidCallback answerSheetPdfUrl;
  final VoidCallback assignmentsPdfUrl;
  final bool isCompleted;

  const FacilitatorModuleContainer({
    super.key,
    required this.assessmentAmount,
    required this.moduleName,
    required this.moduleDescription,
    required this.moduleImage,
    required this.facilitatorGuidePdfUrl,
    required this.testSheetPdfUrl,
    required this.assessmentsPdfUrl,
    required this.answerSheetPdfUrl,
    required this.assignmentsPdfUrl,
    this.isCompleted = false,
  });

  @override
  State<FacilitatorModuleContainer> createState() =>
      _FacilitatorModuleContainerState();
}

class _FacilitatorModuleContainerState
    extends State<FacilitatorModuleContainer> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
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
                _buildAssessmentCount(),
                const SizedBox(height: 16),
                _buildActionButtonsGrid(),
              ],
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

  Widget _buildActionButtonsGrid() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.description_outlined,
                label: 'Guide',
                onTap: widget.facilitatorGuidePdfUrl,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildActionButton(
                icon: Icons.assignment_outlined,
                label: 'Assessments',
                onTap: widget.assessmentsPdfUrl,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildActionButton(
                icon: Icons.assignment_outlined,
                label: 'Assignments',
                onTap: widget.assignmentsPdfUrl,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.quiz_outlined,
                label: 'Test',
                onTap: widget.testSheetPdfUrl,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildActionButton(
                icon: Icons.assignment_turned_in_outlined,
                label: 'Answer Sheet',
                onTap: widget.answerSheetPdfUrl,
              ),
            ),
            const SizedBox(width: 8),
            const Spacer(),
          ],
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Mycolors().green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: Mycolors().green,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Mycolors().green,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
