import 'package:flutter/material.dart';
import 'dart:typed_data';

class CourseModel with ChangeNotifier {
  String courseName = '';
  String coursePrice = '';
  String courseCategory = '';
  String courseDescription = '';
  Uint8List? courseImage; // Raw image data
  String? courseImageUrl; // 🔥 Image URL field
  Uint8List? previewPdf;
  String? previewPdfUrl;
  String? previewPdfName;
  List<Module> modules = [];
  bool isNewCourse = true;

  void setCourseName(String name) {
    courseName = name;
    notifyListeners();
  }

  void setCoursePrice(String price) {
    coursePrice = price;
    notifyListeners();
  }

  void setCourseCategory(String category) {
    courseCategory = category;
    notifyListeners();
  }

  void setCourseDescription(String description) {
    courseDescription = description;
    notifyListeners();
  }

  void setCourseImage(Uint8List? image) {
    courseImage = image;
    notifyListeners();
  }

  void setCourseImageUrl(String? imageUrl) {
    // 🔥 New method
    courseImageUrl = imageUrl;
    notifyListeners();
  }

  void setPreviewPdf(Uint8List? pdf, String? name) {
    previewPdf = pdf;
    previewPdfName = name;
    notifyListeners();
  }

  void setPreviewPdfUrl(String? url) {
    previewPdfUrl = url;
    notifyListeners();
  }

  void addModule(Module module) {
    modules.add(module);
    notifyListeners();
    print('Module added: ${module.moduleName}');
  }

  void updateModule(int index, Module updatedModule) {
    if (index >= 0 && index < modules.length) {
      modules[index] = updatedModule;
      notifyListeners();
      print('Module updated at index $index: ${updatedModule.moduleName}');
    } else {
      print('Invalid index when updating module: $index');
    }
  }

  void removeModule(int index) {
    if (index >= 0 && index < modules.length) {
      print('Module removed at index $index: ${modules[index].moduleName}');
      modules.removeAt(index);
      notifyListeners();
    } else {
      print('Invalid index when removing module: $index');
    }
  }

  void clearCourseData() {
    courseName = '';
    coursePrice = '';
    courseCategory = '';
    courseDescription = '';
    courseImage = null;
    courseImageUrl = null; // 🔥 Reset the image URL
    previewPdf = null;
    previewPdfUrl = null;
    previewPdfName = null;
    modules.clear();
    notifyListeners();
  }

  Map<String, dynamic> toMap() {
    return {
      'courseName': courseName,
      'coursePrice': coursePrice,
      'courseCategory': courseCategory,
      'courseDescription': courseDescription,
      'courseImageUrl': courseImageUrl, // 🔥 Store URL instead of raw image
      'modules': modules.map((module) => module.toMap()).toList(),
      'isNewCourse': isNewCourse,
    };
  }
}

class Module with ChangeNotifier {
  String moduleName;
  String moduleDescription;

  // Module Image (both local data & Firestore URL)
  Uint8List? moduleImage;
  String? moduleImageUrl; // ✅ Stores existing image URL from Firestore

  // Module PDF (both local data & Firestore URL)
  Uint8List? modulePdf;
  String? modulePdfName;
  String? modulePdfUrl; // ✅ Stores existing module PDF URL from Firestore

  // Additional PDFs (both local files and Firestore URLs)
  Uint8List? studentGuidePdf;
  String? studentGuidePdfName;
  String? studentGuidePdfUrl; // ✅ Firestore URL

  Uint8List? facilitatorGuidePdf;
  String? facilitatorGuidePdfName;
  String? facilitatorGuidePdfUrl; // ✅ Firestore URL

  Uint8List? answerSheetPdf;
  String? answerSheetPdfName;
  String? answerSheetPdfUrl; // ✅ Firestore URL

  Uint8List? activitiesPdf;
  String? activitiesPdfName;
  String? activitiesPdfUrl; // ✅ Firestore URL

  Uint8List? assessmentsPdf;
  String? assessmentsPdfName;
  String? assessmentsPdfUrl; // ✅ Firestore URL

  Uint8List? testSheetPdf;
  String? testSheetPdfName;
  String? testSheetPdfUrl; // ✅ Firestore URL

  Uint8List? assignmentsPdf;
  String? assignmentsPdfName;
  String? assignmentsPdfUrl; // ✅ Firestore URL

  List<Question> questions;
  List<Task> tasks;
  List<Assignment> assignments;

  List<String> changes;
  String id;

