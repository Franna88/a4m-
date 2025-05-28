import 'package:a4m/Constants/myColors.dart';
import 'package:a4m/Lecturers/LectureDashboard/dashboard_card.dart';
import 'package:a4m/Lecturers/LectureDashboard/reusable_dash_module_container.dart';
import 'package:a4m/myutility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NewlySubmitedModules extends StatefulWidget {
  final String lecturerId;
  final Function(int, {String courseId, String moduleId})
      changePageWithCourseId;

  const NewlySubmitedModules(
      {super.key,
      required this.lecturerId,
      required this.changePageWithCourseId});

  @override
  State<NewlySubmitedModules> createState() => _NewlySubmitedModulesState();
}

class _NewlySubmitedModulesState extends State<NewlySubmitedModules> {
  List<Map<String, dynamic>> recentSubmissions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRecentSubmissions();
  }

  Future<void> fetchRecentSubmissions() async {
    try {
      if (widget.lecturerId.isEmpty) {
        if (mounted) {
          setState(() => isLoading = false);
        }
        return;
      }

      final DateTime oneWeekAgo =
          DateTime.now().subtract(const Duration(days: 7));
      List<Map<String, dynamic>> tempSubmissions = [];

      final coursesSnapshot =
          await FirebaseFirestore.instance.collection('courses').get();

      for (var courseDoc in coursesSnapshot.docs) {
        if (!courseDoc.exists) continue;

        final courseData = courseDoc.data();
        final assignedLecturers =
            courseData['assignedLecturers'] as List<dynamic>?;

        if (assignedLecturers != null) {
          bool lecturerFound = assignedLecturers.any((lecturer) =>
              lecturer is Map<String, dynamic> &&
              lecturer['id'] == widget.lecturerId);

          if (lecturerFound && courseDoc.id.isNotEmpty) {
            final modulesSnapshot =
                await courseDoc.reference.collection('modules').get();

            for (var moduleDoc in modulesSnapshot.docs) {
              if (!moduleDoc.exists) continue;

              final moduleData = moduleDoc.data();
              final submissionsSnapshot =
                  await moduleDoc.reference.collection('submissions').get();

              for (var submissionDoc in submissionsSnapshot.docs) {
                if (!submissionDoc.exists) continue;

                final submissionData = submissionDoc.data();
                final submittedAssessments =
                    submissionData['submittedAssessments'] as List<dynamic>?;

                if (submittedAssessments != null) {
                  for (var assessment in submittedAssessments) {
                    if (assessment == null ||
                        assessment is! Map<String, dynamic>) continue;

                    final submittedTimestamp = assessment['submittedAt'];
                    if (submittedTimestamp == null) continue;

                    DateTime submissionDate;
                    if (submittedTimestamp is Timestamp) {
                      submissionDate = submittedTimestamp.toDate();
                    } else if (submittedTimestamp is String) {
                      submissionDate = DateTime.parse(submittedTimestamp);
                    } else {
                      continue;
                    }

                    if (submissionDate.isAfter(oneWeekAgo)) {
                      tempSubmissions.add({
                        'name': assessment['studentName'] ?? 'Unknown Student',
                        'moduleName':
                            moduleData['moduleName'] ?? 'Unknown Module',
                        'moduleNumber':
                            moduleData['moduleName'] ?? 'Unknown Module',
                        'moduleType': assessment['assessmentName'] ??
                            'Unknown Assessment',
                        'submitted': submissionDate.toString(),
                        'mark': assessment['mark']?.toString() ?? 'N/A',
                        'comment': assessment['comment'] ?? '',
                        'courseId': courseDoc.id,
                        'moduleId': moduleDoc.id,
                        'studentId': submissionDoc.id,
                        'assessmentName': assessment['assessmentName'],
                        'fileUrl': assessment['fileUrl'],
                      });
                    }
                  }
                }
              }
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          recentSubmissions = tempSubmissions;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    recentSubmissions.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      title: 'Newly Submitted',
      height: MyUtility(context).height * 0.31,
      width: MyUtility(context).width * 0.52,
      actions: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Mycolors().green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${recentSubmissions.length} submissions',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  color: Mycolors().green,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_upward,
                color: Mycolors().green,
                size: 16,
              ),
            ],
          ),
        ),
      ],
      content: isLoading
          ? const Center(child: CircularProgressIndicator())
          : recentSubmissions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No newly submitted modules found',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: recentSubmissions.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final module = recentSubmissions[index];
                    return ReusableDashModuleContainer(
                      name: module['name'],
                      moduleName: module['moduleName'],
                      moduleNumber: module['moduleNumber'],
                      moduleType: module['moduleType'],
                      onTap: () {
                        widget.changePageWithCourseId(
                          6,
                          courseId: module['courseId'],
                          moduleId: '',
                        );
                      },
                    );
                  },
                ),
    );
  }
}
