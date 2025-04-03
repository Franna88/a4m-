import 'package:a4m/Admin/AdminMarketing/adminCourseDetailsPopup/adminCourseDetailsPopup.dart';
import 'package:a4m/Admin/AdminMarketing/ui/adminCourseContainers.dart';
import 'package:a4m/CommonComponents/inputFields/myDropDownMenu.dart';
import 'package:a4m/CommonComponents/inputFields/mySearchBar.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminMarketing extends StatefulWidget {
  const AdminMarketing({super.key});

  @override
  State<AdminMarketing> createState() => _AdminMarketingState();
}

class _AdminMarketingState extends State<AdminMarketing> {
  List<Map<String, dynamic>> courses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllCourses();
  }

  Future<void> _fetchAllCourses() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot coursesSnapshot =
          await firestore.collection('courses').get();

      List<Map<String, dynamic>> fetchedCourses = [];

      for (var doc in coursesSnapshot.docs) {
        final courseData = doc.data() as Map<String, dynamic>;

        // Get student count
        int studentCount =
            (courseData['students'] as List<dynamic>? ?? []).length;

        // Get modules count
        QuerySnapshot moduleSnapshot = await firestore
            .collection('courses')
            .doc(doc.id)
            .collection('modules')
            .get();
        int moduleCount = moduleSnapshot.docs.length;

        // Get assessment count
        int assessmentCount = 0;
        for (var module in moduleSnapshot.docs) {
          final moduleData = module.data() as Map<String, dynamic>;
          if (moduleData['assessmentsPdfUrl'] != null &&
              moduleData['assessmentsPdfUrl'].isNotEmpty) {
            assessmentCount++;
          }
        }

        fetchedCourses.add({
          ...courseData,
          'courseId': doc.id,
          'studentCount': studentCount,
          'moduleCount': moduleCount,
          'assessmentCount': assessmentCount,
        });
      }

      setState(() {
        courses = fetchedCourses;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching courses: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> openCourseDetailsPopup(Map<String, dynamic> course) async {
    bool? shouldRefresh = await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: AdminCourseDetailsPopup(course: course),
        );
      },
    );

    if (shouldRefresh == true) {
      _fetchAllCourses(); // Re-fetch course data
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseSearch = TextEditingController();
    final courseCategorySelect = TextEditingController();

    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = (screenWidth ~/ 400).clamp(1, 6);

    return SizedBox(
      width: MyUtility(context).width - 320,
      height: MyUtility(context).height - 80,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 300,
                  height: 50,
                  child: MySearchBar(
                    textController: courseSearch,
                    hintText: 'Search Course',
                  ),
                ),
                const SizedBox(width: 20),
                MyDropDownMenu(
                  description: 'Course Category',
                  customSize: 300,
                  items: [],
                  textfieldController: courseCategorySelect,
                ),
              ],
            ),
            const SizedBox(height: 30),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: LayoutGrid(
                        columnSizes: List.generate(
                          crossAxisCount,
                          (_) => FlexibleTrackSize(1),
                        ),
                        rowSizes: List.generate(
                          (courses.length / crossAxisCount).ceil(),
                          (_) => auto,
                        ),
                        rowGap: 20,
                        columnGap: 20,
                        children: [
                          for (var course in courses)
                            SizedBox(
                              width: 320,
                              height: 340,
                              child: AdminCourseContainers(
                                courseName: course['courseName'] ?? 'Unknown',
                                price: course['coursePrice']?.toString() ?? '0',
                                courseDescription:
                                    course['courseDescription'] ?? '',
                                totalStudents:
                                    course['studentCount']?.toString() ?? '0',
                                moduleAmount:
                                    course['moduleCount']?.toString() ?? '0',
                                assessmentAmount:
                                    course['assessmentCount']?.toString() ??
                                        '0',
                                courseImage: course['courseImageUrl'] ??
                                    'https://via.placeholder.com/150',
                                status: course['status'] ?? 'approved',
                                onTap: () => openCourseDetailsPopup(course),
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
