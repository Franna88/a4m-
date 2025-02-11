import 'package:a4m/LandingPage/CourseListPage/ui/categoryNameStack.dart';
import 'package:a4m/Student/assessments/AssessmentTabBar.dart';
import 'package:a4m/Student/assessments/SubmitModuleAssessments/ModuleAssessmentsList.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';

class SubmitModuleAssessments extends StatefulWidget {
  final void Function(int newPage, String courseId, String moduleId)
      changePageWithCourseId;
  final String selectedCourseId;
  final String studentID;

  const SubmitModuleAssessments(
      {Key? key,
      required this.changePageWithCourseId,
      required this.selectedCourseId,
      required this.studentID})
      : super(key: key);

  @override
  State<SubmitModuleAssessments> createState() =>
      _SubmitModuleAssessmentsState();
}

class _SubmitModuleAssessmentsState extends State<SubmitModuleAssessments> {
  int _selectedIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      Center(
        child: ModuleAssessmentList(
          courseId: widget.selectedCourseId,
          onTap: (moduleId) {
            widget.changePageWithCourseId(5, widget.selectedCourseId, moduleId);
          },
          studentId: widget.studentID,
        ),
      ),
      Center(child: Text('Active Page', style: TextStyle(fontSize: 24))),
      Center(child: Text('Completed Page', style: TextStyle(fontSize: 24))),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CategoryNameStack(text: 'Submit Assessments'),
          const SizedBox(height: 15),
          SizedBox(
            height: 50,
            width: 500,
            child: AssessmentTabBar(
              selectedIndex: _selectedIndex,
              onTabSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
          SizedBox(
            width: MyUtility(context).width - 360,
            height: MyUtility(context).height - 205,
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }
}
