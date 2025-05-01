import 'package:a4m/CommonComponents/buttons/slimButtons.dart';
import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:a4m/Themes/text_style.dart';
import 'package:flutter/material.dart';

class TestsContainer extends StatelessWidget {
  final String title;
  final String buttonText;
  final VoidCallback onAddQuestion;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TestsContainer({
    super.key,
    required this.title,
    required this.buttonText,
    required this.onAddQuestion,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              // Title Text
              Text(
                title,
                style: MyTextStyles(context).mediumBlack,
              ),
              const Spacer(),
              // Add Question Button
              SlimButtons(
                buttonText: buttonText,
                buttonColor: Colors.white,
                onPressed: onAddQuestion,
                customWidth: 160,
                customHeight: 40,
                borderColor: Mycolors().darkGrey,
                textColor: Mycolors().darkGrey,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Mycolors().darkGrey,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(3.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 0,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Question Type Text
                              Text(
                                'True/False',
                                style: MyTextStyles(context).smallBlack,
                              ),
                              const Spacer(),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      // Edit Button
                                      SlimButtons(
                                        onPressed: onEdit,
                                        buttonText: 'EDIT',
                                        buttonColor: Mycolors().blue,
                                        textColor: Colors.white,
                                        customWidth: 75,
                                        customHeight: 30,
                                      ),
                                      const SizedBox(width: 10),
                                      // Separator Line
                                      Container(
                                        width: 2,
                                        height: 30,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 10),
                                      // Delete Button
                                      SlimButtons(
                                        onPressed: onDelete,
                                        buttonText: 'DELETE',
                                        buttonColor: Mycolors().red,
                                        textColor: Colors.white,
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
