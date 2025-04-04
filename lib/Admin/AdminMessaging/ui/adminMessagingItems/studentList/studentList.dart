import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../CommonComponents/inputFields/mySearchBar.dart';
import '../../../../../myutility.dart';
import '../../../../AdminA4mMembers/ui/memberContainers.dart';
import '../../../../../CommonComponents/dialogs/submitUserReportDialog.dart';

class StudentList extends StatefulWidget {
  final Function(String id, String name, String userType)? onStudentSelected;
  final String? currentUserId;

  const StudentList({
    super.key,
    this.onStudentSelected,
    this.currentUserId,
  });

  @override
  State<StudentList> createState() => _StudentListState();
}

class _StudentListState extends State<StudentList> {
  final TextEditingController searchStudent = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    searchStudent.addListener(() {
      setState(() {
        searchQuery = searchStudent.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    searchStudent.dispose();
    super.dispose();
  }

  void _showReportDialog(
      BuildContext context, String studentId, String studentName) {
    showDialog(
      context: context,
      builder: (context) => SubmitUserReportDialog(
        userId: studentId,
        userName: studentName,
        userType: 'student',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double itemWidth = 200;
    int columns = 1;

    if (screenWidth > 800) {
      columns = ((screenWidth - 300) / itemWidth).floor().clamp(1, 3);
    }

    return Container(
      width: double.infinity,
      height: MyUtility(context).height - 110,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 300,
            child: MySearchBar(
              textController: searchStudent,
              hintText: 'Search Students',
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .where('userType', isEqualTo: 'student')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error.toString()}'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No students found'));
                }

                final students = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  data['uid'] = doc.id;
                  return data;
                }).where((student) {
                  final name = (student['name'] ?? '').toString().toLowerCase();
                  final id = student['uid'] ?? '';
                  // Filter out current user and apply search
                  return id != widget.currentUserId &&
                      (searchQuery.isEmpty || name.contains(searchQuery));
                }).toList();

                if (students.isEmpty) {
                  return const Center(
                    child: Text('No students match your search'),
                  );
                }

                return SizedBox(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: LayoutGrid(
                      gridFit: GridFit.loose,
                      columnSizes: List.generate(columns, (index) => 1.fr),
                      rowSizes: List.generate(students.length, (index) => auto),
                      rowGap: 15,
                      columnGap: 8,
                      children: students.map((student) {
                        final studentId = student['uid'] ?? '';
                        final name = student['name'] ?? 'Unknown';
                        final phone = student['phoneNumber'] ?? '';
                        final profileImage = student['profileImageUrl'] ?? '';
                        final userType = student['userType'] ?? 'student';

                        // Get enrolled courses data
                        List<String> courses = [];
                        if (student['enrolledCourses'] != null) {
                          if (student['enrolledCourses'] is List) {
                            courses = List<String>.from(
                                student['enrolledCourses'].map((course) {
                              if (course is Map) {
                                return course['courseTitle'] ??
                                    'Untitled Course';
                              } else {
                                return course.toString();
                              }
                            }));
                          } else if (student['enrolledCourses'] is Map) {
                            courses = List<String>.from(
                                (student['enrolledCourses'] as Map)
                                    .values
                                    .map((course) {
                              if (course is Map) {
                                return course['courseTitle'] ??
                                    'Untitled Course';
                              } else {
                                return course.toString();
                              }
                            }));
                          }
                        }

                        return MemberContainers(
                          image: profileImage.isNotEmpty
                              ? profileImage
                              : 'images/person1.png',
                          name: name,
                          number: phone,
                          isLecturer: false,
                          studentAmount: courses.length.toString(),
                          onTap: () {
                            if (widget.onStudentSelected != null) {
                              widget.onStudentSelected!(
                                  studentId, name, userType);
                            }
                          },
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.report_problem,
                              size: 20,
                              color: Colors.grey,
                            ),
                            onPressed: () =>
                                _showReportDialog(context, studentId, name),
                            tooltip: 'Submit report about $name',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
