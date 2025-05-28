import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

    _fetchCourseData();
  }

  Future<void> _fetchCourseData() async {
    try {
      String collection = widget.isEdited ? 'pendingCourses' : 'courses';

      DocumentSnapshot courseSnapshot = await FirebaseFirestore.instance
          .collection(collection)
          .doc(widget.courseId)
          .get();

      if (courseSnapshot.exists) {
        final courseData = courseSnapshot.data() as Map<String, dynamic>;

        setState(() {
          _courseNameController.text = courseData['courseName'] ?? 'Unknown';
          _coursePriceController.text =
              courseData['coursePrice']?.toString() ?? 'Unknown';
          _courseCategoryController.text =
              courseData['courseCategory'] ?? 'Unknown';
          _courseDescriptionController.text =
              courseData['courseDescription'] ?? 'No description available';
          courseImageUrl = courseData['courseImageUrl'] ?? '';
          changes = List<String>.from(courseData['changes'] ?? []);
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Modern Header with gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Mycolors().darkTeal, Mycolors().blue],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                height: MyUtility(context).height * 0.08,
                width: MyUtility(context).width,
                child: Stack(
                  children: [
                    Positioned(
                      left: 20,
                      top: 0,
                      bottom: 0,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => widget.changePageIndex(5),
                      ),
                    ),
                    Center(
                      child: Text(
                        'Review Course',
                        style: MyTextStyles(context).headerWhite.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Main Content Card
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(30.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Course Image
                            Flexible(
                              flex: 2,
                              child: Container(
                                height: 250,
                                decoration: BoxDecoration(
                                  color: Mycolors().offWhite,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.3),
                                  ),
                                ),
                                child: courseImageUrl != null &&
                                        courseImageUrl!.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: ImageNetwork(
                                          image: courseImageUrl!,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.3,
                                          height: 250,
                                          fitWeb: BoxFitWeb.cover,
                                          fitAndroidIos: BoxFit.cover,
                                          onLoading: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                          onError: Icon(
                                            Icons.error_outline,
                                            color: Colors.red,
                                            size: 50,
                                          ),
                                        ),
                                      )
                                    : Center(
                                        child: Icon(
                                          Icons.image_not_supported_outlined,
                                          size: 50,
                                          color: Mycolors().darkGrey,
                                        ),
                                      ),
                              ),
                            ),
                            SizedBox(width: 30),
                            // Course Details
                            Flexible(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ContentDevTextfields(
                                    headerText: 'Course Name',
                                    inputController: _courseNameController,
                                    keyboardType: '',
                                    readOnly: true,
                                  ),
                                  SizedBox(height: 20),
                                  ContentDevTextfields(
                                    headerText: 'Course Price',
                                    inputController: _coursePriceController,
                                    keyboardType: 'intType',
                                    readOnly: true,
                                  ),
                                  SizedBox(height: 20),
                                  ContentDevTextfields(
                                    headerText: 'Course Category',
                                    inputController: _courseCategoryController,
                                    keyboardType: '',
                                    readOnly: true,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        ContentDevTextfields(
                          headerText: 'Course Description',
                          inputController: _courseDescriptionController,
                          keyboardType: '',
                          maxLines: 7,
                          readOnly: true,
                        ),
                        SizedBox(height: 30),
                        if (changes.isNotEmpty) ...[
                          Text(
                            'Changes Made:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Mycolors().darkGrey,
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Mycolors().offWhite,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: changes
                                  .map((change) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0),
                                        child: Text(
                                          '• $change',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Mycolors().darkGrey,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                          SizedBox(height: 30),
                        ],
                        Center(
                          child: SlimButtons(
                            buttonText: 'Review Modules',
                            buttonColor: Mycolors().blue,
                            textColor: Colors.white,
                            onPressed: () {
                              widget.changePageIndex(10, {
                                'courseId': widget.courseId,
                                'isEdited': widget.isEdited
                              });
                            },
                            customWidth: 180,
                            customHeight: 45,
                          ),
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
    );
  }
}