  Module({
    required this.moduleName,
    required this.moduleDescription,
    this.moduleImage,
    this.moduleImageUrl, // ✅ Firestore URL
    this.modulePdf,
    this.modulePdfName,
    this.modulePdfUrl, // ✅ Firestore URL
    this.studentGuidePdf,
    this.studentGuidePdfName,
    this.studentGuidePdfUrl, // ✅ Firestore URL
    this.facilitatorGuidePdf,
    this.facilitatorGuidePdfName,
    this.facilitatorGuidePdfUrl, // ✅ Firestore URL
    this.answerSheetPdf,
    this.answerSheetPdfName,
    this.answerSheetPdfUrl, // ✅ Firestore URL
    this.activitiesPdf,
    this.activitiesPdfName,
    this.activitiesPdfUrl, // ✅ Firestore URL
    this.assessmentsPdf,
    this.assessmentsPdfName,
    this.assessmentsPdfUrl, // ✅ Firestore URL
    this.testSheetPdf,
    this.testSheetPdfName,
    this.testSheetPdfUrl, // ✅ Firestore URL
    this.assignmentsPdf,
    this.assignmentsPdfName,
    this.assignmentsPdfUrl, // ✅ Firestore URL
    this.changes = const [],
    List<Question>? questions,
    List<Task>? tasks,
    List<Assignment>? assignments,
    required this.id,
  })  : questions = questions ?? [],
        tasks = tasks ?? [],
        assignments = assignments ?? [];

  // ✅ Add Question
  void addQuestion(Question question) {
    questions.add(question);
    notifyListeners(); // ✅ UI updates after adding a question
    print('Question added: ${question.questionText}');
  }

  // ✅ Update Question
  void updateQuestion(int index, Question updatedQuestion) {
    if (index >= 0 && index < questions.length) {
      questions[index] = updatedQuestion;
      notifyListeners(); // ✅ UI updates after question update
      print(
          'Question updated at index $index: ${updatedQuestion.questionText}');
    } else {
      print('Invalid index when updating question: $index');
    }
  }

  // ✅ Remove Question
  void removeQuestion(int index) {
    if (index >= 0 && index < questions.length) {
      print(
          'Question removed at index $index: ${questions[index].questionText}');
      questions.removeAt(index);
      notifyListeners(); // ✅ UI updates after question removal
    } else {
      print('Invalid index when removing question: $index');
    }
  }

  // ✅ Add Task
  void addTask(Task task) {
    tasks.add(task);
    notifyListeners(); // ✅ UI updates after adding a task
    print('Task added: ${task.title}');
  }

  // ✅ Remove Task
  void removeTask(int index) {
    if (index >= 0 && index < tasks.length) {
      print('Task removed at index $index: ${tasks[index].title}');
      tasks.removeAt(index);
      notifyListeners(); // ✅ UI updates after task removal
    } else {
      print('Invalid index when removing task: $index');
    }
  }

  // ✅ Add Assignment
  void addAssignment(Assignment assignment) {
    assignments.add(assignment);
    notifyListeners(); // ✅ UI updates after adding an assignment
    print('Assignment added: ${assignment.title}');
  }

  // ✅ Remove Assignment
  void removeAssignment(int index) {
    if (index >= 0 && index < assignments.length) {
      print('Assignment removed at index $index: ${assignments[index].title}');
      assignments.removeAt(index);
      notifyListeners(); // ✅ UI updates after assignment removal
    } else {
      print('Invalid index when removing assignment: $index');
    }
  }

  // ✅ Convert Module to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'moduleName': moduleName,
      'moduleDescription': moduleDescription,

      // ✅ Store URLs instead of base64 encoding
      'moduleImageUrl': moduleImageUrl,
      'modulePdfUrl': modulePdfUrl,
      'modulePdfName': modulePdfName,

      'studentGuidePdfUrl': studentGuidePdfUrl,
      'studentGuidePdfName': studentGuidePdfName,

      'facilitatorGuidePdfUrl': facilitatorGuidePdfUrl,
      'facilitatorGuidePdfName': facilitatorGuidePdfName,

      'answerSheetPdfUrl': answerSheetPdfUrl,
      'answerSheetPdfName': answerSheetPdfName,

      'activitiesPdfUrl': activitiesPdfUrl,
      'activitiesPdfName': activitiesPdfName,

      'assessmentsPdfUrl': assessmentsPdfUrl,
      'assessmentsPdfName': assessmentsPdfName,

      'testSheetPdfUrl': testSheetPdfUrl,
      'testSheetPdfName': testSheetPdfName,

      'assignmentsPdfUrl': assignmentsPdfUrl,
      'assignmentsPdfName': assignmentsPdfName,

      'questions': questions.map((q) => q.toMap()).toList(),
      'tasks': tasks.map((t) => t.toMap()).toList(),
      'assignments': assignments.map((a) => a.toMap()).toList(),
      'changes': changes,
    };
  }
}

class Question {
  String questionText;
  String questionType;
  List<String> options;
  String correctAnswer;

  Question({
    required this.questionText,
    required this.questionType,
    List<String>? options,
    required this.correctAnswer,
  }) : options = options ?? [];

  // Convert Question to a Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'questionText': questionText,
      'questionType': questionType,
      'options': options,
      'correctAnswer': correctAnswer,
    };
  }
}

class Task {
  String title;

  Task({required this.title});

  // Convert Task to a Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'title': title,
    };
  }
}

class Assignment {
  String title;

  Assignment({required this.title});

  // Convert Assignment to a Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'title': title,
    };
  }
}
