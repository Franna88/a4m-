import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../Themes/Constants/myColors.dart';
import 'CompSuggestionsItems/courseReviews/ui/courseReviewTable.dart';
import 'CompSuggestionsItems/courseEvaluations/ui/courseEvaluationTable.dart';

class CompSuggestionsMain extends StatefulWidget {
  const CompSuggestionsMain({super.key});

  @override
  State<CompSuggestionsMain> createState() => _CompSuggestionsMainState();
}

class _CompSuggestionsMainState extends State<CompSuggestionsMain> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Feedback Management',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Mycolors().navyBlue,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildTab('Course Reviews', 0),
              const SizedBox(width: 16),
              _buildTab('Course Evaluations', 1),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _selectedIndex == 0
                ? const CourseReviewTable()
                : const CourseEvaluationTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Mycolors().darkTeal : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Mycolors().darkTeal : Colors.grey[300]!,
          ),
        ),
        child: Text(
          title,
          style: GoogleFonts.poppins(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
