import 'package:a4m/Admin/Dashboard/ui/coursePerformancePieChart.dart';
import 'package:a4m/Admin/Dashboard/ui/monthlySalesChart.dart';
import 'package:a4m/Admin/Dashboard/ui/monthlyStatSumContainers.dart';
import 'package:a4m/ContentDev/create_course_textfields.dart';
import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:a4m/Themes/text_style.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';

class CreateCourse extends StatefulWidget {
  CreateCourse({super.key});

  @override
  State<CreateCourse> createState() => _CreateCourseState();
}

class _CreateCourseState extends State<CreateCourse> {
  late TextEditingController _courseNameController;
  late TextEditingController _coursePriceController;
  late TextEditingController _courseCategoryController;
  late TextEditingController _courseDescriptionController;

  @override
  void initState() {
    super.initState();
    _courseNameController = TextEditingController();
    _coursePriceController = TextEditingController();
    _courseCategoryController = TextEditingController();
    _courseDescriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _courseNameController.dispose();
    _coursePriceController.dispose();
    _courseCategoryController.dispose();
    _courseDescriptionController.dispose();
    super.dispose();
  }

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
                      'Create Course',
                      style: MyTextStyles(context).headerWhite,
                    ),
                  ),
                ),
              ),
              Container(
                  color: Colors.white,
                  width: MyUtility(context).width,
                  height: MyUtility(context).height * 0.78,
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              height: MyUtility(context).height * 0.38,
                              width: MyUtility(context).width * 0.3,
                              decoration: BoxDecoration(
                                color: Mycolors().offWhite,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.image,
                                  size: 50,
                                  color: Mycolors().darkGrey,
                                ),
                              ),
                            ),
                            Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                CreateCourseTextfields(
                                  title: 'Course Name',
                                  controller: _courseNameController,
                                ),
                                CreateCourseTextfields(
                                  title: 'Course Price',
                                  controller: _coursePriceController,
                                ),
                                CreateCourseTextfields(
                                  title: 'Course Category',
                                  controller: _courseCategoryController,
                                ),
                              ],
                            )
                          ],
                        ),
                        Center(
                          child: CreateCourseTextfields(
                            title: 'Course Description',
                            widthFactor: 0.9,
                            heightFactor: 0.7,
                            controller: _courseDescriptionController,
                          ),
                        ),
                      ],
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
