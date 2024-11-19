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
                                onPressed: () {},
                                customWidth: 160,
                                customHeight: 40,
                                borderColor: Mycolors().darkGrey,
                                textColor: Mycolors().darkGrey,
                              ),
                            ],
                          ),
                          Container(
                            child: Column(
                              children: [
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              padding: EdgeInsets.all(10.0),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.5),
                                                    spreadRadius: 0,
                                                    blurRadius: 5,
                                                    offset: Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                children: [
                                                  // Checkbox and text
                                                  Text(
                                                    'True/False',
                                                    style: MyTextStyles(context)
                                                        .smallBlack,
                                                  ),
                                                  Spacer(),
                                                  Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          SlimButtons(
                                                            onPressed: () {
                                                              // Add edit logic here
                                                            },
                                                            buttonText: 'EDIT',
                                                            buttonColor:
                                                                Mycolors().blue,
                                                            textColor:
                                                                Colors.white,
                                                            customWidth: 75,
                                                            customHeight: 30,
                                                          ),
                                                          SizedBox(width: 10),
                                                          Container(
                                                            width: 2,
                                                            height: 30,
                                                            color: Colors.grey,
                                                          ),
                                                          SizedBox(width: 10),
                                                          SlimButtons(
                                                            onPressed: () {},
                                                            buttonText:
                                                                'DELETE',
                                                            buttonColor:
                                                                Mycolors().red,
                                                            textColor:
                                                                Colors.white,
                                                            customWidth: 75,
                                                            customHeight: 30,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
