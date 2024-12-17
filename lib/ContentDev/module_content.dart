import 'package:a4m/ContentDev/ModuleAssessments/module_list_item_reusables.dart';
import 'package:flutter/material.dart';
import 'package:a4m/CommonComponents/buttons/slimButtons.dart';
import 'package:a4m/CommonComponents/inputFields/myTextFields.dart';
import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:a4m/Themes/text_style.dart';
import 'package:a4m/myutility.dart';

class ModuleContent extends StatefulWidget {
  final Function(int) changePageIndex;

  ModuleContent({
    super.key,
    required this.changePageIndex,
  });

  @override
  State<ModuleContent> createState() => _ModuleContentState();
}

class _ModuleContentState extends State<ModuleContent> {
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
              children: [
                // Header
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
                // Content
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MyUtility(context).height * 0.78,
                  ),
                  child: Container(
                    color: Colors.white,
                    width: MyUtility(context).width,
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Row(
                                children: [
                                  // Dropdown for Question Type
                                  Text(
                                    'Tests',
                                    style: MyTextStyles(context).mediumBlack,
                                  ),
                                  Spacer(),
                                  SlimButtons(
                                    buttonText: 'Add Question',
                                    buttonColor: Colors.white,
                                    onPressed: () {
                                      widget.changePageIndex(4);
                                    },
                                    customWidth: 160,
                                    customHeight: 40,
                                    borderColor: Mycolors().darkGrey,
                                    textColor: Mycolors().darkGrey,
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              Container(
                                decoration: BoxDecoration(
                                  // border: Border.all(
                                  //   color: Mycolors().darkGrey,
                                  //   width: 1.0,
                                  // ),
                                  borderRadius: BorderRadius.circular(3.0),
                                ),
                                child: AddModuleListItem(
                                  text: 'Question Title',
                                  onEdit: () {},
                                  onDelete: () {},
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Column(
                            children: [
                              Row(
                                children: [
                                  // Dropdown for Question Type
                                  Text(
                                    'Task/Activities',
                                    style: MyTextStyles(context).mediumBlack,
                                  ),
                                  Spacer(),
                                  SlimButtons(
                                    buttonText: 'Add Task',
                                    buttonColor: Colors.white,
                                    onPressed: () {
                                      widget.changePageIndex(6);
                                    },
                                    customWidth: 160,
                                    customHeight: 40,
                                    borderColor: Mycolors().darkGrey,
                                    textColor: Mycolors().darkGrey,
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              Container(
                                decoration: BoxDecoration(
                                  // border: Border.all(
                                  //   color: Mycolors().darkGrey,
                                  //   width: 1.0,
                                  // ),
                                  borderRadius: BorderRadius.circular(3.0),
                                ),
                                child: AddModuleListItem(
                                  text: 'Question Title',
                                  onEdit: () {},
                                  onDelete: () {},
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Column(
                            children: [
                              Row(
                                children: [
                                  // Dropdown for Question Type
                                  Text(
                                    'Assignments',
                                    style: MyTextStyles(context).mediumBlack,
                                  ),
                                  Spacer(),
                                  SlimButtons(
                                    buttonText: 'Add Assessment',
                                    buttonColor: Colors.white,
                                    onPressed: () {
                                      widget.changePageIndex(7);
                                    },
                                    customWidth: 160,
                                    customHeight: 40,
                                    borderColor: Mycolors().darkGrey,
                                    textColor: Mycolors().darkGrey,
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              Container(
                                decoration: BoxDecoration(
                                  // border: Border.all(
                                  //   color: Mycolors().darkGrey,
                                  //   width: 1.0,
                                  // ),
                                  borderRadius: BorderRadius.circular(3.0),
                                ),
                                child: AddModuleListItem(
                                  text: 'Question Title',
                                  onEdit: () {},
                                  onDelete: () {},
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
