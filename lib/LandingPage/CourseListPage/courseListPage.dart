import 'package:a4m/CommonComponents/A4mFooter.dart';
import 'package:a4m/CommonComponents/inputFields/myDropDownMenu.dart';
import 'package:a4m/CommonComponents/inputFields/mySearchBar.dart';
import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:a4m/LandingPage/CourseListPage/ui/categoryNameStack.dart';
import 'package:a4m/LandingPage/CourseListPage/ui/courseContainers.dart';
import 'package:a4m/LandingPage/landingPageMain.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../Login/loginPopup.dart';
import '../A4mAppBar/a4mAppBar.dart';

class CourseListPage extends StatefulWidget {
  const CourseListPage({super.key});

  @override
  State<CourseListPage> createState() => _CourseListPageState();
}

class _CourseListPageState extends State<CourseListPage> {
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>>? courses;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    setState(() {
      isLoading = true;
    });
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('courses')
          .where('status', isEqualTo: 'approved')
          .get();
      List<Map<String, dynamic>> courseList = [];
      for (var doc in snapshot.docs) {
        final courseData = doc.data() as Map<String, dynamic>;
        // Only include courses with assigned lecturers
        if (courseData['assignedLecturers'] != null &&
            (courseData['assignedLecturers'] as List).isNotEmpty) {
          // Fetch modules for the course
          QuerySnapshot moduleSnapshot = await FirebaseFirestore.instance
              .collection('courses')
              .doc(doc.id)
              .collection('modules')
              .get();
          int moduleCount = moduleSnapshot.docs.length;
          int assessmentCount = 0;
          for (var module in moduleSnapshot.docs) {
            final moduleData = module.data() as Map<String, dynamic>;
            if (moduleData['assessmentsPdfUrl'] != null &&
                moduleData['assessmentsPdfUrl'].isNotEmpty) {
              assessmentCount++;
            }
          }
          courseList.add({
            ...courseData,
            'moduleCount': moduleCount,
            'assessmentCount': assessmentCount,
          });
        }
      }
      setState(() {
        courses = courseList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        courses = [];
        isLoading = false;
      });
    }
  }

  Future openLoginTabs() => showDialog(
      context: context,
      builder: (context) {
        return const Dialog(
          alignment: Alignment.centerRight,
          insetPadding: EdgeInsets.all(0),
          child: LoginPopup(),
        );
      });

  @override
  Widget build(BuildContext context) {
    final category = TextEditingController();
    final courseSearch = TextEditingController();

    return Scaffold(
      backgroundColor: Mycolors().offWhite,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  SizedBox(
                    width: MyUtility(context).width * 0.85,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 100,
                        ),
                        CategoryNameStack(text: 'Category Name Here'),
                        const SizedBox(
                          height: 30,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            MyDropDownMenu(
                                description: 'Category',
                                customSize: 300,
                                items: ['test1', 'test2'],
                                textfieldController: category),
                            const SizedBox(
                              width: 40,
                            ),
                            SizedBox(
                              width: 350,
                              child: MySearchBar(
                                  textController: courseSearch,
                                  hintText: 'Search Course'),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        isLoading
                            ? Center(
                                child: CircularProgressIndicator(
                                  color: Mycolors().green,
                                ),
                              )
                            : CourseContainers(courses: courses),
                        const SizedBox(
                          height: 30,
                        ),
                      ],
                    ),
                  ),
                  A4mFooter()
                ],
              ),
            ),
          ),
          A4mAppBar(
            opacity: 1,
            onTapHome: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const LandingPageMain()),
              );
            },
            onTapCourses: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CourseListPage()),
              );
            },
            onTapContact: () {},
            onTapLogin: openLoginTabs,
          ),
        ],
      ),
    );
  }
}
