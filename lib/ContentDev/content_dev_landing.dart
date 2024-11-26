import 'package:a4m/Admin/AdminA4mMembers/a4mMemebersList.dart';
import 'package:a4m/Admin/AdminCertification/adminCertification.dart';
import 'package:a4m/Admin/AdminCourses/adminCourseList.dart';
import 'package:a4m/Admin/AdminMarketing/AdminMarketing.dart';
import 'package:a4m/Admin/AdminMessaging/adminMessagesMain.dart';

import 'package:a4m/Admin/ApproveContent/approveContent.dart';
import 'package:a4m/Admin/Commonui/adminMainNavBar.dart';
import 'package:a4m/Admin/ComplaintsSuggestions/compSuggestionsMain.dart';
import 'package:a4m/Admin/CurriculumVitae/cirriculumVitae.dart';
import 'package:a4m/Admin/Dashboard/adminDashboardMain.dart';
import 'package:a4m/ContentDev/EditContentDev/edit_module.dart';
import 'package:a4m/ContentDev/ModuleAssessments/add_module_assignments.dart';
import 'package:a4m/ContentDev/ModuleAssessments/add_module_tasks.dart';
import 'package:a4m/ContentDev/CreateContentDev/content_dev_navbar.dart';
import 'package:a4m/ContentDev/CreateContentDev/create_course.dart';
import 'package:a4m/ContentDev/CreateContentDev/choose_course_type.dart';
import 'package:a4m/ContentDev/CreateContentDev/create_module.dart';
import 'package:a4m/ContentDev/EditContentDev/edit_content_dev.dart';
import 'package:a4m/ContentDev/ModuleAssessments/add_module_questions.dart';
import 'package:a4m/ContentDev/CreateContentDev/module_content.dart';
import 'package:a4m/ContentDev/ContentDevMessages/content_dev_messages.dart';
import 'package:flutter/material.dart';

class ContentDevHome extends StatefulWidget {
  const ContentDevHome({super.key});

  @override
  State<ContentDevHome> createState() => _ContentDevHomeState();
}

class _ContentDevHomeState extends State<ContentDevHome> {
  var pageIndex = 0;

  late List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      ChooseCourseType(
        changePageIndex: changePageIndex,
      ),
      EditContentDev(changePageIndex: changePageIndex),
      CreateCourse(
        changePageIndex: changePageIndex,
      ),
      CreateModule(changePageIndex: changePageIndex),
      AddModuleQuestions(changePageIndex: changePageIndex),
      ModuleContent(changePageIndex: changePageIndex),
      AddModuleTasks(changePageIndex: changePageIndex),
      AddModuleAssignments(changePageIndex: changePageIndex),
      EditModule(changePageIndex: changePageIndex),
      const ContentDevMessages(),
    ];
  }

  void changePageIndex(int value) {
    setState(() {
      pageIndex = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ContentDevNavBar(
      changePage: changePageIndex,
      child: pages[pageIndex],
    );
  }
}
