import 'package:a4m/CommonComponents/buttons/AddContentButton.dart';
import 'package:a4m/CommonComponents/inputFields/contentDevTextfields.dart';
import 'package:a4m/Themes/text_style.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../Themes/Constants/myColors.dart';

class AddContentPopup extends StatefulWidget {
  const AddContentPopup({super.key});

  @override
  State<AddContentPopup> createState() => _AdminCourseDetailsPopupState();
}

class _AdminCourseDetailsPopupState extends State<AddContentPopup> {
  late TextEditingController _contentTitleController;

  @override
  void initState() {
    super.initState();
    _contentTitleController = TextEditingController();
  }

  @override
  void dispose() {
    _contentTitleController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MyUtility(context).height * 0.45,
      width: MyUtility(context).width * 0.4,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Container(
            height: 50,
            width: MyUtility(context).width * 0.4,
            decoration: BoxDecoration(
              color: Mycolors().blue,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Center(
              child: Text(
                'Add Content',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: MyUtility(context).height * 0.35,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'I Want To:',
                    style: MyTextStyles(context).mediumBlack,
                  ),
                  Row(
                    children: [
                      AddContentButton(
                        width: 125,
                        buttonText: 'Add Section',
                        onTap: () {
                          print('Add Section');
                        },
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      AddContentButton(
                        width: 140,
                        buttonText: 'Replace Section',
                        onTap: () {
                          print('Replace Section');
                        },
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      AddContentButton(
                        width: 140,
                        buttonText: 'Remove Section',
                        onTap: () {
                          print('Remove Section');
                        },
                      ),
                    ],
                  ),
                  Text(
                    'This is a:',
                    style: MyTextStyles(context).mediumBlack,
                  ),
                  Row(
                    children: [
                      AddContentButton(
                        width: 125,
                        buttonText: 'Title',
                        onTap: () {
                          print('Add Section');
                        },
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      AddContentButton(
                        width: 140,
                        buttonText: 'Description',
                        onTap: () {
                          print('Replace Section');
                        },
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      AddContentButton(
                        width: 140,
                        buttonText: 'Image',
                        onTap: () {
                          print('Remove Section');
                        },
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      AddContentButton(
                        width: 140,
                        buttonText: 'Video',
                        onTap: () {
                          print('Remove Section');
                        },
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      AddContentButton(
                        width: 140,
                        buttonText: 'Audio',
                        onTap: () {
                          print('Remove Section');
                        },
                      ),
                    ],
                  ),
                  ContentDevTextfields(
                    inputController: _contentTitleController,
                    keyboardType: '',
                    headerText: 'Title',
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
