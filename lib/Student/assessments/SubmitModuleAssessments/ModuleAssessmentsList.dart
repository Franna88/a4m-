import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:a4m/Student/assessments/SubmitModuleAssessments/ModuleContainerSubmit.dart';

class ModuleAssessmentList extends StatefulWidget {
  final String courseId;
  final String studentId;
  final void Function(String moduleId) onTap;

  const ModuleAssessmentList({
    super.key,
    required this.courseId,
    required this.studentId,
    required this.onTap,
  });

  @override
  State<ModuleAssessmentList> createState() => _ModuleAssessmentListState();
}

class _ModuleAssessmentListState extends State<ModuleAssessmentList> {
  late Future<List<Map<String, dynamic>>> _modulesFuture;

  @override
  void initState() {
    super.initState();
    _modulesFuture = fetchModules();
  }

  // 🔹 Fetch modules for the selected course and calculate assessments/submissions
  Future<List<Map<String, dynamic>>> fetchModules() async {
    try {
      QuerySnapshot moduleSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('modules')
          .get();

      List<Map<String, dynamic>> modules = [];

      for (var module in moduleSnapshot.docs) {
        final moduleData = module.data() as Map<String, dynamic>;

        int totalAssessments = 0;
        int submittedAssessments = 0;

        // Count `assessmentsPdfUrl` and `testSheetPdfUrl`
        if (moduleData['assessmentsPdfUrl'] != null &&
            moduleData['assessmentsPdfUrl'].isNotEmpty) {
          totalAssessments++;
        }

        if (moduleData['testSheetPdfUrl'] != null &&
            moduleData['testSheetPdfUrl'].isNotEmpty) {
          totalAssessments++;
        }

        // Fetch submissions for this module and student
        DocumentSnapshot submissionDoc = await FirebaseFirestore.instance
            .collection('courses')
            .doc(widget.courseId)
            .collection('modules')
            .doc(module.id)
            .collection('submissions')
            .doc(widget.studentId)
            .get();

        if (submissionDoc.exists) {
          List<dynamic> submittedFiles =
              submissionDoc['submittedAssessments'] ?? [];
          submittedAssessments = submittedFiles.length;
        }

        modules.add({
          'id': module.id,
          'moduleName': moduleData['moduleName'] ?? 'No Name',
          'moduleImageUrl':
              moduleData['moduleImageUrl'] ?? 'https://via.placeholder.com/320',
          'moduleDescription':
              moduleData['moduleDescription'] ?? 'No Description',
          'totalAssessments': totalAssessments,
          'submittedAssessments': submittedAssessments,
        });
      }

      return modules;
    } catch (e) {
      debugPrint('Error fetching modules: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _modulesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No modules found.'));
              }

              final modules = snapshot.data!;

              return ListView.builder(
                itemCount: modules.length,
                itemBuilder: (context, index) {
                  final module = modules[index];

                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: ModuleContainerSubmit(
                      courseName: module['moduleName'],
                      courseImage: module['moduleImageUrl'],
                      courseDescription: module['moduleDescription'],
                      moduleCount: "1",
                      assessmentCount:
                          "${module['submittedAssessments']} / ${module['totalAssessments']}",
                      onTap: () {
                        widget.onTap(module['id']);
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
