import 'package:a4m/Admin/Dashboard/ui/coursePerformancePieChart.dart';
import 'package:a4m/Admin/Dashboard/ui/monthlySalesChart.dart';
import 'package:a4m/Admin/Dashboard/ui/monthlyStatSumContainers.dart';
import 'package:a4m/CommonComponents/buttons/slimButtons.dart';
import 'package:a4m/CommonComponents/inputFields/contentDevTextfields.dart';
import 'package:a4m/ContentDev/ModuleAssessments/CourseModel.dart';
import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:a4m/Themes/text_style.dart';
import 'package:a4m/myutility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';
import 'dart:typed_data';
import 'dart:html' as html;

import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateCourse extends StatefulWidget {
  Function(int, {int? moduleIndex}) changePageIndex;

  final String? courseId;
  CreateCourse({
    super.key,
    required this.changePageIndex,
    this.courseId,
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
  bool isLoading = false;
  String? _selectedImageUrl;
  Uint8List? _selectedPreviewPdf;
  String? _selectedPreviewPdfUrl;
  String? _selectedPreviewPdfName;

  @override
  void initState() {
    super.initState();
    _courseNameController = TextEditingController();
    _coursePriceController = TextEditingController();
    _courseCategoryController = TextEditingController();
    _courseDescriptionController = TextEditingController();

    if (widget.courseId == null) {
      _clearCourseData(); // 🔥 Reset data only when creating a new course
    } else {
      _fetchCourseData(); // ✅ Load course data if editing
    }
  }

  Future<void> _fetchCourseData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Check if there's a pending edit first
      DocumentSnapshot pendingDoc = await FirebaseFirestore.instance
          .collection('pendingCourses')
          .doc(widget.courseId)
          .get();

      if (pendingDoc.exists) {
        var pendingData = pendingDoc.data() as Map<String, dynamic>;

        setState(() {
          _courseNameController.text = pendingData['courseName'] ?? '';
          _coursePriceController.text = pendingData['coursePrice'] ?? '';
          _courseCategoryController.text = pendingData['courseCategory'] ?? '';
          _courseDescriptionController.text =
              pendingData['courseDescription'] ?? '';
          _selectedImageUrl =
              pendingData['courseImageUrl'] ?? _selectedImageUrl;
          _selectedPreviewPdfUrl = pendingData['previewPdfUrl'];
          _selectedPreviewPdfName = pendingData['previewPdfName'];

          print("⚠️ Loading pending course edits for review.");
        });

        setState(() {
          isLoading = false;
        });
        return;
      }

      // If no pending edits, fetch the live course data
      DocumentSnapshot courseDoc = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .get();

      if (courseDoc.exists) {
        var data = courseDoc.data() as Map<String, dynamic>;

        setState(() {
          _courseNameController.text = data['courseName'] ?? '';
          _coursePriceController.text = data['coursePrice'] ?? '';
          _courseCategoryController.text = data['courseCategory'] ?? '';
          _courseDescriptionController.text = data['courseDescription'] ?? '';
          if (data.containsKey('courseImageUrl') &&
              data['courseImageUrl'] != null) {
            _selectedImageUrl = data['courseImageUrl'];
          }
          if (data.containsKey('previewPdfUrl') &&
              data['previewPdfUrl'] != null) {
            _selectedPreviewPdfUrl = data['previewPdfUrl'];
            _selectedPreviewPdfName = data['previewPdfName'];
          }

          print("✅ Loaded course data from Firestore.");
        });
      }
    } catch (e) {
      print("❌ Error fetching course data: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _saveCourseEdits() async {
    if (!_validateInputs()) return;
    setState(() {
      isLoading = true;
    });

    try {
      final storage = FirebaseStorage.instance;
      final firestore = FirebaseFirestore.instance;
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('No user logged in');
      }

      // Track changes
      List<String> changeList = [];

      // Get existing course data first
      Map<String, dynamic>? existingData;
      if (widget.courseId != null) {
        DocumentSnapshot existingDoc =
            await firestore.collection('courses').doc(widget.courseId).get();
        if (existingDoc.exists) {
          existingData = existingDoc.data() as Map<String, dynamic>;
        }
      }

      // Handle course image upload
      String? newImageUrl = _selectedImageUrl;
      if (_selectedImage != null) {
        final ref = storage
            .ref()
            .child('courses/${DateTime.now().millisecondsSinceEpoch}.png');
        final uploadTask = ref.putData(_selectedImage!);
        final snapshot = await uploadTask;
        newImageUrl = await snapshot.ref.getDownloadURL();
        changeList.add("Updated Course Image");
      } else if (existingData != null &&
          existingData['courseImageUrl'] != null) {
        newImageUrl = existingData['courseImageUrl'];
      }

      // Helper function to handle PDF upload (similar to module implementation)
      Future<Map<String, String?>> uploadPdf(Uint8List? pdfData,
          String? existingUrl, String? existingName, String fileName) async {
        if (pdfData == null) {
          print(
              'uploadPdf: No new PDF data, keeping existing URL: $existingUrl');
          return {
            'url': existingUrl,
            'name': existingName
          }; // Keep existing data
        }

        print('uploadPdf: Starting upload of new PDF');
        // Use the original file name if available, otherwise use the default name
        String actualFileName = _selectedPreviewPdfName ?? '$fileName.pdf';
        print('uploadPdf: Using filename: $actualFileName');

        final ref = storage.ref().child(
            'course_previews/${DateTime.now().millisecondsSinceEpoch}_$actualFileName');
        print('uploadPdf: Storage reference path: ${ref.fullPath}');

        final uploadTask = ref.putData(pdfData);
        final snapshot = await uploadTask;
        final url = await snapshot.ref.getDownloadURL();
        print('uploadPdf: Upload complete. New URL: $url');

        return {'url': url, 'name': actualFileName};
      }

      // Handle preview PDF upload using the helper function
      Map<String, String?> pdfData = await uploadPdf(_selectedPreviewPdf,
          _selectedPreviewPdfUrl, _selectedPreviewPdfName, 'preview');

      String? previewPdfUrl = pdfData['url'];
      String? previewPdfName = pdfData['name'];

      // Track PDF changes
      if (_selectedPreviewPdf != null) {
        changeList.add("Updated Preview PDF");
      }

      // Compare changes for existing course
      if (existingData != null) {
        if (_courseNameController.text != existingData['courseName']) {
          changeList.add("Updated Course Name: ${_courseNameController.text}");
        }
        if (_coursePriceController.text != existingData['coursePrice']) {
          changeList
              .add("Updated Course Price: ${_coursePriceController.text}");
        }
        if (_courseCategoryController.text != existingData['courseCategory']) {
          changeList.add(
              "Updated Course Category: ${_courseCategoryController.text}");
        }
        if (_courseDescriptionController.text !=
            existingData['courseDescription']) {
          changeList.add("Updated Course Description");
        }
      }

      // Prepare course data
      final Map<String, dynamic> courseData = {
        'courseName': _courseNameController.text,
        'coursePrice': _coursePriceController.text,
        'courseCategory': _courseCategoryController.text,
        'courseDescription': _courseDescriptionController.text,
        'courseImageUrl': newImageUrl,
        'createdBy': user.uid,
      };

      // Only add preview PDF fields if we have data
      if (previewPdfUrl != null) {
        courseData['previewPdfUrl'] = previewPdfUrl;
        courseData['previewPdfName'] = previewPdfName;
      }

      if (widget.courseId == null) {
        // New course
        courseData['status'] = 'pending_approval';
        courseData['createdAt'] = FieldValue.serverTimestamp();
        await firestore.collection('courses').doc().set(courseData);
        print("✅ New course created successfully");
      } else {
        // Edit existing course
        courseData['status'] = 'pending';
        courseData['editedAt'] = FieldValue.serverTimestamp();
        courseData['changes'] = changeList;

        // For edits, save to pendingCourses
        await firestore
            .collection('pendingCourses')
            .doc(widget.courseId)
            .set(courseData);
        print("✅ Course edit submitted for review with changes: $changeList");
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(widget.courseId == null
                ? 'Course created successfully!'
                : 'Edit submitted for review!')),
      );
    } catch (e) {
      print("❌ Error saving course: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save course: ${e.toString()}')),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _flagCourseForReview() async {
    final firebaseStorage = FirebaseFirestore.instance;
    DocumentReference pendingCourseRef =
        firebaseStorage.collection('pendingCourses').doc(widget.courseId);

    DocumentSnapshot pendingCourseDoc = await pendingCourseRef.get();
    List<String> changeList = [];

    // If pendingCourses exists, get the existing change list
    if (pendingCourseDoc.exists) {
      Map<String, dynamic> pendingData =
          pendingCourseDoc.data() as Map<String, dynamic>;
      changeList = List<String>.from(pendingData['changes'] ?? []);
    }

    // Add a module edit change if not already added
    if (!changeList.contains("Edited Modules")) {
      changeList.add("Edited Modules");
    }

    // Update or create pending course entry
    await pendingCourseRef.set({
      'status': 'pending',
      'editedAt': FieldValue.serverTimestamp(),
      'changes': changeList,
    }, SetOptions(merge: true));

    print("⚠️ Course flagged for review due to module edits.");
  }

  void _loadNetworkImage(String imageUrl) async {
    final response = await html.HttpRequest.request(
      imageUrl,
      responseType: "arraybuffer",
    );

    if (response.response is ByteBuffer) {
      setState(() {
        _selectedImage = Uint8List.view(response.response);
      });
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

  void _pickPreviewPdf() async {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'application/pdf';
    uploadInput.click();

    uploadInput.onChange.listen((e) async {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final file = files[0];
        final reader = html.FileReader();
        reader.readAsArrayBuffer(file);
        reader.onLoadEnd.listen((e) {
          setState(() {
            _selectedPreviewPdf = reader.result as Uint8List;
            _selectedPreviewPdfName = file.name;
          });
        });
      }
    });
  }

  void _clearCourseData() {
    final courseModel = Provider.of<CourseModel>(context, listen: false);

    // 🗑️ Clear stored modules (Prevents old modules from being re-used)
    courseModel.modules.clear();

    // 🗑️ Reset all course fields
    setState(() {
      _courseNameController.clear();
      _coursePriceController.clear();
      _courseCategoryController.clear();
      _courseDescriptionController.clear();
      _selectedImage = null;
      _selectedImageUrl = null;
      _selectedPreviewPdf = null;
      _selectedPreviewPdfUrl = null;
      _selectedPreviewPdfName = null;
    });

    print("🆕 New course initialized, clearing old course data.");
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Mycolors().offWhite,
      child: isLoading
          ? Center(
              child: CircularProgressIndicator(
              color: Mycolors().blue,
            ))
          : SizedBox(
              width: MyUtility(context).width - 280,
              height: MyUtility(context).height - 80,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Modern Header with gradient
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Mycolors().blue, Mycolors().darkTeal],
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
                        child: Center(
                          child: Text(
                            'Create Course',
                            style: MyTextStyles(context).headerWhite.copyWith(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      // Main Content Card
                      Container(
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
                        width: MyUtility(context).width,
                        child: Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Image Upload Section
                                  InkWell(
                                    onTap: _pickImage,
                                    child: Container(
                                      height: MyUtility(context).height * 0.38,
                                      width: MyUtility(context).width * 0.3,
                                      decoration: BoxDecoration(
                                        color: Mycolors().offWhite,
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                          color: Colors.grey.withOpacity(0.3),
                                        ),
                                      ),
                                      child: _selectedImage != null
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              child: Image.memory(
                                                _selectedImage!,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : (_selectedImageUrl != null &&
                                                  _selectedImageUrl!.isNotEmpty)
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  child: ImageNetwork(
                                                    image: _selectedImageUrl!,
                                                    width: MyUtility(context)
                                                            .width *
                                                        0.3,
                                                    height: MyUtility(context)
                                                            .height *
                                                        0.38,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    fitWeb: BoxFitWeb.cover,
                                                    fitAndroidIos: BoxFit.cover,
                                                    onLoading: Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                      color: Mycolors().blue,
                                                    )),
                                                  ),
                                                )
                                              : Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .add_photo_alternate_outlined,
                                                      size: 50,
                                                      color:
                                                          Mycolors().darkGrey,
                                                    ),
                                                    SizedBox(height: 10),
                                                    Text(
                                                      'Click to upload course image',
                                                      style: TextStyle(
                                                        color:
                                                            Mycolors().darkGrey,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                    ),
                                  ),
                                  SizedBox(width: 30),
                                  // Course Details Section
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ContentDevTextfields(
                                          headerText: 'Course Name',
                                          inputController:
                                              _courseNameController,
                                          keyboardType: '',
                                        ),
                                        SizedBox(height: 20),
                                        ContentDevTextfields(
                                          headerText: 'Course Price',
                                          inputController:
                                              _coursePriceController,
                                          keyboardType: 'intType',
                                        ),
                                        SizedBox(height: 20),
                                        ContentDevTextfields(
                                          headerText: 'Course Category',
                                          inputController:
                                              _courseCategoryController,
                                          keyboardType: '',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 30),
                              // Course Description
                              ContentDevTextfields(
                                headerText: 'Course Description',
                                inputController: _courseDescriptionController,
                                keyboardType: '',
                                maxLines: 7,
                              ),
                              SizedBox(height: 30),
                              // Preview PDF and Next Button
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: _pickPreviewPdf,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Mycolors().blue,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    icon: Icon(
                                      _selectedPreviewPdf != null ||
                                              _selectedPreviewPdfUrl != null
                                          ? Icons.check_circle
                                          : Icons.upload_file,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      _selectedPreviewPdf != null ||
                                              _selectedPreviewPdfUrl != null
                                          ? 'Preview PDF Added'
                                          : 'Add Preview PDF',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: _handleNext,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Mycolors().green,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 30, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Next',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward,
                                            color: Colors.white),
                                      ],
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
                ),
              ),
            ),
    );
  }

  bool _validateInputs() {
    if (_courseNameController.text.isEmpty ||
        _coursePriceController.text.isEmpty ||
        _courseCategoryController.text.isEmpty ||
        _courseDescriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields and select an image.')),
      );
      return false;
    }
    return true;
  }

  void _handleNext() async {
    if (_validateInputs()) {
      setState(() {
        isLoading = true;
      });

      try {
        // Update the CourseModel without saving to Firebase
        final courseModel = Provider.of<CourseModel>(context, listen: false);
        courseModel.setCourseName(_courseNameController.text);
        courseModel.setCoursePrice(_coursePriceController.text);
        courseModel.setCourseCategory(_courseCategoryController.text);
        courseModel.setCourseDescription(_courseDescriptionController.text);
        courseModel.setCourseImage(_selectedImage);
        courseModel.setCourseImageUrl(_selectedImageUrl);

        // Update preview PDF data
        if (_selectedPreviewPdf != null) {
          courseModel.setPreviewPdf(
              _selectedPreviewPdf, _selectedPreviewPdfName);
        } else if (_selectedPreviewPdfUrl != null) {
          courseModel.setPreviewPdfUrl(_selectedPreviewPdfUrl);
          if (_selectedPreviewPdfName != null) {
            courseModel.setPreviewPdf(null, _selectedPreviewPdfName);
          }
        }

        // Navigate to next page
        widget.changePageIndex(3, moduleIndex: 0);
      } catch (e) {
        print("❌ Error in _handleNext: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save course: ${e.toString()}')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
