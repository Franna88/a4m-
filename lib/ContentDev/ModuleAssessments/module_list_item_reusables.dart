import 'package:a4m/CommonComponents/buttons/slimButtons.dart';
import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:a4m/Themes/text_style.dart';
import 'package:flutter/material.dart';

class AddModuleListItem extends StatelessWidget {
  final String text;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool showCheckbox;
  final bool? checkboxValue;
  final ValueChanged<bool?>? onCheckboxChanged;

  const AddModuleListItem({
    Key? key,
    required this.text,
    required this.onEdit,
    required this.onDelete,
    this.showCheckbox = false,
    this.checkboxValue,
    this.onCheckboxChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
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
                  // Optional checkbox with text
                  if (showCheckbox)
                    Row(
                      children: [
                        Checkbox(
                          value: checkboxValue,
                          onChanged: onCheckboxChanged,
                        ),
                        Text(
                          text,
                          style: MyTextStyles(context).smallBlack,
                        ),
                      ],
                    )
                  else
                    Text(
                      text,
                      style: MyTextStyles(context).smallBlack,
                    ),
                  const Spacer(),
                  Column(
                    children: [
                      Row(
                        children: [
                          SlimButtons(
                            onPressed: onEdit,
                            buttonText: 'EDIT',
                            buttonColor: Mycolors().blue,
                            textColor: Colors.white,
                            customWidth: 75,
                            customHeight: 30,
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 2,
                            height: 30,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 10),
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
    );
  }
}
