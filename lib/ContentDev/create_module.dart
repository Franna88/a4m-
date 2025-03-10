import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:a4m/CommonComponents/buttons/slimButtons.dart';
import 'package:a4m/CommonComponents/inputFields/contentDevTextfields.dart';
import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:a4m/Themes/text_style.dart';
import 'package:a4m/myutility.dart';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:a4m/ContentDev/ModuleAssessments/CourseModel.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateModule extends StatefulWidget {
  final Function(int, {int? moduleIndex}) changePageIndex;
  final int? moduleIndex;
  final String? courseId;

  CreateModule(
      {super.key,
      required this.changePageIndex,
      this.moduleIndex,
      required this.courseId});

  @override
  State<CreateModule> createState() => _CreateModuleState();
}

class _CreateModuleState extends State<CreateModule> {
  late TextEditingController _moduleNameController;
  late TextEditingController _moduleDescriptionController;
  Uint8List? _selectedImage;
  Uint8List? _selectedPdf;
  String? _selectedPdfName;
  int? _currentModuleIndex;

  // New variables for additional PDF uploads
  Uint8List? _studentGuidePdf;
  String? _studentGuidePdfName;
  Uint8List? _facilitatorGuidePdf;
  String? _facilitatorGuidePdfName;
  Uint8List? _answerSheetPdf;
  String? _answerSheetPdfName;
  Uint8List? _activitiesPdf;
  String? _activitiesPdfName;
  Uint8List? _assessmentsPdf;
  String? _assessmentsPdfName;
  Uint8List? _testSheetPdf;
  String? _testSheetPdfName;

  bool _isLoading = false;
  bool _isSubmittedForReview = false;

  @override
  void initState() {
    super.initState();
    _moduleNameController = TextEditingController();
    _moduleDescriptionController = TextEditingController();

    // Load module data if moduleIndex is provided
    if (widget.moduleIndex != null) {
      _currentModuleIndex = widget.moduleIndex;
    } else {
      _currentModuleIndex = 0;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadModuleData();
  }

  @override
  void didUpdateWidget(covariant CreateModule oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.moduleIndex != oldWidget.moduleIndex) {
      _currentModuleIndex = widget.moduleIndex;
      _loadModuleData();
    }
  }

  @override
  void dispose() {
    _moduleNameController.dispose();
    _moduleDescriptionController.dispose();
    super.dispose();
  }

