import 'package:flutter/material.dart';
import 'package:a4m/CommonComponents/buttons/slimButtons.dart';
import 'package:a4m/CommonComponents/inputFields/myTextFields.dart';
import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:a4m/Themes/text_style.dart';
import 'package:a4m/myutility.dart';

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
  late TextEditingController _trueFalseAnswerController;
  List<String> _answers = [];
  String? _selectedQuestionType;

  @override
  void initState() {
    super.initState();
    _trueFalseQuestionController = TextEditingController();
    _trueFalseAnswerController = TextEditingController();
  }

  @override
  void dispose() {
    _trueFalseQuestionController.dispose();
    super.dispose();
  }

  void _addAnswerField() {
    final String answer = _trueFalseAnswerController.text.trim();
    if (answer.isNotEmpty) {
      setState(() {
        _answers.add(answer);
        _trueFalseAnswerController.clear(); // Clear the answer text field only
      });
    }
  }

  void _removeAnswerField(int index) {
    setState(() {
      _answers.removeAt(index);
    });
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
                        'Module Assessments',
                        style: MyTextStyles(context).headerWhite,
                      ),
                    ),
                  ),
                ),
                // Content
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        MyUtility(context).height * 0.78, // Minimum height
                  ),
                  child: Container(
                    color: Colors.white,
                    width: MyUtility(context).width,
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Dropdown for Question Type
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
                                  _answers.clear(); // Clear previous answers
                                });
                              },
                              hint: Text('Select Assessment Type'),
                            ),
                          ),
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
                              onPressed: () {
                                widget.changePageIndex(5);
                              },
                              customWidth: 160,
                              customHeight: 40,
                              borderColor: Mycolors().darkGrey,
                              textColor: Mycolors().darkGrey,
                            ),
                          ],

                          SizedBox(height: MyUtility(context).height * 0.02),
                          if (_selectedQuestionType == 'multiple_choice') ...[
                            Text(
                              'Questions',
                              style: MyTextStyles(context).smallBlack,
                            ),
                            SizedBox(height: 10),
                            MyTextFields(
                              inputController: _trueFalseQuestionController,
                              keyboardType: '',
                              maxLines: 5,
                            ),
                            Text(
                              'Question Answers',
                              style: MyTextStyles(context).smallBlack,
                            ),
                            SizedBox(height: 10),
                            MyTextFields(
                              inputController: _trueFalseAnswerController,
                              keyboardType: '',
                              maxLines: 3,
                            ),
                            SizedBox(height: MyUtility(context).height * 0.02),
                            Row(
                              children: [
                                Spacer(),
                                SlimButtons(
                                  buttonText: 'ADD',
                                  buttonColor: Mycolors().blue,
                                  onPressed: _addAnswerField,
                                  customWidth: 75,
                                  customHeight: 30,
                                  textColor: Colors.white,
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            // List of Answers
                            Column(
                              children: [
                                for (int i = 0; i < _answers.length; i++)
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
                                                Row(
                                                  children: [
                                                    Checkbox(
                                                      value: false,
                                                      onChanged: (bool? value) {
                                                        // Add your checkbox logic here
                                                      },
                                                    ),
                                                    Text(
                                                      _answers[i],
                                                      style:
                                                          MyTextStyles(context)
                                                              .smallBlack,
                                                    ),
                                                  ],
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
                                                          onPressed: () =>
                                                              _removeAnswerField(
                                                                  i),
                                                          buttonText: 'DELETE',
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

                            SizedBox(height: 20),
                            SlimButtons(
                              buttonText: 'Save',
                              buttonColor: Colors.white,
                              onPressed: () {
                                widget.changePageIndex(5);
                              },
                              customWidth: 160,
                              customHeight: 40,
                              borderColor: Mycolors().darkGrey,
                              textColor: Mycolors().darkGrey,
                            ),
                          ],
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
