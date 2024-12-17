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
  const ContentDevHome({super.key});

  @override
  State<ContentDevHome> createState() => _ContentDevHomeState();
}

class _ContentDevHomeState extends State<ContentDevHome> {
  var pageIndex = 0;
  int selectedModuleIndex = 0;

  late List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      ChooseCourseType(
        changePageIndex: changePageIndex,
      ),
      EditCourseButton(),
      CreateCourse(
        changePageIndex: changePageIndex,
      ),
      CreateModule(
        changePageIndex: changePageIndex,
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
    ];
  }

  void changePageIndex(int value, {int? moduleIndex}) {
    final courseModel = Provider.of<CourseModel>(context, listen: false);

    // Ensure module-specific pages only get accessed if there are modules available
    if ((value == 4 || value == 5 || value == 6 || value == 7) &&
        courseModel.modules.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please create a module first before proceeding.'),
        ),
      );
      return;
    }

    setState(() {
      pageIndex = value;
      if (moduleIndex != null) {
        selectedModuleIndex = moduleIndex;
      }
    });

    // Update the page list with the new selectedModuleIndex to make sure all pages have the correct value.
    pages = [
      ChooseCourseType(
        changePageIndex: changePageIndex,
      ),
      EditCourseButton(),
      CreateCourse(
        changePageIndex: changePageIndex,
      ),
      CreateModule(
        changePageIndex: changePageIndex,
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
    ];
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
