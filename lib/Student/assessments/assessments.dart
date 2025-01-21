import 'package:a4m/LandingPage/CourseListPage/ui/categoryNameStack.dart';
import 'package:a4m/Student/commonUi/customTabBar.dart';
import 'package:a4m/Student/commonUi/studentCourseItem.dart';
import 'package:a4m/Student/dummyList/allStudentCourses.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';

class AssessmentsMain extends StatefulWidget {
  const AssessmentsMain({super.key});

  @override
  State<AssessmentsMain> createState() => _AssessmentsMainState();
}

class _AssessmentsMainState extends State<AssessmentsMain> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    Center(child: AllStudentCourses()),
    Center(child: Text('Active Page', style: TextStyle(fontSize: 24))),
    Center(child: Text('Completed Page', style: TextStyle(fontSize: 24))),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CategoryNameStack(text: 'Ássessments'),
          const SizedBox(
            height: 15,
          ),
          SizedBox(
            height: 50,
            width: 500,
            child: CustomTabBar(
              selectedIndex: _selectedIndex,
              onTabSelected: (index) {
                setState(() {
                  _selectedIndex = index; // Update the selected index
                });
              },
            ),
          ),
          // Expanded widget to display the selected page
          SizedBox(
            width: MyUtility(context).width - 360,
            height: MyUtility(context).height - 205,
            child: _pages[
                _selectedIndex], // Show the page corresponding to the selected tab
          ),
        ],
      ),
    );
  }
}
