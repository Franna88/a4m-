import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_network/image_network.dart';
import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:a4m/CommonComponents/inputFields/contentDevTextfields.dart';
import 'package:a4m/CommonComponents/buttons/slimButtons.dart';
import 'package:a4m/Themes/text_style.dart';
import 'package:a4m/myutility.dart';

class ReviewCourse extends StatefulWidget {
  final Function(int, [Map<String, dynamic>?]) changePageIndex;
  final String courseId;
  final bool isEdited;

  const ReviewCourse({
    super.key,
    required this.changePageIndex,
    required this.courseId,
    required this.isEdited,
  });

  @override
  State<ReviewCourse> createState() => _ReviewCourseState();
}

class _ReviewCourseState extends State<ReviewCourse> {
  late TextEditingController _courseNameController;
  late TextEditingController _coursePriceController;
  late TextEditingController _courseCategoryController;
  late TextEditingController _courseDescriptionController;
  String? courseImageUrl;
  List<String> changes = [];

  @override
  void initState() {
    super.initState();
    _courseNameController = TextEditingController();
    _coursePriceController = TextEditingController();
    _courseCategoryController = TextEditingController();
    _courseDescriptionController = TextEditingController();

    // Fetch course data when the page initializes
    _fetchCourseData();
  }

  Future<void> _fetchCourseData() async {
    try {
      // Determine whether to fetch from pendingCourses or courses
      String collection = widget.isEdited ? 'pendingCourses' : 'courses';

      DocumentSnapshot courseSnapshot = await FirebaseFirestore.instance
          .collection(collection)
          .doc(widget.courseId)
          .get();

      if (courseSnapshot.exists) {
        final courseData = courseSnapshot.data() as Map<String, dynamic>;

        // Populate the controllers with course data
        _courseNameController.text = courseData['courseName'] ?? 'Unknown';
        _coursePriceController.text = courseData['coursePrice'] ?? 'Unknown';
        _courseCategoryController.text =
            courseData['courseCategory'] ?? 'Unknown';
        _courseDescriptionController.text =
            courseData['courseDescription'] ?? 'No description available';

        setState(() {
          courseImageUrl = courseData['courseImageUrl'] ?? '';
          changes =
              (courseData['changes'] as List<dynamic>?)?.cast<String>() ?? [];
        });

        print("Course Image URL: $courseImageUrl");
        print("Detected Changes: $changes");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Course data not found.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch course data: $e')),
      );
    }
  }

  @override
  void dispose() {
    _courseNameController.dispose();
    _coursePriceController.dispose();
    _courseCategoryController.dispose();
    _courseDescriptionController.dispose();
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
                            courseImageUrl != null && courseImageUrl!.isNotEmpty
                                ? ImageNetwork(
                                    image: courseImageUrl!,
                                    height: MyUtility(context).height * 0.38,
                                    width: MyUtility(context).width * 0.3,
                                    borderRadius: BorderRadius.circular(10),
                                    duration: 1500,
                                    curve: Curves.easeIn,
                                    onLoading: CircularProgressIndicator(),
                                    onError: const Icon(
                                      Icons.error,
                                      color: Colors.red,
                                      size: 40,
                                    ),
                                  )
                                : Container(
                                    height: MyUtility(context).height * 0.38,
                                    width: MyUtility(context).width * 0.3,
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
                            widget.changePageIndex(10, {
                              'courseId': widget.courseId,
                              'isEdited': widget.isEdited
                            });
                          },
                          customWidth: 85,
                          customHeight: 35,
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
