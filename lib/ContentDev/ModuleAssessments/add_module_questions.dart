import 'package:a4m/CommonComponents/inputFields/contentDevTextfields.dart';
import 'package:a4m/ContentDev/ModuleAssessments/module_list_item_reusables.dart';
import 'package:flutter/material.dart';
import 'package:a4m/CommonComponents/buttons/slimButtons.dart';
import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:a4m/Themes/text_style.dart';
import 'package:a4m/myutility.dart';
import 'package:provider/provider.dart';
import 'package:a4m/ContentDev/ModuleAssessments/CourseModel.dart';

class AddModuleQuestions extends StatefulWidget {
  final Function(int, {int? moduleIndex}) changePageIndex;
  final int moduleIndex;

  AddModuleQuestions({
    super.key,
    required this.changePageIndex,
    required this.moduleIndex,
  });

  @override
  State<AddModuleQuestions> createState() => _AddModuleQuestionsState();
}

class _AddModuleQuestionsState extends State<AddModuleQuestions> {
  late TextEditingController _trueFalseQuestionController;
  late TextEditingController _trueFalseAnswerController;
  List<String> _answers = [];
  List<bool> _correctAnswers = [];
  String? _selectedQuestionType;
  String _trueFalseAnswer = '';

  @override
  void initState() {
    super.initState();
    _trueFalseQuestionController = TextEditingController();
    _trueFalseAnswerController = TextEditingController();
  }

  @override
  void dispose() {
    _trueFalseQuestionController.dispose();
    _trueFalseAnswerController.dispose();
    super.dispose();
  }

  void _addAnswerField() {
    final String answer = _trueFalseAnswerController.text.trim();
    if (answer.isNotEmpty) {
      setState(() {
        _answers.add(answer);
        _correctAnswers
            .add(false); // Add a corresponding 'false' for correctness
        _trueFalseAnswerController.clear();
      });
    }
  }

  void _removeAnswerField(int index) {
    setState(() {
      _answers.removeAt(index);
      _correctAnswers.removeAt(index);
    });
  }

  void _setCorrectAnswer(int index) {
    setState(() {
      for (int i = 0; i < _correctAnswers.length; i++) {
        _correctAnswers[i] = i == index;
      }
    });
  }

  void _saveQuestion() {
    final courseModel = Provider.of<CourseModel>(context, listen: false);

    if (widget.moduleIndex < 0 ||
        widget.moduleIndex >= courseModel.modules.length) {
      print('Invalid module index');
      return;
    }

    Module module = courseModel.modules[widget.moduleIndex];

    if (_selectedQuestionType == 'true_false') {
      if (_trueFalseQuestionController.text.isNotEmpty &&
          _trueFalseAnswer.isNotEmpty) {
        print(
            'Saving True/False question: ${_trueFalseQuestionController.text}');
        final question = Question(
          questionText: _trueFalseQuestionController.text,
          questionType: 'true_false',
          correctAnswer: _trueFalseAnswer,
        );

        module.addQuestion(question);
        courseModel.updateModule(widget.moduleIndex, module);

        _trueFalseQuestionController.clear();
        _trueFalseAnswer = '';

        widget.changePageIndex(5, moduleIndex: widget.moduleIndex);
      }
    } else if (_selectedQuestionType == 'multiple_choice') {
      if (_trueFalseQuestionController.text.isNotEmpty && _answers.isNotEmpty) {
        final correctAnswerIndex = _correctAnswers.indexOf(true);
        if (correctAnswerIndex == -1) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please select the correct answer.')),
          );
          return;
        }

        print(
            'Saving Multiple Choice question: ${_trueFalseQuestionController.text}');
        final question = Question(
          questionText: _trueFalseQuestionController.text,
          questionType: 'multiple_choice',
          options: _answers,
          correctAnswer: _answers[correctAnswerIndex],
        );

        module.addQuestion(question);
        courseModel.updateModule(widget.moduleIndex, module);

        _trueFalseQuestionController.clear();
        _answers.clear();
        _correctAnswers.clear();

        widget.changePageIndex(5, moduleIndex: widget.moduleIndex);
      }
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
                                  _answers.clear();
                                  _correctAnswers.clear();
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
                            ContentDevTextfields(
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
                                  buttonColor: _trueFalseAnswer == 'True'
                                      ? Mycolors().darkTeal
                                      : Mycolors().blue,
                                  onPressed: () {
                                    setState(() {
                                      _trueFalseAnswer = 'True';
                                    });
                                  },
                                  customWidth: 75,
                                  customHeight: 30,
                                  textColor: Colors.white,
                                ),
                                SizedBox(width: 10),
                                SlimButtons(
                                  buttonText: 'False',
                                  buttonColor: _trueFalseAnswer == 'False'
                                      ? Mycolors().darkTeal
                                      : Mycolors().red,
                                  onPressed: () {
                                    setState(() {
                                      _trueFalseAnswer = 'False';
                                    });
                                  },
                                  customWidth: 75,
                                  customHeight: 30,
                                  textColor: Colors.white,
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                          ],
                          if (_selectedQuestionType == 'multiple_choice') ...[
                            Text(
                              'Question',
                              style: MyTextStyles(context).smallBlack,
                            ),
                            SizedBox(height: 10),
                            ContentDevTextfields(
                              inputController: _trueFalseQuestionController,
                              keyboardType: '',
                              maxLines: 5,
                            ),
                            Text(
                              'Question Answers',
                              style: MyTextStyles(context).smallBlack,
                            ),
                            SizedBox(height: 10),
                            ContentDevTextfields(
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
                            Column(
                              children: [
                                for (int i = 0; i < _answers.length; i++)
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _correctAnswers[i],
                                        onChanged: (value) {
                                          _setCorrectAnswer(i);
                                        },
                                      ),
                                      Expanded(
                                        child: AddModuleListItem(
                                          text: _answers[i],
                                          onEdit: () {},
                                          onDelete: () => _removeAnswerField(i),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            SizedBox(height: 20),
                          ],
                          SlimButtons(
                            buttonText: 'Save Question',
                            buttonColor: Colors.white,
                            onPressed: _saveQuestion,
                            customWidth: 160,
                            customHeight: 40,
                            borderColor: Mycolors().darkGrey,
                            textColor: Mycolors().darkGrey,
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
