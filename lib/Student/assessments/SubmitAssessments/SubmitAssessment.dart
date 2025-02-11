import 'package:a4m/Constants/myColors.dart';
import 'package:a4m/Student/assessments/SubmitAssessments/SubmitContainerList.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SubmitAssessment extends StatefulWidget {
  final String courseId;
  final String moduleId;
  final String studentId;

  const SubmitAssessment(
      {super.key,
      required this.courseId,
      required this.moduleId,
      required this.studentId});

  @override
  State<SubmitAssessment> createState() => _SubmitAssessmentState();
}

class _SubmitAssessmentState extends State<SubmitAssessment> {
  @override
  void initState() {
    super.initState();
    print(
        "SubmitAssessment Initialized with Course ID: ${widget.courseId}, Module ID: ${widget.moduleId}, Student ID: ${widget.studentId}");
  }

  Widget build(BuildContext context) {
    final oldNew = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        width: MyUtility(context).width - 320,
        height: MyUtility(context).height - 80,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.black,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Material(
          color: Colors.white,
          child: DefaultTabController(
            length: 1, // Only one tab
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dropdown Menu
                  Container(
                    width: 400,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Mycolors().darkGrey,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          'ModuleName',
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Single TabBarView
                  Expanded(
                    child: TabBarView(
                      children: [
                        SubmitContainerList(
                          courseId: widget.courseId,
                          moduleId: widget.moduleId,
                          studentId: widget.studentId, // Pass the module ID
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
