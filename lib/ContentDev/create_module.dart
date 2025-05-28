import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';
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

  const CreateModule(
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
  Uint8List? _assignmentsPdf;
  String? _assignmentsPdfName;
  Uint8List? _indexPdf;
  String? _indexPdfName;
  Uint8List? _lecturerGuidePdf;
  String? _lecturerGuidePdfName;
  String? _lecturerGuidePdfUrl;

  String? _selectedImageUrl;

  String? _selectedPdfUrl;

  String? _studentGuidePdfUrl;

  String? _facilitatorGuidePdfUrl;

  String? _answerSheetPdfUrl;

  String? _activitiesPdfUrl;

  String? _assessmentsPdfUrl;

  String? _testSheetPdfUrl;

  String? _assignmentsPdfUrl;

  String? _indexPdfUrl;

  bool _isLoading = false;
  final bool _isSubmittedForReview = false;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

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

      // When first creating a module, get the course image immediately
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final courseModel = Provider.of<CourseModel>(context, listen: false);

        // First check for course image in memory
        if (courseModel.courseImage != null) {
          // Create a blob URL from the in-memory course image for display
          final blob = html.Blob([courseModel.courseImage!]);
          final url = html.Url.createObjectUrlFromBlob(blob);

          setState(() {
            _selectedImageUrl = url;
          });
          print("Using in-memory course image for new module");
        }
        // Then check for URL
        else if (courseModel.courseImageUrl != null &&
            courseModel.courseImageUrl!.isNotEmpty) {
          setState(() {
            _selectedImageUrl = courseModel.courseImageUrl;
          });
          print(
              "Using course image URL for new module: ${courseModel.courseImageUrl}");
        }
      });
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

    // If modules have already been loaded, simply use the current module index.
    if (courseModel.modules.isNotEmpty &&
        _currentModuleIndex != null &&
        _currentModuleIndex! < courseModel.modules.length) {
      final existingModule = courseModel.modules[_currentModuleIndex!];
      setState(() {
        _moduleNameController.text = existingModule.moduleName;
        _moduleDescriptionController.text = existingModule.moduleDescription;

        // First check if the module has its own image URL
        if (existingModule.moduleImageUrl != null &&
            existingModule.moduleImageUrl!.isNotEmpty) {
          _selectedImageUrl = existingModule.moduleImageUrl;
        } else {
          // If not, use the course image as fallback
          _selectedImageUrl = courseModel.courseImageUrl;
        }

        _selectedPdfUrl = existingModule.modulePdfUrl;

        _studentGuidePdfUrl = existingModule.studentGuidePdfUrl;
        _facilitatorGuidePdfUrl = existingModule.facilitatorGuidePdfUrl;
        _answerSheetPdfUrl = existingModule.answerSheetPdfUrl;
        _activitiesPdfUrl = existingModule.activitiesPdfUrl;
        _assessmentsPdfUrl = existingModule.assessmentsPdfUrl;
        _testSheetPdfUrl = existingModule.testSheetPdfUrl;
        _assignmentsPdfUrl = existingModule.assignmentsPdfUrl;
        _indexPdfUrl = existingModule.indexPdfUrl;

        _selectedPdfName = existingModule.modulePdfName ?? "Existing PDF";
        _studentGuidePdfName =
            existingModule.studentGuidePdfName ?? "Existing Student Guide";
        _facilitatorGuidePdfName = existingModule.facilitatorGuidePdfName ??
            "Existing Facilitator Guide";
        _answerSheetPdfName =
            existingModule.answerSheetPdfName ?? "Existing Answer Sheet";
        _activitiesPdfName =
            existingModule.activitiesPdfName ?? "Existing Activities";
        _assessmentsPdfName =
            existingModule.assessmentsPdfName ?? "Existing Assessments";
        _testSheetPdfName =
            existingModule.testSheetPdfName ?? "Existing Test Sheet";
        _assignmentsPdfName =
            existingModule.assignmentsPdfName ?? "Existing Assignments";
        _indexPdfName = existingModule.indexPdfName ?? "Existing Index PDF";

        _lecturerGuidePdfUrl = existingModule.lecturerGuidePdfUrl;
        _lecturerGuidePdfName =
            existingModule.lecturerGuidePdfName ?? 'Existing Lecturer Guide';

        // Clear the local image so that the widget uses the URL image for the current module
        _selectedImage = null;
      });
      print(
          "✅ Loaded module: ${existingModule.moduleName} (Index: $_currentModuleIndex)");
    }
    // If the modules list is empty and courseId is provided, fetch the modules.
    else if (widget.courseId != null) {
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
            id: doc.id,
            moduleName: data['moduleName'] ?? '',
            moduleDescription: data['moduleDescription'] ?? '',
            modulePdfUrl: data['modulePdfUrl'],
            moduleImageUrl:
                data['moduleImageUrl'] ?? courseModel.courseImageUrl,
            studentGuidePdfUrl: data['studentGuidePdfUrl'],
            facilitatorGuidePdfUrl: data['facilitatorGuidePdfUrl'],
            answerSheetPdfUrl: data['answerSheetPdfUrl'],
            activitiesPdfUrl: data['activitiesPdfUrl'],
            assessmentsPdfUrl: data['assessmentsPdfUrl'],
            testSheetPdfUrl: data['testSheetPdfUrl'],
            assignmentsPdfUrl: data['assignmentsPdfUrl'],
            modulePdfName: data['modulePdfName'],
            studentGuidePdfName: data['studentGuidePdfName'],
            facilitatorGuidePdfName: data['facilitatorGuidePdfName'],
            answerSheetPdfName: data['answerSheetPdfName'],
            activitiesPdfName: data['activitiesPdfName'],
            assessmentsPdfName: data['assessmentsPdfName'],
            testSheetPdfName: data['testSheetPdfName'],
            assignmentsPdfName: data['assignmentsPdfName'],
            indexPdfUrl: data['indexPdfUrl'],
            indexPdfName: data['indexPdfName'],
            lecturerGuidePdfUrl: data['lecturerGuidePdfUrl'],
            lecturerGuidePdfName: data['lecturerGuidePdfName'],
          );
        }).toList();

        // Update CourseModel only if it's empty.
        if (courseModel.modules.isEmpty) {
          courseModel.modules = fetchedModules;
        }

        // Only reset _currentModuleIndex to 0 if it's null or out-of-bounds.
        if (_currentModuleIndex == null ||
            _currentModuleIndex! >= fetchedModules.length) {
          _currentModuleIndex = 0;
        }

        setState(() {
          _moduleNameController.text =
              courseModel.modules[_currentModuleIndex!].moduleName;
          _moduleDescriptionController.text =
              courseModel.modules[_currentModuleIndex!].moduleDescription;

          // First check if the module has its own image URL
          if (courseModel.modules[_currentModuleIndex!].moduleImageUrl !=
                  null &&
              courseModel
                  .modules[_currentModuleIndex!].moduleImageUrl!.isNotEmpty) {
            _selectedImageUrl =
                courseModel.modules[_currentModuleIndex!].moduleImageUrl;
          } else {
            // If not, use the course image as fallback
            _selectedImageUrl = courseModel.courseImageUrl;
          }

          _selectedPdfUrl =
              courseModel.modules[_currentModuleIndex!].modulePdfUrl;

          _studentGuidePdfUrl =
              courseModel.modules[_currentModuleIndex!].studentGuidePdfUrl;
          _facilitatorGuidePdfUrl =
              courseModel.modules[_currentModuleIndex!].facilitatorGuidePdfUrl;
          _answerSheetPdfUrl =
              courseModel.modules[_currentModuleIndex!].answerSheetPdfUrl;
          _activitiesPdfUrl =
              courseModel.modules[_currentModuleIndex!].activitiesPdfUrl;
          _assessmentsPdfUrl =
              courseModel.modules[_currentModuleIndex!].assessmentsPdfUrl;
          _testSheetPdfUrl =
              courseModel.modules[_currentModuleIndex!].testSheetPdfUrl;
          _assignmentsPdfUrl =
              courseModel.modules[_currentModuleIndex!].assignmentsPdfUrl;
          _indexPdfUrl = courseModel.modules[_currentModuleIndex!].indexPdfUrl;

          _selectedPdfName =
              courseModel.modules[_currentModuleIndex!].modulePdfName;
          _studentGuidePdfName =
              courseModel.modules[_currentModuleIndex!].studentGuidePdfName;
          _facilitatorGuidePdfName =
              courseModel.modules[_currentModuleIndex!].facilitatorGuidePdfName;
          _answerSheetPdfName =
              courseModel.modules[_currentModuleIndex!].answerSheetPdfName;
          _activitiesPdfName =
              courseModel.modules[_currentModuleIndex!].activitiesPdfName;
          _assessmentsPdfName =
              courseModel.modules[_currentModuleIndex!].assessmentsPdfName;
          _testSheetPdfName =
              courseModel.modules[_currentModuleIndex!].testSheetPdfName;
          _assignmentsPdfName =
              courseModel.modules[_currentModuleIndex!].assignmentsPdfName;
          _indexPdfName =
              courseModel.modules[_currentModuleIndex!].indexPdfName;

          _lecturerGuidePdfUrl =
              courseModel.modules[_currentModuleIndex!].lecturerGuidePdfUrl;
          _lecturerGuidePdfName =
              courseModel.modules[_currentModuleIndex!].lecturerGuidePdfName ??
                  'Existing Lecturer Guide';

          // Clear the local image state here as well
          _selectedImage = null;
        });
        print(
            "✅ Loaded modules from Firestore. Current Module: ${courseModel.modules[_currentModuleIndex!].moduleName}");
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
    uploadInput.onChange.first.then((_) {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(files[0]);
        reader.onLoadEnd.first.then((_) {
          // Create a temporary URL for preview
          final blob = html.Blob([reader.result as Uint8List]);
          final url = html.Url.createObjectUrlFromBlob(blob);
          setState(() {
            _selectedImage = reader.result as Uint8List;
            _selectedImageUrl = url;
          });
          print("New image selected.");
        });
      } else {
        print("No image selected.");
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
          final pdfData = reader.result as Uint8List;
          final pdfName = files[0].name;

          setState(() {
            switch (pdfType) {
              case var t when t.contains('Module PDF'):
                _selectedPdf = pdfData;
                _selectedPdfName = pdfName;
                _selectedPdfUrl = null;
                break;
              case var t when t.contains('Lecturer Guide'):
                _lecturerGuidePdf = pdfData;
                _lecturerGuidePdfName = pdfName;
                _lecturerGuidePdfUrl = null;
                break;
              case var t when t.contains('Student Guide'):
                _studentGuidePdf = pdfData;
                _studentGuidePdfName = pdfName;
                _studentGuidePdfUrl = null;
                break;
              case var t when t.contains('Facilitator Guide'):
                _facilitatorGuidePdf = pdfData;
                _facilitatorGuidePdfName = pdfName;
                _facilitatorGuidePdfUrl = null;
                break;
              case var t when t.contains('Answer Sheet'):
                _answerSheetPdf = pdfData;
                _answerSheetPdfName = pdfName;
                _answerSheetPdfUrl = null;
                break;
              case var t when t.contains('Activities'):
                _activitiesPdf = pdfData;
                _activitiesPdfName = pdfName;
                _activitiesPdfUrl = null;
                break;
              case var t when t.contains('Assessments'):
                _assessmentsPdf = pdfData;
                _assessmentsPdfName = pdfName;
                _assessmentsPdfUrl = null;
                break;
              case var t when t.contains('Test'):
                _testSheetPdf = pdfData;
                _testSheetPdfName = pdfName;
                _testSheetPdfUrl = null;
                break;
              case var t when t.contains('Assignments'):
                _assignmentsPdf = pdfData;
                _assignmentsPdfName = pdfName;
                _assignmentsPdfUrl = null;
                break;
              case var t when t.contains('Index PDF'):
                _indexPdf = pdfData;
                _indexPdfName = pdfName;
                _indexPdfUrl = null;
                break;
              default:
                print('Unknown PDF type: $pdfType');
                break;
            }
          });

          // Show feedback to user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$pdfType selected: $pdfName'),
              duration: Duration(seconds: 2),
            ),
          );
        });
      }
    });
  }

  /// Updates or creates a module based on the input fields.
  /// If the `currentModuleIndex` is valid, it updates the existing module.
  /// Otherwise, it creates a new module and adds it to the course.
  /// The method also updates the local state and displays a success message.
  void _setModule() {
    if (_validateInputs()) {
      final courseModel = Provider.of<CourseModel>(context, listen: false);

      if (_currentModuleIndex != null &&
          _currentModuleIndex! < courseModel.modules.length) {
        // Update existing module (Editing Mode)
        final existingModule = courseModel.modules[_currentModuleIndex!];
        existingModule.moduleName = _moduleNameController.text;
        existingModule.moduleDescription = _moduleDescriptionController.text;

        // Only update module image if a new one was selected
        if (_selectedImage != null) {
          existingModule.moduleImage = _selectedImage;
          existingModule.moduleImageUrl = _selectedImageUrl;
        } else if (_selectedImageUrl != null &&
            _selectedImageUrl != courseModel.courseImageUrl) {
          // If we have a specific module image URL that's not the course image, keep it
          existingModule.moduleImageUrl = _selectedImageUrl;
          existingModule.moduleImage = null;
        } else {
          // Otherwise, use the course image
          existingModule.moduleImage = null;
          existingModule.moduleImageUrl =
              null; // This will make it fall back to course image
        }

        existingModule.modulePdf = _selectedPdf;
        existingModule.modulePdfName = _selectedPdfName;
        existingModule.modulePdfUrl = _selectedPdfUrl;

        // Update additional PDFs
        existingModule.studentGuidePdf = _studentGuidePdf;
        existingModule.studentGuidePdfName = _studentGuidePdfName;
        existingModule.studentGuidePdfUrl = _studentGuidePdfUrl;
        existingModule.facilitatorGuidePdf = _facilitatorGuidePdf;
        existingModule.facilitatorGuidePdfName = _facilitatorGuidePdfName;
        existingModule.facilitatorGuidePdfUrl = _facilitatorGuidePdfUrl;
        existingModule.answerSheetPdf = _answerSheetPdf;
        existingModule.answerSheetPdfName = _answerSheetPdfName;
        existingModule.answerSheetPdfUrl = _answerSheetPdfUrl;
        existingModule.activitiesPdf = _activitiesPdf;
        existingModule.activitiesPdfName = _activitiesPdfName;
        existingModule.activitiesPdfUrl = _activitiesPdfUrl;
        existingModule.assessmentsPdf = _assessmentsPdf;
        existingModule.assessmentsPdfName = _assessmentsPdfName;
        existingModule.assessmentsPdfUrl = _assessmentsPdfUrl;
        existingModule.testSheetPdf = _testSheetPdf;
        existingModule.testSheetPdfName = _testSheetPdfName;
        existingModule.testSheetPdfUrl = _testSheetPdfUrl;
        existingModule.assignmentsPdf = _assignmentsPdf;
        existingModule.assignmentsPdfName = _assignmentsPdfName;
        existingModule.assignmentsPdfUrl = _assignmentsPdfUrl;
        existingModule.indexPdf = _indexPdf;
        existingModule.indexPdfName = _indexPdfName;
        existingModule.indexPdfUrl = _indexPdfUrl;
        existingModule.lecturerGuidePdf = _lecturerGuidePdf;
        existingModule.lecturerGuidePdfName = _lecturerGuidePdfName;
        existingModule.lecturerGuidePdfUrl = _lecturerGuidePdfUrl;

        courseModel.updateModule(_currentModuleIndex!, existingModule);
        print("✅ Module updated at index: $_currentModuleIndex");
      } else {
        final newModule = Module(
          id: FirebaseFirestore.instance.collection('modules').doc().id,
          moduleName: _moduleNameController.text,
          moduleDescription: _moduleDescriptionController.text,
          moduleImage: _selectedImage,
          moduleImageUrl: _selectedImage != null ? _selectedImageUrl : null,
          modulePdf: _selectedPdf,
          modulePdfName: _selectedPdfName ?? 'Module PDF',
          modulePdfUrl: _selectedPdfUrl,
          studentGuidePdf: _studentGuidePdf,
          studentGuidePdfName: _studentGuidePdfName ?? 'Student Guide',
          studentGuidePdfUrl: _studentGuidePdfUrl,
          facilitatorGuidePdf: _facilitatorGuidePdf,
          facilitatorGuidePdfName:
              _facilitatorGuidePdfName ?? 'Facilitator Guide',
          facilitatorGuidePdfUrl: _facilitatorGuidePdfUrl,
          answerSheetPdf: _answerSheetPdf,
          answerSheetPdfName: _answerSheetPdfName ?? 'Answer Sheet',
          answerSheetPdfUrl: _answerSheetPdfUrl,
          activitiesPdf: _activitiesPdf,
          activitiesPdfName: _activitiesPdfName ?? 'Activities',
          activitiesPdfUrl: _activitiesPdfUrl,
          assessmentsPdf: _assessmentsPdf,
          assessmentsPdfName: _assessmentsPdfName ?? 'Assessments',
          assessmentsPdfUrl: _assessmentsPdfUrl,
          testSheetPdf: _testSheetPdf,
          testSheetPdfName: _testSheetPdfName ?? 'Test Sheet',
          testSheetPdfUrl: _testSheetPdfUrl,
          assignmentsPdf: _assignmentsPdf,
          assignmentsPdfName: _assignmentsPdfName ?? 'Assignments',
          assignmentsPdfUrl: _assignmentsPdfUrl,
          indexPdf: _indexPdf,
          indexPdfName: _indexPdfName ?? 'Index PDF',
          indexPdfUrl: _indexPdfUrl,
          lecturerGuidePdf: _lecturerGuidePdf,
          lecturerGuidePdfName: _lecturerGuidePdfName ?? 'Lecturer Guide',
          lecturerGuidePdfUrl: _lecturerGuidePdfUrl,
        );

        courseModel.addModule(newModule);
        setState(() {
          _currentModuleIndex = courseModel.modules.length - 1;
        });
        print(
            "🆕 New module added: ${newModule.moduleName} (Index: $_currentModuleIndex)");
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Module saved successfully!')),
      );
    }
  }

  void _addNewModule() {
    final courseModel = Provider.of<CourseModel>(context, listen: false);
    _clearInputs();
    setState(() {
      _currentModuleIndex = courseModel.modules.length;
    });

    // Create a new module with proper initialization
    final newModule = Module(
      moduleName: '',
      moduleDescription: '',
      id: FirebaseFirestore.instance.collection('modules').doc().id,
      moduleImage: null,
      moduleImageUrl: courseModel.courseImageUrl, // Use course image as default

      // Initialize all PDF-related fields
      modulePdf: null,
      modulePdfName: 'Module PDF',
      modulePdfUrl: null,

      studentGuidePdf: null,
      studentGuidePdfName: 'Student Guide',
      studentGuidePdfUrl: null,

      facilitatorGuidePdf: null,
      facilitatorGuidePdfName: 'Facilitator Guide',
      facilitatorGuidePdfUrl: null,

      answerSheetPdf: null,
      answerSheetPdfName: 'Answer Sheet',
      answerSheetPdfUrl: null,

      activitiesPdf: null,
      activitiesPdfName: 'Activities',
      activitiesPdfUrl: null,

      assessmentsPdf: null,
      assessmentsPdfName: 'Assessments',
      assessmentsPdfUrl: null,

      testSheetPdf: null,
      testSheetPdfName: 'Test Sheet',
      testSheetPdfUrl: null,

      assignmentsPdf: null,
      assignmentsPdfName: 'Assignments',
      assignmentsPdfUrl: null,

      indexPdf: null,
      indexPdfName: 'Index PDF',
      indexPdfUrl: null,

      lecturerGuidePdf: null,
      lecturerGuidePdfName: 'Lecturer Guide',
      lecturerGuidePdfUrl: null,
    );

    courseModel.addModule(newModule);

    // Show feedback to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('New module added. Please add content and save.'),
        duration: Duration(seconds: 3),
      ),
    );

    print("➕ New module template created with initialized PDF fields");
  }

  void _clearInputs() {
    setState(() {
      _moduleNameController.clear();
      _moduleDescriptionController.clear();
      _selectedImage = null;
      _selectedImageUrl = null; // Clear the module image URL
      _selectedPdf = null;
      _selectedPdfName = null;

      // Clear additional PDF inputs
      _selectedPdfUrl = null;

      _studentGuidePdf = null;
      _studentGuidePdfName = null;
      _studentGuidePdfUrl = null;

      _facilitatorGuidePdf = null;
      _facilitatorGuidePdfName = null;
      _facilitatorGuidePdfUrl = null;

      _answerSheetPdf = null;
      _answerSheetPdfName = null;
      _answerSheetPdfUrl = null;

      _activitiesPdf = null;
      _activitiesPdfName = null;
      _activitiesPdfUrl = null;

      _assessmentsPdf = null;
      _assessmentsPdfName = null;
      _assessmentsPdfUrl = null;

      _testSheetPdf = null;
      _testSheetPdfName = null;
      _testSheetPdfUrl = null;

      _assignmentsPdf = null;
      _assignmentsPdfName = null;
      _assignmentsPdfUrl = null;

      _indexPdf = null;
      _indexPdfName = null;
      _indexPdfUrl = null;

      _lecturerGuidePdf = null;
      _lecturerGuidePdfName = null;
      _lecturerGuidePdfUrl = null;
    });
  }

  bool _validateInputs() {
    // Only validate required fields: name and description
    if (_moduleNameController.text.isEmpty ||
        _moduleDescriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Please fill in the module name and description.')),
      );
      return false;
    }

    // Optionally, warn if neither module nor course image is present
    final courseModel = Provider.of<CourseModel>(context, listen: false);
    bool hasModuleImage = _selectedImage != null ||
        (_selectedImageUrl != null && _selectedImageUrl!.isNotEmpty);
    bool hasCourseImage = courseModel.courseImage != null ||
        (courseModel.courseImageUrl != null &&
            courseModel.courseImageUrl!.isNotEmpty);

    if (!hasModuleImage && !hasCourseImage) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Warning: No image selected for this module or course.')),
      );
      // Still allow saving, just a warning
    }

    return true;
  }

  Future<void> _saveToFirebase() async {
    // Always save current module changes first, including for new modules
    _setModule(); // This ensures all current UI data is saved to the module

    if (!_validateInputs()) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });
    try {
      final courseModel = Provider.of<CourseModel>(context, listen: false);
      final firebase_storage.FirebaseStorage storage =
          firebase_storage.FirebaseStorage.instance;
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      // Check if this is a new course or an edit
      bool isNewCourse = widget.courseId == null;

      // Track course changes
      List<String> courseChanges = [];
      if (!isNewCourse) {
        // Fetch existing course data to compare
        DocumentSnapshot existingDoc = await FirebaseFirestore.instance
            .collection('courses')
            .doc(widget.courseId)
            .get();

        if (existingDoc.exists) {
          Map<String, dynamic> existingData =
              existingDoc.data() as Map<String, dynamic>;

          if (courseModel.courseName != existingData['courseName']) {
            courseChanges.add("Updated Course Name: ${courseModel.courseName}");
          }
          if (courseModel.courseDescription !=
              existingData['courseDescription']) {
            courseChanges.add("Updated Course Description");
          }
          if (courseModel.coursePrice != existingData['coursePrice']) {
            courseChanges
                .add("Updated Course Price: ${courseModel.coursePrice}");
          }
          if (courseModel.courseCategory != existingData['courseCategory']) {
            courseChanges
                .add("Updated Course Category: ${courseModel.courseCategory}");
          }
        }
      }

      // Upload the course image only if it's new
      String? courseImageUrl =
          courseModel.courseImageUrl; // Keep existing URL by default
      int totalUploads = 1 +
          courseModel.modules.length *
              9; // 1 for course image, 9 for each module's files
      int completedUploads = 0;
      void updateProgress() {
        setState(() {
          _uploadProgress = completedUploads / totalUploads;
        });
      }

      if (courseModel.courseImage != null) {
        firebase_storage.Reference ref = storage
            .ref()
            .child('courses/${DateTime.now().millisecondsSinceEpoch}.png');
        firebase_storage.UploadTask uploadTask =
            ref.putData(courseModel.courseImage!);
        firebase_storage.TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();
        courseModel.setCourseImageUrl(downloadUrl);
        if (!isNewCourse) {
          courseChanges.add("Updated Course Image");
        }
        completedUploads++;
        updateProgress();
      } else {
        completedUploads++;
        updateProgress();
      }

      // Determine which collection to use
      final collection = isNewCourse ? 'courses' : 'pendingCourses';
      DocumentReference docRef;
      if (isNewCourse) {
        docRef = FirebaseFirestore.instance.collection(collection).doc();
      } else {
        // For edited courses, use the same document ID as the original course
        docRef = FirebaseFirestore.instance
            .collection(collection)
            .doc(widget.courseId);
      }

      // Track module changes
      List<Map<String, dynamic>> moduleChanges = [];

      // Upload modules to a subcollection under the course document
      for (var module in courseModel.modules) {
        // Track changes for this module
        List<String> moduleChangeList = [];
        DocumentSnapshot? existingModuleDoc;

        // For edited courses, fetch existing module data to compare
        bool isNewModule = false;
        if (!isNewCourse) {
          try {
            existingModuleDoc = await FirebaseFirestore.instance
                .collection('courses')
                .doc(widget.courseId)
                .collection('modules')
                .doc(module.id)
                .get();

            if (existingModuleDoc.exists) {
              Map<String, dynamic> existingData =
                  existingModuleDoc.data() as Map<String, dynamic>;

              // Compare and track changes
              if (module.moduleName != existingData['moduleName']) {
                moduleChangeList
                    .add("Updated Module Name: ${module.moduleName}");
              }
              if (module.moduleDescription !=
                  existingData['moduleDescription']) {
                moduleChangeList.add("Updated Module Description");
              }
              if (module.moduleImage != null) {
                moduleChangeList.add("Updated Module Image");
              }
              if (module.modulePdf != null) {
                moduleChangeList.add("Updated Module PDF");
              }
              if (module.studentGuidePdf != null) {
                moduleChangeList.add("Updated Student Guide");
              }
              if (module.facilitatorGuidePdf != null) {
                moduleChangeList.add("Updated Facilitator Guide");
              }
              if (module.answerSheetPdf != null) {
                moduleChangeList.add("Updated Answer Sheet");
              }
              if (module.activitiesPdf != null) {
                moduleChangeList.add("Updated Activities");
              }
              if (module.assessmentsPdf != null) {
                moduleChangeList.add("Updated Assessments");
              }
              if (module.testSheetPdf != null) {
                moduleChangeList.add("Updated Test Sheet");
              }
              if (module.assignmentsPdf != null) {
                moduleChangeList.add("Updated Assignments");
              }
            } else {
              // This is a new module being added to an existing course
              isNewModule = true;
              moduleChangeList.add("Added New Module: ${module.moduleName}");

              // Mark all uploaded content as new
              if (module.moduleImage != null || module.moduleImageUrl != null) {
                moduleChangeList.add("Added Module Image");
              }
              if (module.modulePdf != null || module.modulePdfUrl != null) {
                moduleChangeList.add("Added Module PDF");
              }
              if (module.studentGuidePdf != null ||
                  module.studentGuidePdfUrl != null) {
                moduleChangeList.add("Added Student Guide");
              }
              if (module.facilitatorGuidePdf != null ||
                  module.facilitatorGuidePdfUrl != null) {
                moduleChangeList.add("Added Facilitator Guide");
              }
              if (module.answerSheetPdf != null ||
                  module.answerSheetPdfUrl != null) {
                moduleChangeList.add("Added Answer Sheet");
              }
              if (module.activitiesPdf != null ||
                  module.activitiesPdfUrl != null) {
                moduleChangeList.add("Added Activities");
              }
              if (module.assessmentsPdf != null ||
                  module.assessmentsPdfUrl != null) {
                moduleChangeList.add("Added Assessments");
              }
              if (module.testSheetPdf != null ||
                  module.testSheetPdfUrl != null) {
                moduleChangeList.add("Added Test Sheet");
              }
              if (module.assignmentsPdf != null ||
                  module.assignmentsPdfUrl != null) {
                moduleChangeList.add("Added Assignments");
              }
              if (module.indexPdf != null || module.indexPdfUrl != null) {
                moduleChangeList.add("Added Index PDF");
              }
              if (module.lecturerGuidePdf != null ||
                  module.lecturerGuidePdfUrl != null) {
                moduleChangeList.add("Added Lecturer Guide");
              }
            }
          } catch (e) {
            print("Error fetching existing module data: $e");
            // If there's an error fetching, treat as new module to be safe
            isNewModule = true;
          }
        } else {
          // For new courses, all modules are new
          isNewModule = true;
        }

        // Upload module image only if it's new
        String? moduleImageUrl =
            module.moduleImageUrl; // Keep existing URL by default
        if (module.moduleImage != null) {
          firebase_storage.Reference ref = storage.ref().child(
              'modules/${DateTime.now().millisecondsSinceEpoch}_module.png');
          firebase_storage.UploadTask uploadTask =
              ref.putData(module.moduleImage!);
          firebase_storage.TaskSnapshot snapshot = await uploadTask;
          moduleImageUrl = await snapshot.ref.getDownloadURL();
          completedUploads++;
          updateProgress();
        } else if (isNewModule) {
          // For new modules, use the course image URL if no specific module image
          moduleImageUrl = courseModel.courseImageUrl ?? courseImageUrl;
          completedUploads++;
          updateProgress();
        } else {
          // If no module image is uploaded, use the course image URL
          moduleImageUrl =
              moduleImageUrl ?? courseModel.courseImageUrl ?? courseImageUrl;
          completedUploads++;
          updateProgress();
        }

        // Helper function to handle PDF uploads with improved new module handling
        Future<String?> uploadPdf(
            Uint8List? pdfData, String? existingUrl, String fileName) async {
          // For new modules or when new PDF data is provided
          if (pdfData != null) {
            try {
              print('Starting upload for $fileName');
              firebase_storage.Reference ref = storage.ref().child(
                  'pdfs/${DateTime.now().millisecondsSinceEpoch}_$fileName.pdf');

              // Create upload task with metadata
              firebase_storage.UploadTask uploadTask = ref.putData(
                  pdfData,
                  firebase_storage.SettableMetadata(
                      contentType: 'application/pdf',
                      customMetadata: {'fileName': fileName}));

              // Monitor upload progress
              uploadTask.snapshotEvents
                  .listen((firebase_storage.TaskSnapshot snapshot) {
                print(
                    'Upload progress for $fileName: ${snapshot.bytesTransferred}/${snapshot.totalBytes}');
              });

              // Wait for upload to complete
              firebase_storage.TaskSnapshot snapshot = await uploadTask;
              String downloadUrl = await snapshot.ref.getDownloadURL();

              print('Successfully uploaded $fileName: $downloadUrl');
              completedUploads++;
              updateProgress();
              return downloadUrl;
            } catch (e) {
              print('Error uploading $fileName: $e');
              completedUploads++;
              updateProgress();
              return null;
            }
          } else if (existingUrl != null && existingUrl.isNotEmpty) {
            // Keep existing URL if no new data
            print('Using existing URL for $fileName: $existingUrl');
            completedUploads++;
            updateProgress();
            return existingUrl;
          } else {
            // For new modules or when no data is provided
            print('No PDF data for $fileName');
            completedUploads++;
            updateProgress();
            return null;
          }
        }

        // Debug logging for module data
        print('📋 Processing module: ${module.moduleName}');
        print('🆕 Is new module: $isNewModule');
        print('📄 Module PDF data present: ${module.modulePdf != null}');
        print(
            '📄 Student Guide PDF data present: ${module.studentGuidePdf != null}');
        print(
            '📄 Facilitator Guide PDF data present: ${module.facilitatorGuidePdf != null}');
        print(
            '📄 Answer Sheet PDF data present: ${module.answerSheetPdf != null}');
        print(
            '📄 Activities PDF data present: ${module.activitiesPdf != null}');
        print(
            '📄 Assessments PDF data present: ${module.assessmentsPdf != null}');
        print('📄 Test Sheet PDF data present: ${module.testSheetPdf != null}');
        print(
            '📄 Assignments PDF data present: ${module.assignmentsPdf != null}');
        print('📄 Index PDF data present: ${module.indexPdf != null}');
        print(
            '📄 Lecturer Guide PDF data present: ${module.lecturerGuidePdf != null}');

        // Upload all PDFs consistently
        String? modulePdfUrl = await uploadPdf(
            module.modulePdf, module.modulePdfUrl, 'module_pdf');
        String? studentGuidePdfUrl = await uploadPdf(
            module.studentGuidePdf, module.studentGuidePdfUrl, 'student_guide');
        String? facilitatorGuidePdfUrl = await uploadPdf(
            module.facilitatorGuidePdf,
            module.facilitatorGuidePdfUrl,
            'facilitator_guide');
        String? answerSheetPdfUrl = await uploadPdf(
            module.answerSheetPdf, module.answerSheetPdfUrl, 'answer_sheet');
        String? activitiesPdfUrl = await uploadPdf(
            module.activitiesPdf, module.activitiesPdfUrl, 'activities');
        String? assessmentsPdfUrl = await uploadPdf(
            module.assessmentsPdf, module.assessmentsPdfUrl, 'assessments');
        String? testSheetPdfUrl = await uploadPdf(
            module.testSheetPdf, module.testSheetPdfUrl, 'test_sheet');
        String? assignmentsPdfUrl = await uploadPdf(
            module.assignmentsPdf, module.assignmentsPdfUrl, 'assignments');
        String? indexPdfUrl =
            await uploadPdf(module.indexPdf, module.indexPdfUrl, 'index');
        String? lecturerGuidePdfUrl = await uploadPdf(module.lecturerGuidePdf,
            module.lecturerGuidePdfUrl, 'lecturer_guide');

        // If there are changes, add to moduleChanges list
        if (moduleChangeList.isNotEmpty) {
          moduleChanges.add({
            'moduleId': module.id,
            'moduleName': module.moduleName,
            'changes': moduleChangeList,
          });
        }

        // Prepare module data with additional PDFs
        final moduleData = {
          'moduleName': module.moduleName,
          'moduleDescription': module.moduleDescription,
          'moduleImageUrl': moduleImageUrl,
          'modulePdfUrl': modulePdfUrl,
          'modulePdfName': module.modulePdfName ?? 'Module PDF',
          'studentGuidePdfUrl': studentGuidePdfUrl,
          'studentGuidePdfName': module.studentGuidePdfName ?? 'Student Guide',
          'facilitatorGuidePdfUrl': facilitatorGuidePdfUrl,
          'facilitatorGuidePdfName':
              module.facilitatorGuidePdfName ?? 'Facilitator Guide',
          'answerSheetPdfUrl': answerSheetPdfUrl,
          'answerSheetPdfName': module.answerSheetPdfName ?? 'Answer Sheet',
          'activitiesPdfUrl': activitiesPdfUrl,
          'activitiesPdfName': module.activitiesPdfName ?? 'Activities',
          'assessmentsPdfUrl': assessmentsPdfUrl,
          'assessmentsPdfName': module.assessmentsPdfName ?? 'Assessments',
          'testSheetPdfUrl': testSheetPdfUrl,
          'testSheetPdfName': module.testSheetPdfName ?? 'Test Sheet',
          'assignmentsPdfUrl': assignmentsPdfUrl,
          'assignmentsPdfName': module.assignmentsPdfName ?? 'Assignments',
          'indexPdfUrl': indexPdfUrl,
          'indexPdfName': module.indexPdfName ?? 'Index PDF',
          'lecturerGuidePdfUrl': lecturerGuidePdfUrl,
          'lecturerGuidePdfName':
              module.lecturerGuidePdfName ?? 'Lecturer Guide',
          'questions': module.questions.map((q) => q.toMap()).toList(),
          'tasks': module.tasks.map((t) => t.toMap()).toList(),
          'assignments': module.assignments.map((a) => a.toMap()).toList(),
        };

        // For edited courses, use the same module ID in the subcollection
        if (!isNewCourse) {
          await docRef.collection('modules').doc(module.id).set(moduleData);
        } else {
          await docRef.collection('modules').add(moduleData);
        }
      }

      // Prepare data for Firestore
      final courseData = {
        'courseName': courseModel.courseName,
        'coursePrice': courseModel.coursePrice,
        'courseCategory': courseModel.courseCategory,
        'courseDescription': courseModel.courseDescription,
        'courseImageUrl': courseImageUrl,
        'createdBy': user.uid,
        'status': isNewCourse ? 'pending_approval' : 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'editedAt': isNewCourse ? null : FieldValue.serverTimestamp(),
        'changes': isNewCourse ? null : courseChanges,
        'moduleChanges': isNewCourse ? null : moduleChanges,
      };

      // If editing, update the document
      if (!isNewCourse) {
        await docRef.set(courseData, SetOptions(merge: true));
      } else {
        await docRef.set(courseData);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Course and modules submitted!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload data: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
    }
  }

  void _saveCurrentModuleChanges() {
    final courseModel = Provider.of<CourseModel>(context, listen: false);

    if (_currentModuleIndex != null &&
        _currentModuleIndex! < courseModel.modules.length) {
      // Get the current module
      Module existingModule = courseModel.modules[_currentModuleIndex!];

      // Track changes in a list
      List<String> moduleChangeList = [];

      // Compare and detect changes
      if (_moduleNameController.text.trim() !=
          existingModule.moduleName.trim()) {
        moduleChangeList
            .add("Updated Module Name: ${_moduleNameController.text}");
      }
      if (_moduleDescriptionController.text.trim() !=
          existingModule.moduleDescription.trim()) {
        moduleChangeList.add("Updated Module Description");
      }

      // Handle Module Image
      if (_selectedImage != null) {
        moduleChangeList.add("Updated Module Image");
        existingModule.moduleImage = _selectedImage;
        existingModule.moduleImageUrl = _selectedImageUrl;
      } else if (existingModule.moduleImage == null &&
          existingModule.moduleImageUrl == null) {
        existingModule.moduleImageUrl = courseModel.courseImageUrl;
      }

      // Update module data
      existingModule.moduleName = _moduleNameController.text;
      existingModule.moduleDescription = _moduleDescriptionController.text;

      // Handle all PDFs
      if (_selectedPdf != null) {
        moduleChangeList.add("Updated Module PDF");
        existingModule.modulePdf = _selectedPdf;
        existingModule.modulePdfName = _selectedPdfName;
        existingModule.modulePdfUrl = null; // Clear URL to force upload
      }

      if (_studentGuidePdf != null) {
        moduleChangeList.add("Updated Student Guide");
        existingModule.studentGuidePdf = _studentGuidePdf;
        existingModule.studentGuidePdfName = _studentGuidePdfName;
        existingModule.studentGuidePdfUrl = null;
      }

      if (_facilitatorGuidePdf != null) {
        moduleChangeList.add("Updated Facilitator Guide");
        existingModule.facilitatorGuidePdf = _facilitatorGuidePdf;
        existingModule.facilitatorGuidePdfName = _facilitatorGuidePdfName;
        existingModule.facilitatorGuidePdfUrl = null;
      }

      if (_answerSheetPdf != null) {
        moduleChangeList.add("Updated Answer Sheet");
        existingModule.answerSheetPdf = _answerSheetPdf;
        existingModule.answerSheetPdfName = _answerSheetPdfName;
        existingModule.answerSheetPdfUrl = null;
      }

      if (_activitiesPdf != null) {
        moduleChangeList.add("Updated Activities");
        existingModule.activitiesPdf = _activitiesPdf;
        existingModule.activitiesPdfName = _activitiesPdfName;
        existingModule.activitiesPdfUrl = null;
      }

      if (_assessmentsPdf != null) {
        moduleChangeList.add("Updated Assessments");
        existingModule.assessmentsPdf = _assessmentsPdf;
        existingModule.assessmentsPdfName = _assessmentsPdfName;
        existingModule.assessmentsPdfUrl = null;
      }

      if (_testSheetPdf != null) {
        moduleChangeList.add("Updated Test Sheet");
        existingModule.testSheetPdf = _testSheetPdf;
        existingModule.testSheetPdfName = _testSheetPdfName;
        existingModule.testSheetPdfUrl = null;
      }

      if (_assignmentsPdf != null) {
        moduleChangeList.add("Updated Assignments");
        existingModule.assignmentsPdf = _assignmentsPdf;
        existingModule.assignmentsPdfName = _assignmentsPdfName;
        existingModule.assignmentsPdfUrl = null;
      }

      if (_indexPdf != null) {
        moduleChangeList.add("Updated Index PDF");
        existingModule.indexPdf = _indexPdf;
        existingModule.indexPdfName = _indexPdfName;
        existingModule.indexPdfUrl = null;
      }

      if (_lecturerGuidePdf != null) {
        moduleChangeList.add("Updated Lecturer Guide");
        existingModule.lecturerGuidePdf = _lecturerGuidePdf;
        existingModule.lecturerGuidePdfName = _lecturerGuidePdfName;
        existingModule.lecturerGuidePdfUrl = null;
      }

      // Attach changes to module
      existingModule.changes = moduleChangeList;

      // Save changes inside CourseModel
      courseModel.updateModule(_currentModuleIndex!, existingModule);

      print(
          "✅ Auto-saved module changes at index: $_currentModuleIndex with changes: $moduleChangeList");
    }
  }

  void _navigateToNextModule() {
    final courseModel = Provider.of<CourseModel>(context, listen: false);

    // Save the current module before navigating
    _saveCurrentModuleChanges();

    if (_currentModuleIndex != null &&
        _currentModuleIndex! < courseModel.modules.length - 1) {
      setState(() {
        _currentModuleIndex = _currentModuleIndex! + 1;
        _loadModuleData();
      });
    }
  }

  void _navigateToPreviousModule() {
    final courseModel = Provider.of<CourseModel>(context, listen: false);

    // Save the current module before navigating
    _saveCurrentModuleChanges();

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

    return Stack(
      children: [
        Material(
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
                    child: Center(
                      child: Text(
                        widget.courseId != null
                            ? 'Edit Module'
                            : 'Upload Module',
                        style: MyTextStyles(context).headerWhite.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Main Content Card
                  Expanded(
                    child: SingleChildScrollView(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Module Navigation and Controls
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Module ${currentIndex} of $totalModules',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Mycolors().darkGrey,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 30),
                            // Module Name
                            ContentDevTextfields(
                              inputController: _moduleNameController,
                              headerText: widget.courseId != null
                                  ? 'Edit Module Name'
                                  : 'Module Name',
                              keyboardType: '',
                            ),
                            SizedBox(height: 30),
                            // Module Content Section
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  flex: 2,
                                  child: InkWell(
                                    onTap: _pickImage,
                                    child: Container(
                                      constraints:
                                          BoxConstraints(maxHeight: 250),
                                      decoration: BoxDecoration(
                                        color: Mycolors().offWhite,
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                          color: Colors.grey.withOpacity(0.3),
                                        ),
                                      ),
                                      child: (() {
                                        final courseModel =
                                            Provider.of<CourseModel>(context);

                                        // 1. First priority: In-memory selected image
                                        if (_selectedImage != null) {
                                          return ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            child: Image.memory(
                                              _selectedImage!,
                                              fit: BoxFit.cover,
                                            ),
                                          );
                                        }
                                        // 2. Second priority: Selected image URL (could be blob or network)
                                        else if (_selectedImageUrl != null &&
                                            _selectedImageUrl!.isNotEmpty) {
                                          // Check if it's a blob URL (starts with blob:)
                                          if (_selectedImageUrl!
                                              .startsWith('blob:')) {
                                            return ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              child: Image.network(
                                                _selectedImageUrl!,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.3,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.3,
                                                fit: BoxFit.cover,
                                                loadingBuilder: (context, child,
                                                    loadingProgress) {
                                                  if (loadingProgress == null)
                                                    return child;
                                                  return Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: Mycolors().blue,
                                                    ),
                                                  );
                                                },
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  print(
                                                      "Error loading blob URL: $error");
                                                  return _buildErrorWidget();
                                                },
                                              ),
                                            );
                                          }
                                          // Handle remote URLs with ImageNetwork widget
                                          else {
                                            return ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              child: ImageNetwork(
                                                image: _selectedImageUrl!,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.3,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.3,
                                                fitWeb: BoxFitWeb.cover,
                                                fitAndroidIos: BoxFit.cover,
                                                onLoading: Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                  color: Mycolors().blue,
                                                )),
                                                onError: _buildErrorWidget(),
                                              ),
                                            );
                                          }
                                        }
                                        // 3. Third priority: In-memory course image
                                        else if (courseModel.courseImage !=
                                            null) {
                                          return ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            child: Image.memory(
                                              courseModel.courseImage!,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.3,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.3,
                                              fit: BoxFit.cover,
                                            ),
                                          );
                                        }
                                        // 4. Fourth priority: Course image URL
                                        else if (courseModel.courseImageUrl !=
                                                null &&
                                            courseModel
                                                .courseImageUrl!.isNotEmpty) {
                                          // Check if it's a blob URL
                                          if (courseModel.courseImageUrl!
                                              .startsWith('blob:')) {
                                            return ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              child: Image.network(
                                                courseModel.courseImageUrl!,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.3,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.3,
                                                fit: BoxFit.cover,
                                                loadingBuilder: (context, child,
                                                    loadingProgress) {
                                                  if (loadingProgress == null)
                                                    return child;
                                                  return Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: Mycolors().blue,
                                                    ),
                                                  );
                                                },
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  print(
                                                      "Error loading course blob URL: $error");
                                                  return _buildErrorWidget();
                                                },
                                              ),
                                            );
                                          } else {
                                            return ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              child: ImageNetwork(
                                                image:
                                                    courseModel.courseImageUrl!,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.3,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.3,
                                                fitWeb: BoxFitWeb.cover,
                                                fitAndroidIos: BoxFit.cover,
                                                onLoading: Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                  color: Mycolors().blue,
                                                )),
                                                onError: _buildErrorWidget(),
                                              ),
                                            );
                                          }
                                        }
                                        // 5. Default: Placeholder
                                        else {
                                          return Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons
                                                    .add_photo_alternate_outlined,
                                                size: 50,
                                                color: Mycolors().darkGrey,
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                'Click to upload module image\nor use course image',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Mycolors().darkGrey,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          );
                                        }
                                      })(),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 30),
                                Flexible(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Module Documents',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Mycolors().darkGrey,
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      Wrap(
                                        spacing: 10,
                                        runSpacing: 10,
                                        children: [
                                          _buildPdfButton(
                                              widget.courseId != null
                                                  ? 'Edit Student Guide'
                                                  : 'Student Guide',
                                              _studentGuidePdf,
                                              _studentGuidePdfUrl),
                                          _buildPdfButton(
                                              widget.courseId != null
                                                  ? 'Edit Facilitator Guide'
                                                  : 'Facilitator Guide',
                                              _facilitatorGuidePdf,
                                              _facilitatorGuidePdfUrl),
                                          _buildPdfButton(
                                              widget.courseId != null
                                                  ? 'Edit Answer Sheet'
                                                  : 'Answer Sheet',
                                              _answerSheetPdf,
                                              _answerSheetPdfUrl),
                                          _buildPdfButton(
                                              widget.courseId != null
                                                  ? 'Edit Lecturer Guide'
                                                  : 'Lecturer Guide',
                                              _lecturerGuidePdf,
                                              _lecturerGuidePdfUrl),
                                          _buildPdfButton(
                                              widget.courseId != null
                                                  ? 'Edit Assessments'
                                                  : 'Assessments',
                                              _assessmentsPdf,
                                              _assessmentsPdfUrl),
                                          _buildPdfButton(
                                              widget.courseId != null
                                                  ? 'Edit Test'
                                                  : 'Test',
                                              _testSheetPdf,
                                              _testSheetPdfUrl),
                                          _buildPdfButton(
                                              widget.courseId != null
                                                  ? 'Edit Assignments'
                                                  : 'Assignments',
                                              _assignmentsPdf,
                                              _assignmentsPdfUrl),
                                        ],
                                      ),
                                      SizedBox(height: 20),
                                      Row(
                                        children: [
                                          _buildPdfButton(
                                            widget.courseId != null
                                                ? 'Edit Index PDF'
                                                : 'Index PDF',
                                            _indexPdf,
                                            _indexPdfUrl,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 30),
                            // Module Description
                            ContentDevTextfields(
                              headerText: widget.courseId != null
                                  ? 'Edit Module Description'
                                  : 'Module Content',
                              inputController: _moduleDescriptionController,
                              keyboardType: '',
                              maxLines: 9,
                            ),
                            SizedBox(height: 30),
                            // Navigation Buttons Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _navigateToPreviousModule,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Mycolors().darkGrey,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(
                                          color: Mycolors().darkGrey),
                                    ),
                                  ),
                                  icon: Icon(Icons.arrow_back),
                                  label: Text('Previous'),
                                ),
                                SizedBox(width: 20),
                                ElevatedButton.icon(
                                  onPressed: _setModule,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Mycolors().blue,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  icon: Icon(Icons.save),
                                  label: Text('Save Module'),
                                ),
                                SizedBox(width: 20),
                                ElevatedButton.icon(
                                  onPressed: _addNewModule,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Mycolors().blue,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  icon: Icon(Icons.add),
                                  label: Text('Add New Module'),
                                ),
                                SizedBox(width: 20),
                                ElevatedButton.icon(
                                  onPressed: _navigateToNextModule,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Mycolors().darkGrey,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(
                                          color: Mycolors().darkGrey),
                                    ),
                                  ),
                                  icon: Icon(Icons.arrow_forward),
                                  label: Text('Next'),
                                ),
                              ],
                            ),
                            SizedBox(height: 40),
                            // Submit Button
                            Center(
                              child: ElevatedButton.icon(
                                onPressed: _saveToFirebase,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Mycolors().green,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                icon: Icon(Icons.send, color: Colors.white),
                                label: Text(
                                  'Submit for Review',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
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
        ),
        if (_isUploading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                      width: 300,
                      child: LinearProgressIndicator(value: _uploadProgress)),
                  SizedBox(height: 16),
                  Text('Uploading, please wait...',
                      style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPdfButton(String title, Uint8List? pdfData, [String? pdfUrl]) {
    // A PDF is considered uploaded if either we have new data or an existing URL
    final isUploaded = pdfData != null || (pdfUrl != null && pdfUrl.isNotEmpty);
    final isNewUpload = pdfData != null;

    // Debug logging for PDF status

    return ElevatedButton.icon(
      onPressed: () => _pickPdf(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: isUploaded ? Mycolors().green : Colors.white,
        foregroundColor: isUploaded ? Colors.white : Mycolors().darkGrey,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isUploaded ? Mycolors().green : Mycolors().darkGrey,
          ),
        ),
      ),
      icon: Icon(isNewUpload
          ? Icons.check_circle
          : isUploaded
              ? Icons.cloud_done
              : Icons.upload_file),
      label: Text(isNewUpload
          ? '$title Ready'
          : isUploaded
              ? '$title Added'
              : title),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 50,
            color: Colors.red,
          ),
          SizedBox(height: 10),
          Text(
            'Failed to load image',
            style: TextStyle(
              color: Colors.red,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
