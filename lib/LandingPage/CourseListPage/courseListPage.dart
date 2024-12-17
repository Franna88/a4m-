import 'package:a4m/CommonComponents/A4mFooter.dart';
import 'package:a4m/CommonComponents/inputFields/myDropDownMenu.dart';
import 'package:a4m/CommonComponents/inputFields/mySearchBar.dart';
import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:a4m/LandingPage/CourseListPage/ui/categoryNameStack.dart';
import 'package:a4m/LandingPage/CourseListPage/ui/courseContainers.dart';
import 'package:a4m/LandingPage/landingPageMain.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';

import '../../Login/loginPopup.dart';
import '../A4mAppBar/a4mAppBar.dart';

class CourseListPage extends StatefulWidget {
  const CourseListPage({super.key});

  @override
  State<CourseListPage> createState() => _CourseListPageState();
}

class _CourseListPageState extends State<CourseListPage> {
  final ScrollController _scrollController = ScrollController();
  // double _appBarOpacity = 0.0;

  // @override
  // void initState() {
  //   super.initState();
  //   _scrollController.addListener(_scrollListener);
  // }

  // @override
  // void dispose() {
  //   _scrollController.removeListener(_scrollListener);
  //   _scrollController.dispose();
  //   super.dispose();
  // }

  // void _scrollListener() {
  //   double offset = _scrollController.offset;
  //   setState(() {
  //     // Adjust opacity between 0 and 1 based on the offset
  //     _appBarOpacity = (offset / 200).clamp(0, 1);
  //   });
  // }

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
                        CourseContainers(),
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
