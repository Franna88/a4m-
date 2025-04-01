import 'package:a4m/Constants/myColors.dart';
import 'package:a4m/Lecturers/LectureDashboard/reusable_dash_module_container.dart';
import 'package:a4m/myutility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NewlySubmitedModules extends StatefulWidget {
  final String lecturerId;
  final Function(int, {String courseId, String moduleId})
      changePageWithCourseId;

  const NewlySubmitedModules(
      {Key? key,
      required this.lecturerId,
      required this.changePageWithCourseId})
      : super(key: key);

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
    print("Fetching recent submissions for lecturerId: ${widget.lecturerId}");
    try {
      // Validate lecturer ID
      if (widget.lecturerId.isEmpty) {
        print("Error: Lecturer ID is empty");
        setState(() => isLoading = false);
        return;
      }

      final DateTime oneWeekAgo =
          DateTime.now().subtract(const Duration(days: 7));
      print("Looking for submissions after: $oneWeekAgo");

      List<Map<String, dynamic>> tempSubmissions = [];

      // Step 1: Fetch all courses
      final coursesSnapshot =
          await FirebaseFirestore.instance.collection('courses').get();

      print("Fetched ${coursesSnapshot.docs.length} courses.");

      for (var courseDoc in coursesSnapshot.docs) {
        // Skip if course doc is invalid
        if (!courseDoc.exists) continue;

        final courseData = courseDoc.data();
        if (courseData == null) continue;

        // Check if the lecturer is assigned
        final assignedLecturers =
            courseData['assignedLecturers'] as List<dynamic>?;
        if (assignedLecturers != null) {
          bool lecturerFound = assignedLecturers.any((lecturer) =>
              lecturer is Map<String, dynamic> &&
              lecturer['id'] == widget.lecturerId);

          if (lecturerFound) {
            print("Course '${courseData['courseName']}' assigned to lecturer.");

            // Skip if course ID is empty
            if (courseDoc.id.isEmpty) continue;

            // Step 2: Get modules in the course
            final modulesSnapshot =
                await courseDoc.reference.collection('modules').get();

            for (var moduleDoc in modulesSnapshot.docs) {
              // Skip if module doc is invalid
              if (!moduleDoc.exists) continue;

              final moduleData = moduleDoc.data();
              if (moduleData == null) continue;

              final studentAssessments =
                  moduleData['studentAssessment'] as List<dynamic>?;

              if (studentAssessments != null) {
                for (var submission in studentAssessments) {
                  if (submission == null || submission is! Map<String, dynamic>)
                    continue;

                  final submittedTimestamp =
                      submission['submitted'] as Timestamp?;
                  if (submittedTimestamp == null) continue;

                  DateTime submissionDate = submittedTimestamp.toDate();

                  if (submissionDate.isAfter(oneWeekAgo)) {
                    tempSubmissions.add({
                      'name': submission['name'] ?? 'Unknown Student',
                      'moduleName':
                          courseData['courseName'] ?? 'Unknown Course',
                      'moduleNumber':
                          moduleData['moduleName'] ?? 'Unknown Module',
                      'moduleType': 'Assessment',
                      'submitted': submissionDate.toString(),
                      'mark': submission['mark'] ?? 'N/A',
                      'comment': submission['comment'] ?? '',
                      'courseId': courseDoc.id,
                    });

                    print(
                        "Added submission: ${submission['name']} on ${moduleData['moduleName']} (${courseData['courseName']})");
                  }
                }
              }
            }
          }
        }
      }

      setState(() {
        recentSubmissions = tempSubmissions;
        isLoading = false;
      });

      print("Total submissions fetched: ${recentSubmissions.length}");
    } catch (e) {
      print("Error fetching submissions: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MyUtility(context).width * 0.52,
        height: MyUtility(context).height * 0.31,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              blurRadius: 2.0,
              spreadRadius: 2.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Newly Submitted',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : recentSubmissions.isEmpty
                    ? const Center(
                        child: Text('No newly submitted modules found.'),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: recentSubmissions.length,
                          itemBuilder: (context, index) {
                            final module = recentSubmissions[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: ReusableDashModuleContainer(
                                name: module['name'],
                                moduleName:
                                    module['moduleName'], // Course Name first
                                moduleNumber: module[
                                    'moduleNumber'], // Module Name second
                                moduleType: module['moduleType'],
                                onTap: () {
                                  print(
                                      "Navigating to Modules for Course ID: ${module['courseId']}");
                                  widget.changePageWithCourseId(6,
                                      courseId: module['courseId'],
                                      moduleId: '');
                                },
                              ),
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
