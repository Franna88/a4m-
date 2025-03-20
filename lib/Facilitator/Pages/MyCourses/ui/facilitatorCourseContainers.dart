import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_network/image_network.dart';

import '../../../../CommonComponents/displayCardIcons.dart';
import '../../../../Constants/myColors.dart';

class FacilitatorCourseContainers extends StatefulWidget {
  final bool isAssignStudent;
  final String courseName;
  final String courseDescription;
  final String totalStudents;
  final String totalAssesments;
  final String totalModules;
  final String courseImage;
  final String coursePrice;
  final String facilitatorId;
  final String courseId;

  const FacilitatorCourseContainers({
    super.key,
    required this.isAssignStudent,
    required this.courseName,
    required this.courseDescription,
    required this.totalStudents,
    required this.totalAssesments,
    required this.totalModules,
    required this.courseImage,
    required this.coursePrice,
    required this.facilitatorId,
    required this.courseId,
  });

  @override
  State<FacilitatorCourseContainers> createState() =>
      _FacilitatorCourseContainersState();
}

class _FacilitatorCourseContainersState
    extends State<FacilitatorCourseContainers> {
  String? selectedStudentId;
  List<Map<String, dynamic>> students = [];
  Map<String, dynamic>? courseLicenseInfo;

  @override
  void initState() {
    super.initState();
    _fetchFacilitatorStudents();
    _fetchCourseLicenseInfo();
  }

  Future<void> _fetchFacilitatorStudents() async {
    try {
      QuerySnapshot studentSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.facilitatorId)
          .collection('facilitatorStudents')
          .get();

      List<Map<String, dynamic>> studentList = studentSnapshot.docs.map((doc) {
        return {
          'studentId': doc.id,
          'name': doc['name'] ?? 'Unknown',
        };
      }).toList();

      setState(() {
        students = studentList;
      });
    } catch (e) {
      print("Error fetching students: $e");
    }
  }

  Future<void> _fetchCourseLicenseInfo() async {
    try {
      DocumentSnapshot facilitatorDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.facilitatorId)
          .get();

      List<dynamic> facilitatorCourses =
          facilitatorDoc['facilitatorCourses'] ?? [];
      courseLicenseInfo = facilitatorCourses.firstWhere(
        (course) => course['courseId'] == widget.courseId,
        orElse: () => null,
      );

      setState(() {});
    } catch (e) {
      print("Error fetching course license info: $e");
    }
  }

  Future<void> _showAssignStudentDialog(BuildContext context) async {
    if (students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No students available to assign.')),
      );
      return;
    }

    // Check available licenses
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot facilitatorDoc =
        await firestore.collection('Users').doc(widget.facilitatorId).get();

    List<dynamic> facilitatorCourses =
        facilitatorDoc['facilitatorCourses'] ?? [];
    Map<String, dynamic>? courseInfo = facilitatorCourses.firstWhere(
      (course) => course['courseId'] == widget.courseId,
      orElse: () => null,
    );

    if (courseInfo == null || courseInfo['availableLicenses'] <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No available licenses for this course.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Initialize additional fields
    String fullName = '';
    String idNumber = '';

    // Get selected student's initial name if one is selected
    if (selectedStudentId != null) {
      Map<String, dynamic> selectedStudent = students.firstWhere(
          (s) => s['studentId'] == selectedStudentId,
          orElse: () => {'name': ''});
      fullName = selectedStudent['name'] ?? '';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text('Assign Student'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Available Licenses: ${courseInfo['availableLicenses']}'),
                  SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: selectedStudentId,
                    decoration: InputDecoration(
                      labelText: 'Select Student',
                      border: OutlineInputBorder(),
                    ),
                    items: students.map((student) {
                      return DropdownMenuItem<String>(
                        value: student['studentId'],
                        child: Text(student['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedStudentId = value;
                        if (value != null) {
                          Map<String, dynamic> selectedStudent = students
                              .firstWhere((s) => s['studentId'] == value);
                          fullName = selectedStudent['name'] ?? '';
                        }
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Full Name (Name and Surname)',
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(text: fullName),
                    onChanged: (value) {
                      fullName = value;
                    },
                  ),
                  SizedBox(height: 20),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'ID Number (for certificate)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      idNumber = value;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  if (selectedStudentId != null) {
                    if (fullName.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Please enter the student\'s full name'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    try {
                      // Find an available license
                      QuerySnapshot licenseSnapshot = await firestore
                          .collection('courseLicenses')
                          .where('courseId', isEqualTo: widget.courseId)
                          .where('facilitatorId',
                              isEqualTo: widget.facilitatorId)
                          .where('status', isEqualTo: 'available')
                          .limit(1)
                          .get();

                      if (licenseSnapshot.docs.isEmpty) {
                        throw Exception('No available licenses found');
                      }

                      // Update the license
                      await licenseSnapshot.docs.first.reference.update({
                        'status': 'assigned',
                        'assignedTo': selectedStudentId,
                        'assignmentDate': FieldValue.serverTimestamp(),
                        'idNumber': idNumber, // Store ID number with license
                      });

                      // Update the course's available licenses count
                      await firestore
                          .collection('Users')
                          .doc(widget.facilitatorId)
                          .update({
                        'facilitatorCourses': facilitatorCourses.map((course) {
                          if (course['courseId'] == widget.courseId) {
                            return {
                              ...course,
                              'availableLicenses':
                                  course['availableLicenses'] - 1,
                            };
                          }
                          return course;
                        }).toList(),
                      });

                      // Add student to the course
                      DocumentSnapshot courseDoc = await firestore
                          .collection('courses')
                          .doc(widget.courseId)
                          .get();

                      // Initialize students array if it doesn't exist
                      Map<String, dynamic> courseData =
                          courseDoc.data() as Map<String, dynamic>;
                      List<dynamic> currentStudents =
                          courseData['students'] ?? [];

                      // Check if student is already in the course
                      bool studentExists = currentStudents
                          .any((s) => s['studentId'] == selectedStudentId);

                      if (!studentExists) {
                        // Add student in the required format
                        currentStudents.add({
                          'studentId': selectedStudentId,
                          'name': fullName,
                          'idNumber': idNumber,
                          'registered': true,
                        });

                        // Update the course document with the new students array
                        await firestore
                            .collection('courses')
                            .doc(widget.courseId)
                            .set(
                                {
                              'students': currentStudents,
                            },
                                SetOptions(
                                    merge:
                                        true)); // Use merge to preserve other fields

                        // Update student record with full name and ID number
                        await firestore
                            .collection('Users')
                            .doc(widget.facilitatorId)
                            .collection('facilitatorStudents')
                            .doc(selectedStudentId)
                            .set({
                          'name': fullName,
                          'idNumber': idNumber,
                        }, SetOptions(merge: true));

                        // Add the course to the student's enrolled courses
                        DocumentReference studentRef = firestore
                            .collection('Users')
                            .doc(selectedStudentId);

                        DocumentSnapshot studentDoc = await studentRef.get();

                        // Initialize enrolledCourses if it doesn't exist
                        if (!studentDoc.exists ||
                            !(studentDoc.data() as Map<String, dynamic>)
                                .containsKey('enrolledCourses')) {
                          await studentRef.set({
                            'enrolledCourses': [],
                          }, SetOptions(merge: true));
                        }

                        // Add the course to student's enrolled courses
                        await studentRef.update({
                          'enrolledCourses': FieldValue.arrayUnion([
                            {
                              'courseId': widget.courseId,
                              'courseName': widget.courseName,
                              'facilitatorId': widget.facilitatorId,
                              'licenseId': licenseSnapshot.docs.first.id,
                              'enrollmentDate':
                                  DateTime.now().toIso8601String(),
                              'idNumber': idNumber,
                            }
                          ])
                        });

                        // Refresh the course license info
                        await _fetchCourseLicenseInfo();
                      }

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Student assigned successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error assigning student: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: Text('Assign'),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Print the course image URL to the console

    return Material(
      borderRadius: BorderRadius.circular(15),
      elevation: 5,
      child: Container(
        height: 340,
        width: 320,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 320,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ImageNetwork(
                        image: widget.courseImage,
                        fitWeb: BoxFitWeb.cover,
                        fitAndroidIos: BoxFit.cover,
                        onLoading: const Center(
                          child: CircularProgressIndicator(),
                        ),
                        width: 320,
                        height: 180,
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color.fromARGB(0, 255, 255,
                                  255), // Transparent color at the top
                              Mycolors().green, // Green color at the bottom
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Row(
                              children: [
                                if (widget.isAssignStudent) ...[
                                  Container(
                                    height: 30,
                                    width: 30,
                                    decoration: BoxDecoration(
                                      color: Mycolors().blue,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${courseLicenseInfo?['availableLicenses'] ?? 0}',
                                        style: GoogleFonts.montserrat(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                ],
                                GestureDetector(
                                  onTap: () =>
                                      _showAssignStudentDialog(context),
                                  child: Container(
                                    height: 30,
                                    width: widget.isAssignStudent ? 120 : 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: widget.isAssignStudent
                                          ? Mycolors().blue
                                          : Mycolors().darkTeal,
                                    ),
                                    child: Center(
                                      child: Text(
                                        widget.isAssignStudent
                                            ? 'Assign Student'
                                            : widget.coursePrice,
                                        style: GoogleFonts.montserrat(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.courseName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 5, bottom: 5),
              child: Text(
                widget.courseDescription,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                width: 300,
                height: 2,
                color: const Color.fromARGB(255, 189, 189, 189),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: DisplayCardIcons(
                      icon: Icons.person_outline,
                      count: widget.totalStudents,
                      tooltipText: 'Students'),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: DisplayCardIcons(
                      icon: Icons.format_list_numbered,
                      count: widget.totalAssesments,
                      tooltipText: 'Assessments'),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: DisplayCardIcons(
                      icon: Icons.library_books,
                      count: widget.totalModules,
                      tooltipText: 'Modules'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
