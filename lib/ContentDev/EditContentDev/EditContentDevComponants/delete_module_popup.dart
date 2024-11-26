import 'package:a4m/CommonComponents/buttons/slimButtons.dart';
import 'package:a4m/CommonComponents/inputFields/myTextFields.dart';
import 'package:a4m/Themes/text_style.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';

import '../../../Themes/Constants/myColors.dart';

class DeleteModulePopup extends StatefulWidget {
  const DeleteModulePopup({super.key});

  @override
  State<DeleteModulePopup> createState() => _DeleteModulePopupState();
}

class _DeleteModulePopupState extends State<DeleteModulePopup> {
  final TextEditingController _deleteReasonController = TextEditingController();
  bool _showTextField = false;

  void _toggleTextField() {
    setState(() {
      _showTextField = !_showTextField;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _showTextField
          ? MyUtility(context).height * 0.4
          : MyUtility(context).height * 0.25,
      width: MyUtility(context).width * 0.3,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              'Request removal of this module',
              style: MyTextStyles(context).subHeaderBlack,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SlimButtons(
                  buttonText: 'Remove Module',
                  buttonColor: Mycolors().peach,
                  onPressed: _toggleTextField,
                  customWidth: 130,
                  customHeight: 40,
                ),
                const SizedBox(width: 20),
                SlimButtons(
                  buttonText: 'Cancel',
                  buttonColor: Mycolors().peach,
                  onPressed: () {
                    Navigator.pop(context); // Close the popup
                  },
                  customWidth: 130,
                  customHeight: 40,
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_showTextField)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyTextFields(
                    inputController: _deleteReasonController,
                    headerText: 'Reason for removal of module:',
                    keyboardType: '',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SlimButtons(
                    buttonText: 'Submit',
                    buttonColor: Mycolors().blue,
                    onPressed: () {},
                    customWidth: 80,
                    customHeight: 40,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
