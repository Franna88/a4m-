import 'package:a4m/Admin/Dashboard/ui/coursePerformancePieChart.dart';
import 'package:a4m/Admin/Dashboard/ui/monthlySalesChart.dart';
import 'package:a4m/Admin/Dashboard/ui/monthlyStatSumContainers.dart';
import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:a4m/Themes/text_style.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';

class ChooseCourseType extends StatefulWidget {
  Function(int) changePageIndex;

  ChooseCourseType({
    super.key,
    required this.changePageIndex,
  });

  @override
  State<ChooseCourseType> createState() => _AdminDashboardMainState();
}

class _AdminDashboardMainState extends State<ChooseCourseType> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Mycolors().offWhite,
      child: SizedBox(
        width: MyUtility(context).width - 280,
        height: MyUtility(context).height - 80,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Mycolors().blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  height: MyUtility(context).height * 0.06,
                  width: MyUtility(context).width,
                  child: Center(
                    child: Text(
                      'Please Choose an Option',
                      style: MyTextStyles(context).headerWhite,
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      widget.changePageIndex(2);
                      print("Create New Course Content tapped");
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: MyUtility(context).width * 0.35,
                      height: MyUtility(context).height * 0.7,
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: MyUtility(context).height * 0.04,
                            ),
                            Text(
                              'Create New Course Content',
                              style: MyTextStyles(context).subHeaderBlack,
                            ),
                            Spacer(),
                            Image.asset(
                              'images/create_course_content.png',
                              width: MyUtility(context).width * 0.5,
                              height: MyUtility(context).height * 0.6,
                              fit: BoxFit.fill,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      // Add your function here
                      print("Upload Course Content tapped");
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: MyUtility(context).width * 0.35,
                      height: MyUtility(context).height * 0.7,
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: MyUtility(context).height * 0.04,
                            ),
                            Text(
                              'Upload Course Content',
                              style: MyTextStyles(context).subHeaderBlack,
                            ),
                            Spacer(),
                            Image.asset(
                              'images/upload_course_content.png',
                              width: MyUtility(context).width * 0.5,
                              height: MyUtility(context).height * 0.6,
                              fit: BoxFit.fill,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
