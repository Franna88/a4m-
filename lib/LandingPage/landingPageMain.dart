import 'package:a4m/CommonComponents/A4mFooter.dart';
import 'package:a4m/LandingPage/A4mAppBar/a4mAppBar.dart';
import 'package:a4m/LandingPage/LandingA4mTeam/landingA4mTeam.dart';
import 'package:a4m/LandingPage/LandingPageCategoryList/LandingPageCategoryList.dart';
import 'package:a4m/LandingPage/heroSection/heroSection.dart';
import 'package:a4m/LandingPage/landingPageStats/landingPageStats.dart';
import 'package:a4m/Login/loginPopup.dart';
import 'package:flutter/material.dart';

import 'CourseListPage/courseListPage.dart';

class LandingPageMain extends StatefulWidget {
  const LandingPageMain({super.key});

  @override
  State<LandingPageMain> createState() => _LandingPageMainState();
}

class _LandingPageMainState extends State<LandingPageMain> {
  final ScrollController _scrollController = ScrollController();
  double _appBarOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    double offset = _scrollController.offset;
    setState(() {
      // Adjust opacity between 0 and 1 based on the offset
      _appBarOpacity = (offset / 200).clamp(0, 1);
    });
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
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                HeroSection(
                  onTap: openLoginTabs,
                ),
                const LandingPageStats(),
                const LandingPageCategoryList(),
                const LandingA4mTeam(),
                const A4mFooter(),
              ],
            ),
          ),
          A4mAppBar(
            opacity: _appBarOpacity,
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
