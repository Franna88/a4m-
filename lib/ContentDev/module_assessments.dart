import 'package:a4m/Admin/Dashboard/ui/coursePerformancePieChart.dart';
import 'package:a4m/Admin/Dashboard/ui/monthlySalesChart.dart';
import 'package:a4m/Admin/Dashboard/ui/monthlyStatSumContainers.dart';
import 'package:a4m/CommonComponents/buttons/slimButtons.dart';
import 'package:a4m/CommonComponents/inputFields/myTextFields.dart';

import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:a4m/Themes/text_style.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';

class ModuleAssessments extends StatefulWidget {
  final Function(int) changePageIndex;

  ModuleAssessments({
    super.key,
    required this.changePageIndex,
  });

  @override
  State<ModuleAssessments> createState() => _ModuleAssessmentsState();
}

class _ModuleAssessmentsState extends State<ModuleAssessments> {
  late TextEditingController _trueFalseQuestionController;
  late TextEditingController _coursePriceController;
  late TextEditingController _courseCategoryController;
  late TextEditingController _courseDescriptionController;

  String? _selectedQuestionType; // Declare the selected question type

  @override
  void initState() {
    super.initState();
    _trueFalseQuestionController = TextEditingController();
    _coursePriceController = TextEditingController();
    _courseCategoryController = TextEditingController();
    _courseDescriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _trueFalseQuestionController.dispose();
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
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Mycolors().darkTeal,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  height: MyUtility(context).height * 0.06,
                  width: MyUtility(context).width,
                  child: Center(
                    child: Text(
                      'Module Assessments',
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Question Type',
                        style: MyTextStyles(context).smallBlack,
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: MyUtility(context).width * 0.2,
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'true_false',
                              child: Text('True/False'),
                            ),
                            DropdownMenuItem(
                              value: 'multiple_choice',
                              child: Text('Multiple Choice'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedQuestionType = value;
                            });
                          },
                          hint: Text('Select Assessment Type'),
                        ),
                      ),
                      SizedBox(height: MyUtility(context).height * 0.02),
                      if (_selectedQuestionType == 'true_false') ...[
                        Text(
                          'Question',
                          style: MyTextStyles(context).smallBlack,
                        ),
                        SizedBox(height: 10),
                        MyTextFields(
                          inputController: _trueFalseQuestionController,
                          keyboardType: '',
                          maxLines: 5,
                        ),
                        SizedBox(height: MyUtility(context).height * 0.02),
                        Text(
                          'Question Answer',
                          style: MyTextStyles(context).smallBlack,
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            SlimButtons(
                              buttonText: 'True',
                              buttonColor: Mycolors().blue,
                              onPressed: () {},
                              customWidth: 75,
                              customHeight: 30,
                              textColor: Colors.white,
                            ),
                            SizedBox(width: 10),
                            SlimButtons(
                              buttonText: 'False',
                              buttonColor: Mycolors().red,
                              onPressed: () {},
                              customWidth: 75,
                              customHeight: 30,
                              textColor: Colors.white,
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        SlimButtons(
                          buttonText: 'Save',
                          buttonColor: Colors.white,
                          onPressed: () {},
                          customWidth: 160,
                          customHeight: 40,
                          borderColor: Mycolors().darkGrey,
                          textColor: Mycolors().darkGrey,
                        ),
                      ] else if (_selectedQuestionType ==
                          'multiple_choice') ...[
                        Text(
                          'Question',
                          style: MyTextStyles(context).smallBlack,
                        ),
                        SizedBox(height: 10),
                        MyTextFields(
                          inputController: _trueFalseQuestionController,
                          keyboardType: '',
                          maxLines: 5,
                        ),
                        SizedBox(height: MyUtility(context).height * 0.02),
                        Row(
                          children: [
                            Text(
                              'Question Answers',
                              style: MyTextStyles(context).smallBlack,
                            ),
                            Spacer(),
                            SlimButtons(
                              buttonText: 'ADD',
                              buttonColor: Mycolors().blue,
                              onPressed: () {},
                              customWidth: 75,
                              customHeight: 30,
                              textColor: Colors.white,
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        MyTextFields(
                          inputController: _trueFalseQuestionController,
                          keyboardType: '',
                          maxLines: 5,
                        ),
                        SizedBox(height: 20),
                        SlimButtons(
                          buttonText: 'Save',
                          buttonColor: Colors.white,
                          onPressed: () {},
                          customWidth: 160,
                          customHeight: 40,
                          borderColor: Mycolors().darkGrey,
                          textColor: Mycolors().darkGrey,
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
