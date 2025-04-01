import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:a4m/Student/ReviewAssessments/ui/reviewAssessmentsItem.dart';

class ReviewAssessmentsList extends StatefulWidget {
  final void Function(String moduleId) onTap;
  final String courseId;

  const ReviewAssessmentsList({
    super.key,
    required this.onTap,
    required this.courseId,
  });

  @override
  State<ReviewAssessmentsList> createState() => _ReviewAssessmentsListState();
}

class _ReviewAssessmentsListState extends State<ReviewAssessmentsList> {
  Future<List<Map<String, dynamic>>>? _modulesFuture;
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    _modulesFuture = fetchModules();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> fetchModules() async {
    if (!_mounted) return [];

    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('modules')
          .get();

      if (!_mounted) return [];

      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      debugPrint('Error fetching modules: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _modulesFuture,
      builder: (context, snapshot) {
        if (!_mounted) return const SizedBox();

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No modules found.'));
        }

        final modules = snapshot.data!;

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: modules.length,
          itemBuilder: (context, index) {
            final module = modules[index];

            return ReviewAssessmentsItem(
              moduleName: module['moduleName'] ?? 'No Name',
              moduleImage:
                  module['moduleImageUrl'] ?? 'https://picsum.photos/400',
              moduleDescription:
                  module['moduleDescription'] ?? 'No Description',
              moduleCount: "1",
              assessmentCount:
                  (module['assessmentsPdfUrl'] != null ? 1 : 0).toString(),
              isPassed: false,
              onTap: () => widget.onTap(module['id']),
            );
          },
        );
      },
    );
  }
}
