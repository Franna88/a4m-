import 'package:a4m/Admin/AdminMessaging/adminMessagesMain.dart';
import 'package:a4m/ContentDev/DevelopedCourses/DevelopedCourses.dart';
import 'package:a4m/ContentDev/ModuleAssessments/CourseModel.dart';
import 'package:a4m/ContentDev/ModuleAssessments/add_module_assignments.dart';
import 'package:a4m/ContentDev/ModuleAssessments/add_module_tasks.dart';
import 'package:a4m/ContentDev/content_dev_navbar.dart';
import 'package:a4m/ContentDev/create_course.dart';
import 'package:a4m/ContentDev/choose_course_type.dart';
import 'package:a4m/ContentDev/create_module.dart';
import 'package:a4m/ContentDev/edit_course_button.dart';
import 'package:a4m/ContentDev/ModuleAssessments/add_module_questions.dart';
import 'package:a4m/ContentDev/module_content.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ContentDevHome extends StatefulWidget {
  final String contentDevId;
  const ContentDevHome({super.key, required this.contentDevId});

  @override
  State<ContentDevHome> createState() => _ContentDevHomeState();
}

class _ContentDevHomeState extends State<ContentDevHome> {
  var pageIndex = 0;
  int selectedModuleIndex = 0;
  String? selectedCourseId;

  late List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = buildPages();
  }

  List<Widget> buildPages() {
    return [
      ChooseCourseType(
        changePageIndex: changePageIndex,
      ),
      DevelopedCourses(
        changePageWithCourseId: changePageWithCourseId,
        contentDevId: widget.contentDevId,
      ),
      CreateCourse(
        courseId: selectedCourseId, // Pass selected course ID correctly
        changePageIndex: changePageIndex,
      ),
      CreateModule(
        changePageIndex: changePageIndex,
        courseId: selectedCourseId,
        moduleIndex: selectedModuleIndex, // Ensure moduleIndex is passed
      ),
      AddModuleQuestions(
        changePageIndex: changePageIndex,
        moduleIndex: selectedModuleIndex,
      ),
      ModuleContent(
        changePageIndex: changePageIndex,
        moduleIndex: selectedModuleIndex,
      ),
      AddModuleTasks(
        changePageIndex: changePageIndex,
        moduleIndex: selectedModuleIndex,
      ),
      AddModuleAssignments(
        changePageIndex: changePageIndex,
        moduleIndex: selectedModuleIndex,
      ),
      AdminMessagesMain(),
    ];
  }

  void changePageWithCourseId(int value, String courseId) {
    setState(() {
      pageIndex = value;
      selectedCourseId = courseId;
      selectedModuleIndex = 0; // Reset module index when switching courses
      pages = buildPages(); // Ensure page list updates dynamically
    });

    print("📌 Page index changed to: $pageIndex for Course ID: $courseId");
  }

  void changePageIndex(int value, {int? moduleIndex}) {
    final courseModel = Provider.of<CourseModel>(context, listen: false);

    // ✅ ONLY clear course data when navigating to Choose Course Type (pageIndex == 0)
    if (value == 0) {
      print(
          "🆕 Navigating to Choose Course Type (Page Index: 0), clearing course data.");
      courseModel.clearCourseData(); // Clears data when starting a NEW course
      selectedCourseId = null; // Reset selected course
    }

    // ✅ Ensure modules exist before navigating to module-related pages
    if ((value == 4 || value == 5 || value == 6 || value == 7) &&
        courseModel.modules.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Please create a module first before proceeding.')),
      );
      return;
    }

    setState(() {
      pageIndex = value;
      if (moduleIndex != null) {
        selectedModuleIndex = moduleIndex;
        print('🔍 Module Index Updated: $selectedModuleIndex');
      }

      pages = buildPages(); // Ensure page list updates dynamically
    });
  }

  @override
  Widget build(BuildContext context) {
    return ContentDevNavBar(
      changePage: (index) =>
          changePageIndex(index, moduleIndex: selectedModuleIndex),
      child: pages[pageIndex],
    );
  }
}
