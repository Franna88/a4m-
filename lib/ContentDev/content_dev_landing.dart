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
import 'package:a4m/ContentDev/content_dev_navbar.dart';
import 'package:a4m/ContentDev/create_course.dart';
import 'package:a4m/ContentDev/choose_course_type.dart';
import 'package:a4m/ContentDev/create_module.dart';
import 'package:a4m/ContentDev/edit_course_button.dart';
import 'package:a4m/ContentDev/module_assessments.dart';
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
      EditCourseButton(),
      CreateCourse(
        changePageIndex: changePageIndex,
      ),
      CreateModule(changePageIndex: changePageIndex),
      ModuleAssessments(changePageIndex: changePageIndex),
      // CreateCourse(),
      // Add other pages here
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
