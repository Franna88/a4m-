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

  String? _selectedImageUrl;

  String? _selectedPdfUrl;

  String? _studentGuidePdfUrl;

  String? _facilitatorGuidePdfUrl;

  String? _answerSheetPdfUrl;

  String? _activitiesPdfUrl;

  String? _assessmentsPdfUrl;

  String? _testSheetPdfUrl;

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

    // If modules have already been loaded, simply use the current module index.
    if (courseModel.modules.isNotEmpty &&
        _currentModuleIndex != null &&
        _currentModuleIndex! < courseModel.modules.length) {
      final existingModule = courseModel.modules[_currentModuleIndex!];
      setState(() {
        _moduleNameController.text = existingModule.moduleName;
        _moduleDescriptionController.text = existingModule.moduleDescription;
        _selectedImageUrl = existingModule.moduleImageUrl;
        _selectedPdfUrl = existingModule.modulePdfUrl;

        _studentGuidePdfUrl = existingModule.studentGuidePdfUrl;
        _facilitatorGuidePdfUrl = existingModule.facilitatorGuidePdfUrl;
        _answerSheetPdfUrl = existingModule.answerSheetPdfUrl;
        _activitiesPdfUrl = existingModule.activitiesPdfUrl;
        _assessmentsPdfUrl = existingModule.assessmentsPdfUrl;
        _testSheetPdfUrl = existingModule.testSheetPdfUrl;

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
            moduleImageUrl: data['moduleImageUrl'],
            studentGuidePdfUrl: data['studentGuidePdfUrl'],
            facilitatorGuidePdfUrl: data['facilitatorGuidePdfUrl'],
            answerSheetPdfUrl: data['answerSheetPdfUrl'],
            activitiesPdfUrl: data['activitiesPdfUrl'],
            assessmentsPdfUrl: data['assessmentsPdfUrl'],
            testSheetPdfUrl: data['testSheetPdfUrl'],
            modulePdfName: data['modulePdfName'],
            studentGuidePdfName: data['studentGuidePdfName'],
            facilitatorGuidePdfName: data['facilitatorGuidePdfName'],
            answerSheetPdfName: data['answerSheetPdfName'],
            activitiesPdfName: data['activitiesPdfName'],
            assessmentsPdfName: data['assessmentsPdfName'],
            testSheetPdfName: data['testSheetPdfName'],
          );
        }).toList();

        // Update CourseModel only if it's empty.
        if (courseModel.modules.isEmpty) {
          courseModel.modules = fetchedModules;
        }

        // Only reset _currentModuleIndex to 0 if it’s null or out-of-bounds.
        if (_currentModuleIndex == null ||
            _currentModuleIndex! >= fetchedModules.length) {
          _currentModuleIndex = 0;
        }

        setState(() {
          _moduleNameController.text =
              courseModel.modules[_currentModuleIndex!].moduleName;
          _moduleDescriptionController.text =
              courseModel.modules[_currentModuleIndex!].moduleDescription;
          _selectedImageUrl =
              courseModel.modules[_currentModuleIndex!].moduleImageUrl;
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
        existingModule.moduleImage = _selectedImage;
        existingModule.moduleImageUrl =
            _selectedImageUrl; // <-- Update the image URL here
        existingModule.modulePdf = _selectedPdf;
        existingModule.modulePdfName = _selectedPdfName;

        // Update additional PDFs
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
        // Create new module (Creation Mode)
        final newModule = Module(
          id: FirebaseFirestore.instance.collection('modules').doc().id,
          moduleName: _moduleNameController.text,
          moduleDescription: _moduleDescriptionController.text,
          moduleImage: _selectedImage,
          moduleImageUrl:
              _selectedImageUrl, // <-- Assign the module image URL here too
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

  void _clearInputs() {
    setState(() {
      _moduleNameController.clear();
      _moduleDescriptionController.clear();
      _selectedImage = null;
      _selectedImageUrl = null; // Clear the module image URL
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
        (_selectedImage == null &&
            (_selectedImageUrl == null ||
                _selectedImageUrl!.isEmpty)) || // ✅ Allow existing image URL
        (_selectedPdf == null &&
            (_selectedPdfUrl == null || _selectedPdfUrl!.isEmpty))) {
      // ✅ Allow existing PDF URL
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
    if (!_validateInputs()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final firestore = FirebaseFirestore.instance;
      final storage = firebase_storage.FirebaseStorage.instance;
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) throw Exception('No user logged in');

      final courseModel = Provider.of<CourseModel>(context, listen: false);

      // Fetch live course data for comparison
      DocumentSnapshot liveDoc =
          await firestore.collection('courses').doc(widget.courseId).get();
      Map<String, dynamic> liveData =
          liveDoc.exists ? liveDoc.data() as Map<String, dynamic> : {};

      List<String> courseChangeList = [];
      List<Map<String, dynamic>> moduleChanges = [];

      // Track course field changes
      if (courseModel.courseName.trim() !=
          (liveData['courseName'] ?? '').trim()) {
        courseChangeList.add("Updated Course Name: ${courseModel.courseName}");
      }
      if (courseModel.coursePrice.trim() !=
          (liveData['coursePrice'] ?? '').trim()) {
        courseChangeList
            .add("Updated Course Price: ${courseModel.coursePrice}");
      }
      if (courseModel.courseCategory.trim() !=
          (liveData['courseCategory'] ?? '').trim()) {
        courseChangeList
            .add("Updated Course Category: ${courseModel.courseCategory}");
      }
      if (courseModel.courseDescription.trim() !=
          (liveData['courseDescription'] ?? '').trim()) {
        courseChangeList.add("Updated Course Description");
      }

      // Handle course image
      String newImageUrl =
          _selectedImageUrl ?? courseModel.courseImageUrl ?? '';

      if (_selectedImage != null) {
        firebase_storage.Reference imageRef = storage
            .ref()
            .child('courses/${DateTime.now().millisecondsSinceEpoch}.png');

        firebase_storage.TaskSnapshot snapshot =
            await imageRef.putData(_selectedImage!);
        newImageUrl = await snapshot.ref.getDownloadURL();

        // Update the course model with the new image URL
        courseModel.setCourseImageUrl(newImageUrl);
        courseChangeList.add("Updated Course Image");
      }

      // --- Save Pending Course Data ---
      DocumentReference pendingCourseRef =
          firestore.collection('pendingCourses').doc(widget.courseId);

      await pendingCourseRef.set({
        'courseName': courseModel.courseName,
        'coursePrice': courseModel.coursePrice,
        'courseCategory': courseModel.courseCategory,
        'courseDescription': courseModel.courseDescription,
        'courseImageUrl': newImageUrl,
        'status': 'pending',
        'editedAt': FieldValue.serverTimestamp(),
        'changes': courseChangeList.isNotEmpty
            ? courseChangeList
            : ["No Course Changes"],
      }, SetOptions(merge: true));

      // --- Save Pending Module Data ---
      // --- Save Pending Module Data ---
      // --- Save Pending Module Data ---
      for (int i = 0; i < courseModel.modules.length; i++) {
        Module module = courseModel.modules[i]; // Get the current module
        String moduleId = module.id; // Ensure this is unique per module

        print("Processing Module: ${module.moduleName} (ID: $moduleId)");

        DocumentReference pendingModuleRef =
            pendingCourseRef.collection('modules').doc(moduleId);

        // Prevent Overwriting: Check if the module already exists
        DocumentSnapshot existingModule = await pendingModuleRef.get();
        Map<String, dynamic>? existingModuleData = existingModule.exists
            ? existingModule.data() as Map<String, dynamic>
            : null;

        if (existingModuleData != null &&
            existingModuleData['moduleName'] == module.moduleName) {
          print("Skipping duplicate module: ${module.moduleName}");
          continue; // Skip saving if this module is already stored
        }

        // Track module changes
        List<String> moduleChangeList = [];

        // Use the module’s own values instead of controller values
        Map<String, dynamic> pendingData = {
          'moduleName': module.moduleName,
          'moduleDescription': module.moduleDescription,
          'moduleImageUrl': module.moduleImageUrl ?? '',
          'modulePdfUrl': module.modulePdfUrl ?? '',
          'studentGuidePdfUrl': module.studentGuidePdfUrl ?? '',
          'facilitatorGuidePdfUrl': module.facilitatorGuidePdfUrl ?? '',
          'answerSheetPdfUrl': module.answerSheetPdfUrl ?? '',
          'activitiesPdfUrl': module.activitiesPdfUrl ?? '',
          'assessmentsPdfUrl': module.assessmentsPdfUrl ?? '',
          'testSheetPdfUrl': module.testSheetPdfUrl ?? '',
          'status': 'pending',
          'editedAt': FieldValue.serverTimestamp(),
        };

        // Detect changes in module fields by comparing **module values**, not controller text
        if (module.moduleName.trim() !=
            (existingModuleData?['moduleName'] ?? '').trim()) {
          moduleChangeList.add("Updated Module Name: ${module.moduleName}");
        }
        if (module.moduleDescription.trim() !=
            (existingModuleData?['moduleDescription'] ?? '').trim()) {
          moduleChangeList.add("Updated Module Description");
        }

        // Save the module only if it hasn’t been duplicated
        await pendingModuleRef.set(pendingData, SetOptions(merge: true));
        print("✅ Saved Module: ${module.moduleName} (ID: $moduleId)");

        // --- Handle Module Image ---
        if (_selectedImage != null) {
          firebase_storage.Reference imageRef = storage
              .ref()
              .child('modules/${DateTime.now().millisecondsSinceEpoch}.png');
          firebase_storage.TaskSnapshot imageSnapshot =
              await imageRef.putData(_selectedImage!);
          String newImgUrl = await imageSnapshot.ref.getDownloadURL();
          pendingData['moduleImageUrl'] = newImgUrl;
          moduleChangeList.add("Updated Module Image");
        } else {
          pendingData['moduleImageUrl'] =
              _selectedImageUrl ?? module.moduleImageUrl ?? '';
        }

        // --- Handle PDF Uploads ---
        Future<String> uploadPdf(
            Uint8List? pdfData, String? existingUrl, String fileName) async {
          if (pdfData != null) {
            firebase_storage.Reference pdfRef = storage.ref().child(
                'module_pdfs/${DateTime.now().millisecondsSinceEpoch}_$fileName.pdf');

            firebase_storage.SettableMetadata metadata =
                firebase_storage.SettableMetadata(
                    contentType: 'application/pdf');

            firebase_storage.TaskSnapshot pdfSnapshot =
                await pdfRef.putData(pdfData, metadata);

            return await pdfSnapshot.ref.getDownloadURL();
          }
          return existingUrl ?? '';
        }

        // Upload & track changes for each PDF type
        Map<String, Uint8List?> pdfFiles = {
          "Module PDF": _selectedPdf,
          "Student Guide": _studentGuidePdf,
          "Facilitator Guide": _facilitatorGuidePdf,
          "Answer Sheet": _answerSheetPdf,
          "Activities": _activitiesPdf,
          "Assessments": _assessmentsPdf,
          "Test Sheet": _testSheetPdf
        };

        Map<String, String?> existingUrls = {
          "Module PDF": module.modulePdfUrl,
          "Student Guide": module.studentGuidePdfUrl,
          "Facilitator Guide": module.facilitatorGuidePdfUrl,
          "Answer Sheet": module.answerSheetPdfUrl,
          "Activities": module.activitiesPdfUrl,
          "Assessments": module.assessmentsPdfUrl,
          "Test Sheet": module.testSheetPdfUrl
        };

        for (String key in pdfFiles.keys) {
          String pdfKey = key.replaceAll(" ", "").toLowerCase() + "Url";
          Uint8List? pdfFile = pdfFiles[key];

          String newPdfUrl = await uploadPdf(
              pdfFile, existingUrls[key], key.replaceAll(" ", "_"));
          if (pdfFile != null) {
            pendingData[pdfKey] = newPdfUrl;
            moduleChangeList.add("Updated $key");
          }
        }

        pendingData['changes'] = moduleChangeList.isNotEmpty
            ? moduleChangeList
            : ["No Module Changes"];

        // Save or update the pending module document
        await pendingModuleRef.set(pendingData);

        // Store module changes at course level
        if (moduleChangeList.isNotEmpty) {
          moduleChanges.add({
            'moduleId': moduleId,
            'moduleName': module.moduleName,
            'changes': moduleChangeList
          });
        }
      }

      // Store module changes in the pendingCourses document
      await pendingCourseRef.set({
        'moduleChanges': moduleChanges,
      }, SetOptions(merge: true));

      print("✅ Course & all module edits submitted for review.");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Course & Modules submitted for review!')));
    } catch (e) {
      print("❌ Error submitting pending changes: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit for review.')));
    }

    setState(() {
      _isLoading = false;
    });
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
      }

      // Handle PDF uploads tracking
      Map<String, Uint8List?> pdfFiles = {
        "Module PDF": _selectedPdf,
        "Student Guide": _studentGuidePdf,
        "Facilitator Guide": _facilitatorGuidePdf,
        "Answer Sheet": _answerSheetPdf,
        "Activities": _activitiesPdf,
        "Assessments": _assessmentsPdf,
        "Test Sheet": _testSheetPdf
      };

      for (String key in pdfFiles.keys) {
        if (pdfFiles[key] != null) {
          moduleChangeList.add("Updated $key");
        }
      }

      // Store changes in the module itself
      existingModule.moduleName = _moduleNameController.text;
      existingModule.moduleDescription = _moduleDescriptionController.text;
      existingModule.moduleImage = _selectedImage;
      existingModule.moduleImageUrl = _selectedImageUrl;
      existingModule.modulePdf = _selectedPdf;
      existingModule.modulePdfName = _selectedPdfName;

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

      // **Attach changes to module**
      existingModule.changes = moduleChangeList;

      // **Save changes inside CourseModel**
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
                                  id: '',
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
                              ),
                              child: _selectedImage != null
                                  ? Image.memory(
                                      _selectedImage!,
                                      fit: BoxFit.cover,
                                    )
                                  : (_selectedImageUrl != null &&
                                          _selectedImageUrl!.isNotEmpty)
                                      ? ImageNetwork(
                                          key: ValueKey(_selectedImageUrl),
                                          image: _selectedImageUrl!,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.3,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.3,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          fitWeb: BoxFitWeb.cover,
                                          fitAndroidIos: BoxFit.cover,
                                          onLoading: Center(
                                              child:
                                                  CircularProgressIndicator()),
                                        )
                                      : Center(
                                          child: Icon(
                                            Icons.image,
                                            size: 50,
                                            color: Mycolors().darkGrey,
                                          ),
                                        ),
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
