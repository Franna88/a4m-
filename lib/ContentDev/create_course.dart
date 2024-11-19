import 'package:a4m/Admin/Dashboard/ui/coursePerformancePieChart.dart';
import 'package:a4m/Admin/Dashboard/ui/monthlySalesChart.dart';
import 'package:a4m/Admin/Dashboard/ui/monthlyStatSumContainers.dart';
import 'package:a4m/CommonComponents/buttons/slimButtons.dart';
import 'package:a4m/CommonComponents/inputFields/myTextFields.dart';

import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:a4m/Themes/text_style.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';

class CreateCourse extends StatefulWidget {
  Function(int) changePageIndex;
  CreateCourse({
    super.key,
    required this.changePageIndex,
  });

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
          child: SingleChildScrollView(
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
                    height: MyUtility(context).height * 0.9,
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                              SizedBox(
                                height: MyUtility(context).height * 0.38,
                                width: MyUtility(context).width * 0.3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                      width: MyUtility(context).width * 0.3,
                                      child: MyTextFields(
                                        headerText: 'Course Name',
                                        inputController: _courseNameController,
                                        keyboardType: '',
                                      ),
                                    ),
                                    SizedBox(
                                      width: MyUtility(context).width * 0.3,
                                      child: MyTextFields(
                                        headerText: 'Course Price',
                                        inputController: _coursePriceController,
                                        keyboardType: 'intType',
                                      ),
                                    ),
                                    SizedBox(
                                      width: MyUtility(context).width * 0.3,
                                      child: MyTextFields(
                                        headerText: 'Course Category',
                                        inputController:
                                            _courseCategoryController,
                                        keyboardType: '',
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Center(
                              child: SizedBox(
                                width: MyUtility(context).width * 0.8,
                                child: MyTextFields(
                                  headerText: 'Course Description',
                                  inputController: _courseDescriptionController,
                                  keyboardType: '',
                                  maxLines: 7,
                                ),
                              ),
                            ),
                          ),
                          Spacer(),
                          SlimButtons(
                            buttonText: 'Next',
                            buttonColor: Colors.white,
                            borderColor: Color.fromRGBO(203, 210, 224, 1),
                            textColor: Mycolors().green,
                            onPressed: () {
                              widget.changePageIndex(3);
                            },
                            customWidth: 85,
                            customHeight: 35,
                          ),
                        ],
                      ),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
