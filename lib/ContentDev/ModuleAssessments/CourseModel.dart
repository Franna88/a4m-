import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:typed_data';

class CourseModel with ChangeNotifier {
  String courseName = '';
  String coursePrice = '';
  String courseCategory = '';
  String courseDescription = '';
  Uint8List? courseImage;
  List<Module> modules = [];

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

  // Convert the CourseModel to a Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'courseName': courseName,
      'coursePrice': coursePrice,
      'courseCategory': courseCategory,
      'courseDescription': courseDescription,
      'courseImage': courseImage != null ? base64Encode(courseImage!) : null,
      'modules': modules.map((module) => module.toMap()).toList(),
    };
  }
}

class Module {
  String moduleName;
  String moduleDescription;
  Uint8List? modulePdf;
  String? modulePdfName;
  Uint8List? moduleImage;

  // New fields for six additional PDFs
  Uint8List? studentGuidePdf;
  String? studentGuidePdfName;
  Uint8List? facilitatorGuidePdf;
  String? facilitatorGuidePdfName;
  Uint8List? answerSheetPdf;
  String? answerSheetPdfName;
  Uint8List? activitiesPdf;
  String? activitiesPdfName;
  Uint8List? assessmentsPdf;
  String? assessmentsPdfName;
  Uint8List? testSheetPdf;
  String? testSheetPdfName;

  List<Question> questions;
  List<Task> tasks;
  List<Assignment> assignments;

  Module({
    required this.moduleName,
    required this.moduleDescription,
    this.modulePdf,
    this.modulePdfName,
    this.moduleImage,
    this.studentGuidePdf,
    this.studentGuidePdfName,
    this.facilitatorGuidePdf,
    this.facilitatorGuidePdfName,
    this.answerSheetPdf,
    this.answerSheetPdfName,
    this.activitiesPdf,
    this.activitiesPdfName,
    this.assessmentsPdf,
    this.assessmentsPdfName,
    this.testSheetPdf,
    this.testSheetPdfName,
    List<Question>? questions,
    List<Task>? tasks,
    List<Assignment>? assignments,
  })  : questions = questions ?? [],
        tasks = tasks ?? [],
        assignments = assignments ?? [];

  void addQuestion(Question question) {
    questions.add(question);
    print('Question added: ${question.questionText}');
  }

  void updateQuestion(int index, Question updatedQuestion) {
    if (index >= 0 && index < questions.length) {
      questions[index] = updatedQuestion;
      print(
          'Question updated at index $index: ${updatedQuestion.questionText}');
    } else {
      print('Invalid index when updating question: $index');
    }
  }

  void removeQuestion(int index) {
    if (index >= 0 && index < questions.length) {
      print(
          'Question removed at index $index: ${questions[index].questionText}');
      questions.removeAt(index);
    } else {
      print('Invalid index when removing question: $index');
    }
  }

  void addTask(Task task) {
    tasks.add(task);
    print('Task added: ${task.title}');
  }

  void removeTask(int index) {
    if (index >= 0 && index < tasks.length) {
      print('Task removed at index $index: ${tasks[index].title}');
      tasks.removeAt(index);
    } else {
      print('Invalid index when removing task: $index');
    }
  }

  void addAssignment(Assignment assignment) {
    assignments.add(assignment);
    print('Assignment added: ${assignment.title}');
  }

  void removeAssignment(int index) {
    if (index >= 0 && index < assignments.length) {
      print('Assignment removed at index $index: ${assignments[index].title}');
      assignments.removeAt(index);
    } else {
      print('Invalid index when removing assignment: $index');
    }
  }

  // Convert Module to a Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'moduleName': moduleName,
      'moduleDescription': moduleDescription,
      'modulePdfName': modulePdfName,
      'modulePdf': modulePdf != null ? base64Encode(modulePdf!) : null,
      'moduleImage': moduleImage != null ? base64Encode(moduleImage!) : null,
      'studentGuidePdf':
          studentGuidePdf != null ? base64Encode(studentGuidePdf!) : null,
      'studentGuidePdfName': studentGuidePdfName,
      'facilitatorGuidePdf': facilitatorGuidePdf != null
          ? base64Encode(facilitatorGuidePdf!)
          : null,
      'facilitatorGuidePdfName': facilitatorGuidePdfName,
      'answerSheetPdf':
          answerSheetPdf != null ? base64Encode(answerSheetPdf!) : null,
      'answerSheetPdfName': answerSheetPdfName,
      'activitiesPdf':
          activitiesPdf != null ? base64Encode(activitiesPdf!) : null,
      'activitiesPdfName': activitiesPdfName,
      'assessmentsPdf':
          assessmentsPdf != null ? base64Encode(assessmentsPdf!) : null,
      'assessmentsPdfName': assessmentsPdfName,
      'testSheetPdf': testSheetPdf != null ? base64Encode(testSheetPdf!) : null,
      'testSheetPdfName': testSheetPdfName,
      'questions': questions.map((q) => q.toMap()).toList(),
      'tasks': tasks.map((t) => t.toMap()).toList(),
      'assignments': assignments.map((a) => a.toMap()).toList(),
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
