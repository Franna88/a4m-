import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:a4m/Student/ReviewAssessments/ui/reviewAssessmentsItem.dart';

class ReviewAssessmentsList extends StatefulWidget {
  final void Function(String moduleId) onTap;
  final String courseId; // 🔹 Ensure we get the course ID

  const ReviewAssessmentsList({
    super.key,
    required this.onTap,
    required this.courseId, // Receive courseId
  });

  @override
  State<ReviewAssessmentsList> createState() => _ReviewAssessmentsListState();
}

class _ReviewAssessmentsListState extends State<ReviewAssessmentsList> {
  late Future<List<Map<String, dynamic>>> _modulesFuture;

  @override
  void initState() {
    super.initState();
    _modulesFuture = fetchModulesForCourse();
  }

  /// 🔹 Fetch modules and their assessment details for the selected course
  Future<List<Map<String, dynamic>>> fetchModulesForCourse() async {
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
        bool isPassed = false;

        if (moduleData['assessmentsPdfUrl'] != null &&
            moduleData['assessmentsPdfUrl'].isNotEmpty) {
          totalAssessments++;
        }

        if (moduleData['testSheetPdfUrl'] != null &&
            moduleData['testSheetPdfUrl'].isNotEmpty) {
          totalAssessments++;
        }

        // Fetch review status (if module is passed/failed)
        DocumentSnapshot reviewDoc = await FirebaseFirestore.instance
            .collection('courses')
            .doc(widget.courseId)
            .collection('modules')
            .doc(module.id)
            .collection('reviews')
            .doc(widget
                .courseId) // Assuming reviews are stored per course/module
            .get();

        if (reviewDoc.exists) {
          isPassed = reviewDoc['isPassed'] ?? false;
        }

        modules.add({
          'id': module.id,
          'moduleName': moduleData['moduleName'] ?? 'No Name',
          'moduleImageUrl':
              moduleData['moduleImageUrl'] ?? 'https://via.placeholder.com/200',
          'moduleDescription':
              moduleData['moduleDescription'] ?? 'No Description',
          'totalAssessments': totalAssessments,
          'isPassed': isPassed,
        });
      }

      return modules;
    } catch (e) {
      debugPrint('❌ Error fetching modules: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _modulesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('❌ Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('⚠️ No modules found.'));
        }

        final modules = snapshot.data!;

        return Expanded(
          child: ListView.builder(
            itemCount: modules.length,
            itemBuilder: (context, index) {
              final module = modules[index];

              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ReviewAssessmentsItem(
                  moduleName: module['moduleName'],
                  moduleImage: module['moduleImageUrl'],
                  moduleDescription: module['moduleDescription'],
                  moduleCount: "1", // Each module is 1
                  assessmentCount: module['totalAssessments'].toString(),
                  isPassed: module['isPassed'],
                  onTap: () {
                    widget.onTap(module['id']); // Pass moduleId to navigate
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
