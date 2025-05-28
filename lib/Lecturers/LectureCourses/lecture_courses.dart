import 'package:a4m/CommonComponents/inputFields/mySearchBar.dart';
import 'package:a4m/Lecturers/LectureCourses/lecture_course_containers.dart';
import 'package:a4m/myutility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Constants/myColors.dart';

class LectureCourses extends StatefulWidget {
  final Function(int, {String courseId, String moduleId})
      changePageWithCourseId;
  final String lecturerId;

  const LectureCourses({
    super.key,
    required this.changePageWithCourseId,
    required this.lecturerId,
  });

  @override
  State<LectureCourses> createState() => _LectureCoursesState();
}

class _LectureCoursesState extends State<LectureCourses> {
  List<Map<String, dynamic>> assignedCourses = [];
  List<Map<String, dynamic>> filteredCourses = [];
  bool isLoading = true;
  bool isHovered = false;
  String searchQuery = '';
  late TextEditingController searchController;

  // Fetch courses assigned to this lecturer
  Future<void> fetchAssignedCourses() async {
    try {
      print("Fetching courses for Lecturer: ${widget.lecturerId}");
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .where('assignedLecturers', isNotEqualTo: null)
          .get();
      List<Map<String, dynamic>> tempCourses = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final assignedLecturers = data['assignedLecturers'] as List<dynamic>?;
        if (assignedLecturers != null) {
          for (var lecturer in assignedLecturers) {
            if (lecturer['id'].toString().trim() == widget.lecturerId.trim()) {
              QuerySnapshot moduleSnapshot = await FirebaseFirestore.instance
                  .collection('courses')
                  .doc(doc.id)
                  .collection('modules')
                  .get();
              int totalAssessments = 0;
              for (var module in moduleSnapshot.docs) {
                final moduleData = module.data() as Map<String, dynamic>;
                if (moduleData.containsKey('assessmentsPdfUrl')) {
                  totalAssessments++;
                }
              }
              List students = data['students'] ?? [];
              tempCourses.add({
                'id': doc.id,
                'courseName': data['courseName'] ?? 'No Name',
                'courseDescription': data['courseDescription'] ?? '',
                'courseImage': data['courseImageUrl'] ?? '',
                'moduleAmount': moduleSnapshot.size,
                'totalStudents': students.length.toString(),
                'totalAssessments': totalAssessments.toString(),
              });
              break;
            }
          }
        }
      }
      setState(() {
        assignedCourses = tempCourses;
        filteredCourses = tempCourses;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching courses: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterCourses(String query) {
    setState(() {
      searchQuery = query;
      filteredCourses = assignedCourses.where((course) {
        final name = course['courseName']?.toLowerCase() ?? '';
        final desc = course['courseDescription']?.toLowerCase() ?? '';
        return name.contains(query.toLowerCase()) ||
            desc.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    fetchAssignedCourses();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = (screenWidth ~/ 400).clamp(1, 3);
    return Container(
      width: screenWidth - 320,
      height: MediaQuery.of(context).size.height - 80,
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Courses',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(
                    width: 300,
                    height: 50,
                    child: MySearchBar(
                      textController: searchController,
                      hintText: 'Search Course',
                      onChanged: _filterCourses,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Divider(
                color: Mycolors().green,
                thickness: 4,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredCourses.isEmpty
                        ? Center(
                            child: Text(
                              'No courses assigned yet.',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            child: LayoutGrid(
                              columnSizes: List.generate(
                                crossAxisCount,
                                (_) => const FlexibleTrackSize(1),
                              ),
                              rowSizes: List.generate(
                                (filteredCourses.length / crossAxisCount)
                                    .ceil(),
                                (_) => auto,
                              ),
                              rowGap: 20,
                              columnGap: 20,
                              children: [
                                for (var course in filteredCourses)
                                  MouseRegion(
                                    onEnter: (_) =>
                                        setState(() => isHovered = true),
                                    onExit: (_) =>
                                        setState(() => isHovered = false),
                                    child: GestureDetector(
                                      onTap: () {
                                        print(
                                            "Navigating to Modules for Course ID: ${course['id']}");
                                        widget.changePageWithCourseId(
                                          6,
                                          courseId: course['id'],
                                        );
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.1),
                                              spreadRadius: isHovered ? 2 : 1,
                                              blurRadius: isHovered ? 15 : 10,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: LectureCourseContainers(
                                          courseName: course['courseName'],
                                          modulesComplete:
                                              course['moduleAmount'].toString(),
                                          courseDescription:
                                              course['courseDescription'],
                                          totalStudents:
                                              course['totalStudents'],
                                          moduleAmount:
                                              course['moduleAmount'].toString(),
                                          assessmentAmount:
                                              course['totalAssessments'],
                                          courseImage: course['courseImage'],
                                          courseId: course['id'],
                                          onTap: () {},
                                          changePage: (index,
                                                  {String? courseId,
                                                  String? moduleId}) =>
                                              widget.changePageWithCourseId(
                                            index,
                                            courseId: courseId ?? course['id'],
                                            moduleId: moduleId ?? '',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
