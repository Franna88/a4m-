import 'package:a4m/ContentDev/ModuleAssessments/module_list_item_reusables.dart';
import 'package:flutter/material.dart';
import 'package:a4m/CommonComponents/buttons/slimButtons.dart';
import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:a4m/Themes/text_style.dart';
import 'package:a4m/myutility.dart';
import 'package:provider/provider.dart';
import 'package:a4m/ContentDev/ModuleAssessments/CourseModel.dart';

class ModuleContent extends StatefulWidget {
  final Function(int, {int? moduleIndex}) changePageIndex;
  final int moduleIndex;

  ModuleContent({
    super.key,
    required this.changePageIndex,
    required this.moduleIndex,
  });

  @override
  State<ModuleContent> createState() => _ModuleContentState();
}

class _ModuleContentState extends State<ModuleContent> {
  late int _currentModuleIndex;

  @override
  void initState() {
    super.initState();
    _currentModuleIndex = widget.moduleIndex;
    print('Initial moduleIndex: $_currentModuleIndex');
  }

  @override
  void didUpdateWidget(covariant ModuleContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.moduleIndex != oldWidget.moduleIndex) {
      setState(() {
        _currentModuleIndex = widget.moduleIndex;
        print('Updated moduleIndex: $_currentModuleIndex');
      });
    }
  }

  void _navigateToNextModule() {
    final courseModel = Provider.of<CourseModel>(context, listen: false);
    if (_currentModuleIndex < courseModel.modules.length - 1) {
      setState(() {
        _currentModuleIndex++;
        print('Navigating to next module, moduleIndex: $_currentModuleIndex');
      });
    }
  }

  void _navigateToPreviousModule() {
    if (_currentModuleIndex > 0) {
      setState(() {
        _currentModuleIndex--;
        print(
            'Navigating to previous module, moduleIndex: $_currentModuleIndex');
      });
    }
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
                        'Module Assessments (Module ${_currentModuleIndex + 1})',
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
                          // Module Navigation Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SlimButtons(
                                buttonText: 'Previous Module',
                                buttonColor: Colors.white,
                                borderColor: Mycolors().darkGrey,
                                textColor: Mycolors().darkGrey,
                                onPressed: _navigateToPreviousModule,
                                customWidth: 150,
                                customHeight: 40,
                              ),
                              SlimButtons(
                                buttonText: 'Next Module',
                                buttonColor: Colors.white,
                                borderColor: Mycolors().darkGrey,
                                textColor: Mycolors().darkGrey,
                                onPressed: _navigateToNextModule,
                                customWidth: 150,
                                customHeight: 40,
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          // Tests Section
                          Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Tests',
                                    style: MyTextStyles(context).mediumBlack,
                                  ),
                                  Spacer(),
                                  SlimButtons(
                                    buttonText: 'Add Question',
                                    buttonColor: Colors.white,
                                    onPressed: () {
                                      print(
                                          'Navigating to add question for module index: $_currentModuleIndex');
                                      widget.changePageIndex(4,
                                          moduleIndex: _currentModuleIndex);
                                    },
                                    customWidth: 160,
                                    customHeight: 40,
                                    borderColor: Mycolors().darkGrey,
                                    textColor: Mycolors().darkGrey,
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              // Display the questions for the module
                              Consumer<CourseModel>(
                                builder: (context, courseModel, child) {
                                  Module module =
                                      courseModel.modules[_currentModuleIndex];
                                  print(
                                      'Displaying questions for module index: $_currentModuleIndex');
                                  return Column(
                                    children: module.questions.map((question) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(3.0),
                                        ),
                                        child: AddModuleListItem(
                                          text: question.questionText,
                                          onEdit: () {
                                            // Logic to edit the question
                                          },
                                          onDelete: () {
                                            setState(() {
                                              module.removeQuestion(module
                                                  .questions
                                                  .indexOf(question));
                                              courseModel.updateModule(
                                                  _currentModuleIndex, module);
                                            });
                                          },
                                        ),
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          // Tasks Section
                          Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Task/Activities',
                                    style: MyTextStyles(context).mediumBlack,
                                  ),
                                  Spacer(),
                                  SlimButtons(
                                    buttonText: 'Add Task',
                                    buttonColor: Colors.white,
                                    onPressed: () {
                                      print(
                                          'Navigating to add task for module index: $_currentModuleIndex');
                                      widget.changePageIndex(6,
                                          moduleIndex: _currentModuleIndex);
                                    },
                                    customWidth: 160,
                                    customHeight: 40,
                                    borderColor: Mycolors().darkGrey,
                                    textColor: Mycolors().darkGrey,
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              Consumer<CourseModel>(
                                builder: (context, courseModel, child) {
                                  Module module =
                                      courseModel.modules[_currentModuleIndex];
                                  return Column(
                                    children: module.tasks.map((task) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(3.0),
                                        ),
                                        child: AddModuleListItem(
                                          text: task.title,
                                          onEdit: () {},
                                          onDelete: () {
                                            setState(() {
                                              module.removeTask(
                                                  module.tasks.indexOf(task));
                                              courseModel.updateModule(
                                                  _currentModuleIndex, module);
                                            });
                                          },
                                        ),
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          // Assignments Section
                          Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Assignments',
                                    style: MyTextStyles(context).mediumBlack,
                                  ),
                                  Spacer(),
                                  SlimButtons(
                                    buttonText: 'Add Assessment',
                                    buttonColor: Colors.white,
                                    onPressed: () {
                                      print(
                                          'Navigating to add assignment for module index: $_currentModuleIndex');
                                      widget.changePageIndex(7,
                                          moduleIndex: _currentModuleIndex);
                                    },
                                    customWidth: 160,
                                    customHeight: 40,
                                    borderColor: Mycolors().darkGrey,
                                    textColor: Mycolors().darkGrey,
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              Consumer<CourseModel>(
                                builder: (context, courseModel, child) {
                                  Module module =
                                      courseModel.modules[_currentModuleIndex];
                                  return Column(
                                    children:
                                        module.assignments.map((assignment) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(3.0),
                                        ),
                                        child: AddModuleListItem(
                                          text: assignment.title,
                                          onEdit: () {},
                                          onDelete: () {
                                            setState(() {
                                              module.removeAssignment(module
                                                  .assignments
                                                  .indexOf(assignment));
                                              courseModel.updateModule(
                                                  _currentModuleIndex, module);
                                            });
                                          },
                                        ),
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 30),
                          // Save Button
                          SlimButtons(
                            buttonText: 'Save & Return',
                            buttonColor: Mycolors().green,
                            borderColor: Mycolors().green,
                            textColor: Colors.white,
                            onPressed: () {
                              final courseModel = Provider.of<CourseModel>(
                                  context,
                                  listen: false);
                              courseModel.updateModule(_currentModuleIndex,
                                  courseModel.modules[_currentModuleIndex]);
                              print(
                                  'Navigating back from module index: $_currentModuleIndex');
                              widget.changePageIndex(3,
                                  moduleIndex: _currentModuleIndex);
                            },
                            customWidth: 180,
                            customHeight: 50,
                          ),
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
