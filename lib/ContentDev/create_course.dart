import 'package:a4m/Admin/Dashboard/ui/coursePerformancePieChart.dart';
import 'package:a4m/Admin/Dashboard/ui/monthlySalesChart.dart';
import 'package:a4m/Admin/Dashboard/ui/monthlyStatSumContainers.dart';
import 'package:a4m/CommonComponents/buttons/slimButtons.dart';
import 'package:a4m/CommonComponents/inputFields/contentDevTextfields.dart';
import 'package:a4m/ContentDev/ModuleAssessments/CourseModel.dart';
import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:a4m/Themes/text_style.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:html' as html;

import 'package:provider/provider.dart';

class CreateCourse extends StatefulWidget {
  Function(int) changePageIndex;
  CreateCourse({
    super.key,
    required this.changePageIndex,
  });

  @override
  State<CreateCourse> createState() => _CreateCourseState();
}

class _CreateCourseState extends State<CreateCourse> {
  late TextEditingController _courseNameController;
  late TextEditingController _coursePriceController;
  late TextEditingController _courseCategoryController;
  late TextEditingController _courseDescriptionController;
  Uint8List? _selectedImage;

  @override
  void initState() {
    super.initState();
    _courseNameController = TextEditingController();
    _coursePriceController = TextEditingController();
    _courseCategoryController = TextEditingController();
    _courseDescriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _courseNameController.dispose();
    _coursePriceController.dispose();
    _courseCategoryController.dispose();
    _courseDescriptionController.dispose();
    super.dispose();
  }

  void _pickImage() async {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) async {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(files[0]);
        reader.onLoadEnd.listen((e) {
          setState(() {
            _selectedImage = reader.result as Uint8List;
          });
        });
      }
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Mycolors().blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    height: MyUtility(context).height * 0.06,
                    width: MyUtility(context).width,
                    child: Center(
                      child: Text(
                        'Create Course',
                        style: MyTextStyles(context).headerWhite,
                      ),
                    ),
                  ),
                ),
                Container(
                    color: Colors.white,
                    width: MyUtility(context).width,
                    height: MyUtility(context).height * 0.78,
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              InkWell(
                                onTap: _pickImage,
                                child: Container(
                                  height: MyUtility(context).height * 0.38,
                                  width: MyUtility(context).width * 0.3,
                                  decoration: BoxDecoration(
                                    color: Mycolors().offWhite,
                                    borderRadius: BorderRadius.circular(10),
                                    image: _selectedImage != null
                                        ? DecorationImage(
                                            image: MemoryImage(_selectedImage!),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: _selectedImage == null
                                      ? Center(
                                          child: Icon(
                                            Icons.image,
                                            size: 50,
                                            color: Mycolors().darkGrey,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                              Spacer(),
                              SizedBox(
                                height: MyUtility(context).height * 0.38,
                                width: MyUtility(context).width * 0.3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                      width: MyUtility(context).width * 0.3,
                                      child: ContentDevTextfields(
                                        headerText: 'Course Name',
                                        inputController: _courseNameController,
                                        keyboardType: '',
                                      ),
                                    ),
                                    SizedBox(
                                      width: MyUtility(context).width * 0.3,
                                      child: ContentDevTextfields(
                                        headerText: 'Course Price',
                                        inputController: _coursePriceController,
                                        keyboardType: 'intType',
                                      ),
                                    ),
                                    SizedBox(
                                      width: MyUtility(context).width * 0.3,
                                      child: ContentDevTextfields(
                                        headerText: 'Course Category',
                                        inputController:
                                            _courseCategoryController,
                                        keyboardType: '',
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Center(
                              child: SizedBox(
                                width: MyUtility(context).width * 0.8,
                                child: ContentDevTextfields(
                                  headerText: 'Course Description',
                                  inputController: _courseDescriptionController,
                                  keyboardType: '',
                                  maxLines: 7,
                                ),
                              ),
                            ),
                          ),
                          Spacer(),
                          SlimButtons(
                            buttonText: 'Next',
                            buttonColor: Colors.white,
                            borderColor: Color.fromRGBO(203, 210, 224, 1),
                            textColor: Mycolors().green,
                            onPressed: () {
                              if (_validateInputs()) {
                                final courseModel = Provider.of<CourseModel>(
                                    context,
                                    listen: false);
                                courseModel
                                    .setCourseName(_courseNameController.text);
                                courseModel.setCoursePrice(
                                    _coursePriceController.text);
                                courseModel.setCourseCategory(
                                    _courseCategoryController.text);
                                courseModel.setCourseDescription(
                                    _courseDescriptionController.text);
                                courseModel.setCourseImage(_selectedImage);

                                widget.changePageIndex(3);
                              }
                            },
                            customWidth: 85,
                            customHeight: 35,
                          )
                        ],
                      ),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _validateInputs() {
    if (_courseNameController.text.isEmpty ||
        _coursePriceController.text.isEmpty ||
        _courseCategoryController.text.isEmpty ||
        _courseDescriptionController.text.isEmpty ||
        _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields and select an image.')),
      );
      return false;
    }
    return true;
  }
}
