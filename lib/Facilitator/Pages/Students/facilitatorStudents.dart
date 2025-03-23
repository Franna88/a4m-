import 'package:a4m/CommonComponents/inputFields/myDropDownMenu.dart';
import 'package:a4m/CommonComponents/inputFields/mySearchBar.dart';
import 'package:a4m/Lecturers/LectureStudents/lecture_student_containers.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FacilitatorStudents extends StatefulWidget {
  final String facilitatorId;
  const FacilitatorStudents({super.key, this.facilitatorId = ''});

  @override
  State<FacilitatorStudents> createState() => _FacilitatorStudentsState();
}

class _FacilitatorStudentsState extends State<FacilitatorStudents> {
  List<Map<String, dynamic>> students = [];
  bool isLoading = true;
  String sortOption = 'A-Z';
  String filterOption = 'All';

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    try {
      if (widget.facilitatorId.isEmpty) {
        setState(() {
          isLoading = false;
          students = [];
        });
        return;
      }

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot studentsSnapshot = await firestore
          .collection('Users')
          .doc(widget.facilitatorId)
          .collection('facilitatorStudents')
          .get();

      List<Map<String, dynamic>> fetchedStudents = [];
      for (var doc in studentsSnapshot.docs) {
        Map<String, dynamic> studentData = doc.data() as Map<String, dynamic>;
        // Fetch additional user data if available
        try {
          DocumentSnapshot userDoc =
              await firestore.collection('Users').doc(doc.id).get();
          if (userDoc.exists) {
            Map<String, dynamic> userData =
                userDoc.data() as Map<String, dynamic>;
            studentData.addAll({
              'email': userData['email'] ?? '',
              'profileImage': userData['profileImage'] ?? '',
              // Add other fields as needed
            });
          }
        } catch (e) {
          print('Error fetching user details: $e');
        }

        fetchedStudents.add({
          'id': doc.id,
          'name': studentData['name'] ?? 'Unknown',
          'image':
              studentData['profileImage'] ?? 'https://via.placeholder.com/150',
          'courses': await _getStudentCourseCount(doc.id),
          'progress': await _getAverageProgress(doc.id),
          ...studentData,
        });
      }

      // Sort according to current option
      _sortStudents(fetchedStudents, sortOption);

      setState(() {
        students = fetchedStudents;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching students: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<int> _getStudentCourseCount(String studentId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(studentId)
          .get();

      if (userDoc.exists) {
        List<dynamic> enrolledCourses = userDoc['enrolledCourses'] ?? [];
        return enrolledCourses.length;
      }
      return 0;
    } catch (e) {
      print('Error fetching student course count: $e');
      return 0;
    }
  }

  Future<double> _getAverageProgress(String studentId) async {
    // This could be implemented to calculate student progress
    // across all courses if that data is available
    return 0.0;
  }

  void _sortStudents(List<Map<String, dynamic>> studentList, String option) {
    switch (option) {
      case 'A-Z':
        studentList.sort(
            (a, b) => a['name'].toString().compareTo(b['name'].toString()));
        break;
      case 'Z-A':
        studentList.sort(
            (a, b) => b['name'].toString().compareTo(a['name'].toString()));
        break;
      case 'Most Courses':
        studentList
            .sort((a, b) => (b['courses'] ?? 0).compareTo(a['courses'] ?? 0));
        break;
      default:
        // Default A-Z sort
        studentList.sort(
            (a, b) => a['name'].toString().compareTo(b['name'].toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final memberSearch = TextEditingController();
    final memberCategorySelect = TextEditingController();

    // Calculate the number of columns based on the screen width
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount =
        (screenWidth ~/ 400).clamp(1, 6); // Minimum 1, maximum 6

    return Container(
      width: MyUtility(context).width - 320,
      height: MyUtility(context).height - 80,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar and dropdown
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyDropDownMenu(
                  description: 'Sort',
                  customSize: 300,
                  items: ['A-Z', 'Z-A', 'Most Courses'],
                  textfieldController: TextEditingController(text: sortOption),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        sortOption = value;
                        _sortStudents(students, sortOption);
                      });
                    }
                  },
                ),
                MyDropDownMenu(
                  description: 'Filter',
                  customSize: 300,
                  items: ['All', 'Active', 'Inactive'],
                  textfieldController:
                      TextEditingController(text: filterOption),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        filterOption = value;
                        _fetchStudents(); // Refresh with the new filter
                      });
                    }
                  },
                ),
                SizedBox(
                  width: 300,
                  height: 50,
                  child: MySearchBar(
                    textController: memberSearch,
                    hintText: 'Search Student',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Scrollable grid layout
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : students.isEmpty
                      ? Center(child: Text('No students found'))
                      : SingleChildScrollView(
                          child: LayoutGrid(
                            columnSizes: List.generate(
                              crossAxisCount,
                              (_) => FlexibleTrackSize(220),
                            ),
                            rowSizes: List.generate(
                              (students.length / crossAxisCount).ceil(),
                              (_) => auto,
                            ),
                            rowGap: 20, // Space between rows
                            columnGap: 1, // Space between columns
                            children: [
                              for (var student in students)
                                SizedBox(
                                  height: 300,
                                  width: 250,
                                  child: LectureStudentContainers(
                                    isLecturer: false,
                                    isContentDev: false,
                                    isFacilitator: false,
                                    image: student['image'] ??
                                        'https://via.placeholder.com/150',
                                    name: student['name'] ?? 'Unknown',
                                    number: student['phone'] ?? '',
                                    studentAmount:
                                        (student['courses'] ?? 0).toString(),
                                    contentTotal: '0',
                                    rating: '0',
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
