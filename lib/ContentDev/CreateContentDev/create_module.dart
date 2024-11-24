import 'package:a4m/Admin/Dashboard/ui/coursePerformancePieChart.dart';
import 'package:a4m/Admin/Dashboard/ui/monthlySalesChart.dart';
import 'package:a4m/Admin/Dashboard/ui/monthlyStatSumContainers.dart';
import 'package:a4m/CommonComponents/buttons/slimButtons.dart';
import 'package:a4m/CommonComponents/inputFields/contentDevTextfields.dart';
import 'package:a4m/CommonComponents/inputFields/myTextFields.dart';
import 'package:a4m/ContentDev/CreateContentDev/add_content_popup.dart';

import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:a4m/Themes/text_style.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';

class CreateModule extends StatefulWidget {
  Function(int) changePageIndex;
  CreateModule({
    super.key,
    required this.changePageIndex,
  });

  @override
  State<CreateModule> createState() => _CreateModuleState();
}

class _CreateModuleState extends State<CreateModule> {
  late TextEditingController _moduleNameController;

  late TextEditingController _moduleDescriptionController;
  late TextEditingController _contentDescriptionController;

  Future openAddContentPopup() => showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: AddContentPopup(),
        );
      });

  @override
  void initState() {
    super.initState();
    _moduleNameController = TextEditingController();

    _moduleDescriptionController = TextEditingController();
    _contentDescriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _moduleNameController.dispose();

    _moduleDescriptionController.dispose();
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
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                        'Create Module',
                        style: MyTextStyles(context).headerWhite,
                      ),
                    ),
                  ),
                ),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: ContentDevTextfields(
                                inputController: _moduleNameController,
                                headerText: 'Module Name',
                                keyboardType: '',
                              ),
                            ),
                            Spacer(),
                            SlimButtons(
                              buttonText: 'Save',
                              textColor: Mycolors().darkGrey,
                              buttonColor: Colors.white,
                              borderColor: Mycolors().darkGrey,
                              onPressed: () {},
                              customWidth: 75,
                              customHeight: 40,
                            ),
                            SizedBox(width: 30),
                            SlimButtons(
                              buttonText: 'Assessments',
                              textColor: Mycolors().darkGrey,
                              buttonColor: Colors.white,
                              borderColor: Mycolors().darkGrey,
                              onPressed: () {
                                widget.changePageIndex(5);
                              },
                              customWidth: 125,
                              customHeight: 40,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.3,
                            width: MediaQuery.of(context).size.width * 0.3,
                            decoration: BoxDecoration(
                              color: Mycolors().offWhite,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.image,
                                size: 50,
                                color: Mycolors().darkGrey,
                              ),
                            ),
                          ),
                          Spacer(),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.82,
                            child: ContentDevTextfields(
                              headerText: 'Module Description',
                              inputController: _moduleDescriptionController,
                              keyboardType: '',
                              maxLines: 9,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      SlimButtons(
                        buttonText: 'Add Content',
                        buttonColor: Colors.white,
                        borderColor: Mycolors().darkGrey,
                        textColor: Mycolors().darkGrey,
                        onPressed: () {
                          openAddContentPopup();
                        },
                        customWidth: 125,
                        customHeight: 40,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.82,
                            child: ContentDevTextfields(
                              inputController: _contentDescriptionController,
                              keyboardType: '',
                              maxLines: 3,
                            ),
                          ),
                        ),
                      ),
                    ],
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