  void _loadModuleData() async {
    final courseModel = Provider.of<CourseModel>(context, listen: false);

    if (_currentModuleIndex != null &&
        _currentModuleIndex! < courseModel.modules.length) {
      final existingModule = courseModel.modules[_currentModuleIndex!];

      setState(() {
        _moduleNameController.text = existingModule.moduleName;
        _moduleDescriptionController.text = existingModule.moduleDescription;
        _selectedImage = existingModule.moduleImage;
        _selectedPdf = existingModule.modulePdf;
        _selectedPdfName = existingModule.modulePdfName;

        // Load additional PDFs for editing
        _studentGuidePdf = existingModule.studentGuidePdf;
        _studentGuidePdfName = existingModule.studentGuidePdfName;
        _facilitatorGuidePdf = existingModule.facilitatorGuidePdf;
        _facilitatorGuidePdfName = existingModule.facilitatorGuidePdfName;
        _answerSheetPdf = existingModule.answerSheetPdf;
        _answerSheetPdfName = existingModule.answerSheetPdfName;
        _activitiesPdf = existingModule.activitiesPdf;
        _activitiesPdfName = existingModule.activitiesPdfName;
        _assessmentsPdf = existingModule.assessmentsPdf;
        _assessmentsPdfName = existingModule.assessmentsPdfName;
        _testSheetPdf = existingModule.testSheetPdf;
        _testSheetPdfName = existingModule.testSheetPdfName;
      });

      print(
          "📝 Editing module: ${existingModule.moduleName} (Index: $_currentModuleIndex)");
    }
    // 🔥 **Fetch from Firestore if editing an existing course**
    else if (widget.courseId != null) {
      print("📡 Fetching modules for Course ID: ${widget.courseId}");

      try {
        QuerySnapshot moduleDocs = await FirebaseFirestore.instance
            .collection('courses')
            .doc(widget.courseId)
            .collection('modules')
            .get();

        if (moduleDocs.docs.isEmpty) {
          print("⚠️ No modules found for this course.");
          return;
        }

        List<Module> fetchedModules = moduleDocs.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Module(
            moduleName: data['moduleName'] ?? '',
            moduleDescription: data['moduleDescription'] ?? '',
            modulePdfName: data['modulePdfName'],
            modulePdf: null, // Firestore stores PDFs as URLs, not raw data
            studentGuidePdfName: data['studentGuidePdfName'],
            facilitatorGuidePdfName: data['facilitatorGuidePdfName'],
            answerSheetPdfName: data['answerSheetPdfName'],
            activitiesPdfName: data['activitiesPdfName'],
            assessmentsPdfName: data['assessmentsPdfName'],
            testSheetPdfName: data['testSheetPdfName'],
          );
        }).toList();

        // 🔄 **Sync with `CourseModel` only if empty**
        if (courseModel.modules.isEmpty) {
          courseModel.modules = fetchedModules;
        }

        setState(() {
          _currentModuleIndex = 0; // Ensure index is within bounds
          _moduleNameController.text = fetchedModules[0].moduleName;
          _moduleDescriptionController.text =
              fetchedModules[0].moduleDescription;
          _selectedPdfName = fetchedModules[0].modulePdfName;

          // Load additional PDFs
          _studentGuidePdfName = fetchedModules[0].studentGuidePdfName;
          _facilitatorGuidePdfName = fetchedModules[0].facilitatorGuidePdfName;
          _answerSheetPdfName = fetchedModules[0].answerSheetPdfName;
          _activitiesPdfName = fetchedModules[0].activitiesPdfName;
          _assessmentsPdfName = fetchedModules[0].assessmentsPdfName;
          _testSheetPdfName = fetchedModules[0].testSheetPdfName;
        });

        print(
            "✅ Loaded modules from Firestore. Current Module: ${fetchedModules[0].moduleName}");
      } catch (e) {
        print("❌ Error fetching module data: $e");
      }
    } else {
      _clearInputs();
      print("🆕 Creating a new module.");
    }
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

  void _pickPdf(String pdfType) async {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'application/pdf';
    uploadInput.click();
    uploadInput.onChange.listen((e) async {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(files[0]);
        reader.onLoadEnd.listen((e) {
          setState(() {
            final pdfData = reader.result as Uint8List;
            final pdfName = files[0].name;

            switch (pdfType) {
              case 'Student Guide':
                _studentGuidePdf = pdfData;
                _studentGuidePdfName = pdfName;
                break;
              case 'Facilitator Guide':
                _facilitatorGuidePdf = pdfData;
                _facilitatorGuidePdfName = pdfName;
                break;
              case 'Answer Sheet':
                _answerSheetPdf = pdfData;
                _answerSheetPdfName = pdfName;
                break;
              case 'Activities':
                _activitiesPdf = pdfData;
                _activitiesPdfName = pdfName;
                break;
              case 'Assessments':
                _assessmentsPdf = pdfData;
                _assessmentsPdfName = pdfName;
                break;
              case 'Test Sheet':
                _testSheetPdf = pdfData;
                _testSheetPdfName = pdfName;
                break;
              case 'Module PDF':
                _selectedPdf = pdfData;
                _selectedPdfName = pdfName;
                break;
            }
          });
        });
      }
    });
  }

  void _setModule() {
    if (_validateInputs()) {
      final courseModel = Provider.of<CourseModel>(context, listen: false);

      if (_currentModuleIndex != null &&
          _currentModuleIndex! < courseModel.modules.length) {
        // ✅ Update existing module (Editing Mode)
        final existingModule = courseModel.modules[_currentModuleIndex!];
        existingModule.moduleName = _moduleNameController.text;
        existingModule.moduleDescription = _moduleDescriptionController.text;
        existingModule.moduleImage = _selectedImage;
        existingModule.modulePdf = _selectedPdf;
        existingModule.modulePdfName = _selectedPdfName;

        // Set additional PDFs for the existing module
        existingModule.studentGuidePdf = _studentGuidePdf;
        existingModule.studentGuidePdfName = _studentGuidePdfName;
        existingModule.facilitatorGuidePdf = _facilitatorGuidePdf;
        existingModule.facilitatorGuidePdfName = _facilitatorGuidePdfName;
        existingModule.answerSheetPdf = _answerSheetPdf;
        existingModule.answerSheetPdfName = _answerSheetPdfName;
        existingModule.activitiesPdf = _activitiesPdf;
        existingModule.activitiesPdfName = _activitiesPdfName;
        existingModule.assessmentsPdf = _assessmentsPdf;
        existingModule.assessmentsPdfName = _assessmentsPdfName;
        existingModule.testSheetPdf = _testSheetPdf;
        existingModule.testSheetPdfName = _testSheetPdfName;

        courseModel.updateModule(_currentModuleIndex!, existingModule);
        print("✅ Module updated at index: $_currentModuleIndex");
      } else {
        // ✅ Create new module (Creation Mode)
        final newModule = Module(
          moduleName: _moduleNameController.text,
          moduleDescription: _moduleDescriptionController.text,
          moduleImage: _selectedImage,
          modulePdf: _selectedPdf,
          modulePdfName: _selectedPdfName,
          studentGuidePdf: _studentGuidePdf,
          studentGuidePdfName: _studentGuidePdfName,
          facilitatorGuidePdf: _facilitatorGuidePdf,
          facilitatorGuidePdfName: _facilitatorGuidePdfName,
          answerSheetPdf: _answerSheetPdf,
          answerSheetPdfName: _answerSheetPdfName,
          activitiesPdf: _activitiesPdf,
          activitiesPdfName: _activitiesPdfName,
          assessmentsPdf: _assessmentsPdf,
          assessmentsPdfName: _assessmentsPdfName,
          testSheetPdf: _testSheetPdf,
          testSheetPdfName: _testSheetPdfName,
        );

        courseModel.addModule(newModule);

        setState(() {
          _currentModuleIndex = courseModel.modules.length -
              1; // ✅ Keep the last added module displayed
        });

        print(
            "🆕 New module added: ${newModule.moduleName} (Index: $_currentModuleIndex)");
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Module saved successfully!')),
      );
    }
  }

  void _clearInputs() {
    setState(() {
      _moduleNameController.clear();
      _moduleDescriptionController.clear();
      _selectedImage = null;
      _selectedPdf = null;
      _selectedPdfName = null;

      // Clear additional PDF inputs
      _studentGuidePdf = null;
      _studentGuidePdfName = null;
      _facilitatorGuidePdf = null;
      _facilitatorGuidePdfName = null;
      _answerSheetPdf = null;
      _answerSheetPdfName = null;
      _activitiesPdf = null;
      _activitiesPdfName = null;
      _assessmentsPdf = null;
      _assessmentsPdfName = null;
      _testSheetPdf = null;
      _testSheetPdfName = null;
    });
  }

  bool _validateInputs() {
    if (_moduleNameController.text.isEmpty ||
        _moduleDescriptionController.text.isEmpty ||
        _selectedImage == null ||
        _selectedPdf == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Please fill all fields, select an image, and upload a PDF.')),
      );
      return false;
    }
    return true;
  }

  Future<void> _saveToFirebase() async {
    if (!_validateInputs()) {
      return;
    }

    if (_isSubmittedForReview) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Module has already been submitted for review.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final courseModel = Provider.of<CourseModel>(context, listen: false);
      final firebase_storage.FirebaseStorage storage =
          firebase_storage.FirebaseStorage.instance;
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      // Upload the course image to Firebase Storage
      String? courseImageUrl;
      if (courseModel.courseImage != null) {
        firebase_storage.Reference ref = storage
            .ref()
            .child('courses/${DateTime.now().millisecondsSinceEpoch}.png');
        firebase_storage.UploadTask uploadTask =
            ref.putData(courseModel.courseImage!);
        firebase_storage.TaskSnapshot snapshot = await uploadTask;
        courseImageUrl = await snapshot.ref.getDownloadURL();
      }

      // Prepare data for Firestore
      final courseData = {
        'courseName': courseModel.courseName,
        'coursePrice': courseModel.coursePrice,
        'courseCategory': courseModel.courseCategory,
        'courseDescription': courseModel.courseDescription,
        'courseImageUrl': courseImageUrl,
        'createdBy': user.uid,
        'status': 'pending_approval', // Approval status
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Add the course document to Firestore
      DocumentReference courseRef = await FirebaseFirestore.instance
          .collection('courses')
          .add(courseData);

      // Upload modules to a subcollection under the course document
      for (var module in courseModel.modules) {
        // Upload module image
        String? moduleImageUrl;
        if (module.moduleImage != null) {
          firebase_storage.Reference ref = storage.ref().child(
              'modules/${DateTime.now().millisecondsSinceEpoch}_module.png');
          firebase_storage.UploadTask uploadTask =
              ref.putData(module.moduleImage!);
          firebase_storage.TaskSnapshot snapshot = await uploadTask;
          moduleImageUrl = await snapshot.ref.getDownloadURL();
        }

        // Upload module PDF
        String? modulePdfUrl;
        if (module.modulePdf != null) {
          firebase_storage.Reference ref = storage.ref().child(
              'modules/${DateTime.now().millisecondsSinceEpoch}_module.pdf');
          firebase_storage.UploadTask uploadTask =
              ref.putData(module.modulePdf!);
          firebase_storage.TaskSnapshot snapshot = await uploadTask;
          modulePdfUrl = await snapshot.ref.getDownloadURL();
        }

        // Upload additional PDFs for each module
        Future<String?> uploadPdf(Uint8List? pdfData, String fileName) async {
          if (pdfData == null) return null;
          firebase_storage.Reference ref = storage.ref().child(
              'pdfs/${DateTime.now().millisecondsSinceEpoch}_$fileName.pdf');
          firebase_storage.UploadTask uploadTask = ref.putData(pdfData);
          firebase_storage.TaskSnapshot snapshot = await uploadTask;
          return await snapshot.ref.getDownloadURL();
        }

        String? studentGuidePdfUrl =
            await uploadPdf(module.studentGuidePdf, 'student_guide');
        String? facilitatorGuidePdfUrl =
            await uploadPdf(module.facilitatorGuidePdf, 'facilitator_guide');
        String? answerSheetPdfUrl =
            await uploadPdf(module.answerSheetPdf, 'answer_sheet');
        String? activitiesPdfUrl =
            await uploadPdf(module.activitiesPdf, 'activities');
        String? assessmentsPdfUrl =
            await uploadPdf(module.assessmentsPdf, 'assessments');
        String? testSheetPdfUrl =
            await uploadPdf(module.testSheetPdf, 'test_sheet');

        // Prepare module data with additional PDFs
        final moduleData = {
          'moduleName': module.moduleName,
          'moduleDescription': module.moduleDescription,
          'moduleImageUrl': moduleImageUrl,
          'modulePdfUrl': modulePdfUrl,
          'modulePdfName': module.modulePdfName,
          'studentGuidePdfUrl': studentGuidePdfUrl,
          'facilitatorGuidePdfUrl': facilitatorGuidePdfUrl,
          'answerSheetPdfUrl': answerSheetPdfUrl,
          'activitiesPdfUrl': activitiesPdfUrl,
          'assessmentsPdfUrl': assessmentsPdfUrl,
          'testSheetPdfUrl': testSheetPdfUrl,
          'questions': module.questions.map((q) => q.toMap()).toList(),
          'tasks': module.tasks.map((t) => t.toMap()).toList(),
          'assignments': module.assignments.map((a) => a.toMap()).toList(),
        };

        await courseRef.collection('modules').add(moduleData);
      }

      _isSubmittedForReview = true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Module submitted for review!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload data: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToNextModule() {
    final courseModel = Provider.of<CourseModel>(context, listen: false);
    if (_currentModuleIndex != null &&
        _currentModuleIndex! < courseModel.modules.length - 1) {
      setState(() {
        _currentModuleIndex = _currentModuleIndex! + 1;
        _loadModuleData();
      });
    }
  }

  void _navigateToPreviousModule() {
    if (_currentModuleIndex != null && _currentModuleIndex! > 0) {
      setState(() {
        _currentModuleIndex = _currentModuleIndex! - 1;
        _loadModuleData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseModel = Provider.of<CourseModel>(context);
    final currentIndex =
        _currentModuleIndex != null && courseModel.modules.isNotEmpty
            ? _currentModuleIndex! + 1
            : 0;
    final totalModules = courseModel.modules.length;

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
                              buttonText: 'Save Module',
                              textColor: Mycolors().darkGrey,
                              buttonColor: Colors.white,
                              borderColor: Mycolors().darkGrey,
                              onPressed: _setModule,
                              customWidth: 125,
                              customHeight: 40,
                            ),
                            SizedBox(width: 30),
                            // SlimButtons(
//                              buttonText: 'Assessments',
//                              textColor: Mycolors().darkGrey,
//                              buttonColor: Colors.white,
//                              borderColor: Mycolors().darkGrey,
//                              onPressed: () {
//                                if (_currentModuleIndex != null) {
//                                  print(
//                                      'Navigating to assessments for module index: $_currentModuleIndex');
//                                  widget.changePageIndex(5,
//                                      moduleIndex: _currentModuleIndex);
//                                } else {
//                                  ScaffoldMessenger.of(context).showSnackBar(
//                                    SnackBar(
//                                        content: Text(
//                                            'Please set a module before adding assessments.')),
//                                  );
//                                }
//                              },
//                              customWidth: 125,
//                              customHeight: 40,
//                            ),
                            SizedBox(width: 30),
                            SlimButtons(
                              buttonText: 'Add New Module',
                              textColor: Mycolors().darkGrey,
                              buttonColor: Colors.white,
                              borderColor: Mycolors().darkGrey,
                              onPressed: () {
                                _clearInputs();
                                setState(() {
                                  _currentModuleIndex =
                                      courseModel.modules.length;
                                });
                                courseModel.addModule(Module(
                                  moduleName: '',
                                  moduleDescription: '',
                                ));
                              },
                              customWidth: 150,
                              customHeight: 40,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: _pickImage,
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.3,
                              width: MediaQuery.of(context).size.width * 0.3,
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
                          Column(
                            children: [
                              // Student Guide PDF Button
                              SlimButtons(
                                buttonText: 'Upload Student Guide',
                                buttonColor: _studentGuidePdf != null
                                    ? Mycolors().green
                                    : Colors.white,
                                borderColor: _studentGuidePdf != null
                                    ? Mycolors().green
                                    : Mycolors().darkGrey,
                                textColor: _studentGuidePdf != null
                                    ? Colors.white
                                    : Mycolors().darkGrey,
                                onPressed: () => _pickPdf('Student Guide'),
                                customWidth: 180,
                                customHeight: 40,
                              ),
                              SizedBox(height: 10),

                              // Facilitator Guide PDF Button
                              SlimButtons(
                                buttonText: 'Upload Facilitator Guide',
                                buttonColor: _facilitatorGuidePdf != null
                                    ? Mycolors().green
                                    : Colors.white,
                                borderColor: _facilitatorGuidePdf != null
                                    ? Mycolors().green
                                    : Mycolors().darkGrey,
                                textColor: _facilitatorGuidePdf != null
                                    ? Colors.white
                                    : Mycolors().darkGrey,
                                onPressed: () => _pickPdf('Facilitator Guide'),
                                customWidth: 180,
                                customHeight: 40,
                              ),
                              SizedBox(height: 10),

                              // Answer Sheet PDF Button
                              SlimButtons(
                                buttonText: 'Upload Answer Sheet',
                                buttonColor: _answerSheetPdf != null
                                    ? Mycolors().green
                                    : Colors.white,
                                borderColor: _answerSheetPdf != null
                                    ? Mycolors().green
                                    : Mycolors().darkGrey,
                                textColor: _answerSheetPdf != null
                                    ? Colors.white
                                    : Mycolors().darkGrey,
                                onPressed: () => _pickPdf('Answer Sheet'),
                                customWidth: 180,
                                customHeight: 40,
                              ),
                              SizedBox(height: 10),

                              // Activities PDF Button
                              SlimButtons(
                                buttonText: 'Upload Activities',
                                buttonColor: _activitiesPdf != null
                                    ? Mycolors().green
                                    : Colors.white,
                                borderColor: _activitiesPdf != null
                                    ? Mycolors().green
                                    : Mycolors().darkGrey,
                                textColor: _activitiesPdf != null
                                    ? Colors.white
                                    : Mycolors().darkGrey,
                                onPressed: () => _pickPdf('Activities'),
                                customWidth: 180,
                                customHeight: 40,
                              ),
                              SizedBox(height: 10),

                              // Assessments PDF Button
                              SlimButtons(
                                buttonText: 'Upload Assessments',
                                buttonColor: _assessmentsPdf != null
                                    ? Mycolors().green
                                    : Colors.white,
                                borderColor: _assessmentsPdf != null
                                    ? Mycolors().green
                                    : Mycolors().darkGrey,
                                textColor: _assessmentsPdf != null
                                    ? Colors.white
                                    : Mycolors().darkGrey,
                                onPressed: () => _pickPdf('Assessments'),
                                customWidth: 180,
                                customHeight: 40,
                              ),
                              SizedBox(height: 10),

                              // Test Sheet PDF Button
                              SlimButtons(
                                buttonText: 'Upload Test Sheet',
                                buttonColor: _testSheetPdf != null
                                    ? Mycolors().green
                                    : Colors.white,
                                borderColor: _testSheetPdf != null
                                    ? Mycolors().green
                                    : Mycolors().darkGrey,
                                textColor: _testSheetPdf != null
                                    ? Colors.white
                                    : Mycolors().darkGrey,
                                onPressed: () => _pickPdf('Test Sheet'),
                                customWidth: 180,
                                customHeight: 40,
                              ),
                            ],
                          ),
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
                        buttonText: 'Add Content (PDF)',
                        buttonColor: Colors.white,
                        borderColor: Mycolors().darkGrey,
                        textColor: Mycolors().darkGrey,
                        onPressed: () => _pickPdf('Module PDF'),
                        customWidth: 150,
                        customHeight: 40,
                      ),
                      if (_selectedPdfName != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.picture_as_pdf,
                                color: Mycolors().darkTeal,
                                size: 30,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Selected PDF: $_selectedPdfName',
                                style: MyTextStyles(context).mediumBlack,
                              ),
                              Spacer(),
                              TextButton(
                                onPressed: () {
                                  final blob = html.Blob([_selectedPdf!]);
                                  final url =
                                      html.Url.createObjectUrlFromBlob(blob);
                                  final anchor = html.AnchorElement(href: url)
                                    ..setAttribute(
                                        "download",
                                        _selectedPdfName ??
                                            'module_content.pdf')
                                    ..click();
                                  html.Url.revokeObjectUrl(url);
                                },
                                child: Text('Download/View PDF'),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SlimButtons(
                            buttonText: 'Previous Module',
                            buttonColor: Colors.white,
                            borderColor: Mycolors().darkGrey,
                            textColor: Mycolors().darkGrey,
                            onPressed: _navigateToPreviousModule,
                            customWidth: 150,
                            customHeight: 40,
                          ),
                          Text(
                            '$currentIndex / $totalModules',
                            style: MyTextStyles(context).mediumBlack,
                          ),
                          SlimButtons(
                            buttonText: 'Next Module',
                            buttonColor: Colors.white,
                            borderColor: Mycolors().darkGrey,
                            textColor: Mycolors().darkGrey,
                            onPressed: _navigateToNextModule,
                            customWidth: 150,
                            customHeight: 40,
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      SlimButtons(
                        buttonText: 'Submit for review',
                        buttonColor: Mycolors().green,
                        borderColor: Mycolors().green,
                        textColor: Colors.white,
                        onPressed: _saveToFirebase,
                        customWidth: 180,
                        customHeight: 50,
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
