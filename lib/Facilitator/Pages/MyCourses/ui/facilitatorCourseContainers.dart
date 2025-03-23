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
                  Text(
                      'Student name will be used as shown in dropdown. Certificate details can be collected when the course is completed.'),
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
                    try {
                      // Get student name from the selection
                      Map<String, dynamic> selectedStudent =
                          students.firstWhere(
                              (s) => s['studentId'] == selectedStudentId);
                      String studentName = selectedStudent['name'] ?? 'Unknown';

                      // Start a local transaction with empty ID number (will be collected later)
                      bool isSuccessful = await _assignLicenseTransaction(
                        selectedStudentId!,
                        studentName,
                      );

                      if (isSuccessful) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Student assigned successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error assigning student: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please select a student'),
                        backgroundColor: Colors.red,
                      ),
                    );
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

  Future<bool> _assignLicenseTransaction(
    String studentId,
    String fullName,
  ) async {
    // Create references to all documents that will be modified
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Step 1: Find an available license
      QuerySnapshot licenseSnapshot = await firestore
          .collection('courseLicenses')
          .where('courseId', isEqualTo: widget.courseId)
          .where('facilitatorId', isEqualTo: widget.facilitatorId)
          .where('status', isEqualTo: 'available')
          .limit(1)
          .get();

      if (licenseSnapshot.docs.isEmpty) {
        throw Exception('No available licenses found');
      }

      String licenseId = licenseSnapshot.docs.first.id;

      // Step 2: Get current state of all documents
      DocumentSnapshot facilitatorDoc =
          await firestore.collection('Users').doc(widget.facilitatorId).get();

      DocumentSnapshot courseDoc =
          await firestore.collection('courses').doc(widget.courseId).get();

      DocumentSnapshot studentDoc =
          await firestore.collection('Users').doc(studentId).get();

      // Prepare data updates
      // 1. Update license data - not storing ID number
      await licenseSnapshot.docs.first.reference.update({
        'status': 'assigned',
        'assignedTo': studentId,
        'assignmentDate': FieldValue.serverTimestamp(),
      });

      // 2. Update facilitator's course license count
      List<dynamic> facilitatorCourses =
          facilitatorDoc['facilitatorCourses'] ?? [];
      List<dynamic> updatedFacilitatorCourses =
          facilitatorCourses.map((course) {
        if (course['courseId'] == widget.courseId) {
          return {
            ...course,
            'availableLicenses': course['availableLicenses'] - 1,
          };
        }
        return course;
      }).toList();

      await firestore.collection('Users').doc(widget.facilitatorId).update({
        'facilitatorCourses': updatedFacilitatorCourses,
      });

      // 3. Add student to course if not already added
      Map<String, dynamic> courseData =
          courseDoc.data() as Map<String, dynamic>;
      List<dynamic> currentStudents = courseData['students'] ?? [];
      bool studentExists =
          currentStudents.any((s) => s['studentId'] == studentId);

      if (!studentExists) {
        currentStudents.add({
          'studentId': studentId,
          'name': fullName,
          'registered': true,
        });

        await firestore.collection('courses').doc(widget.courseId).update({
          'students': currentStudents,
        });
      }

      // 4. Update student info in facilitator's student collection - only name
      await firestore
          .collection('Users')
          .doc(widget.facilitatorId)
          .collection('facilitatorStudents')
          .doc(studentId)
          .set({
        'name': fullName,
      }, SetOptions(merge: true));

      // 5. Add course to student's enrolled courses
      List<dynamic> enrolledCourses = [];
      if (studentDoc.exists) {
        Map<String, dynamic> studentData =
            studentDoc.data() as Map<String, dynamic>;
        enrolledCourses = studentData['enrolledCourses'] ?? [];
      }

      // Check if course is already in student's enrolled courses
      bool courseExists =
          enrolledCourses.any((c) => c['courseId'] == widget.courseId);

      if (!courseExists) {
        enrolledCourses.add({
          'courseId': widget.courseId,
          'courseName': widget.courseName,
          'facilitatorId': widget.facilitatorId,
          'licenseId': licenseId,
          'enrollmentDate': DateTime.now().toIso8601String(),
        });

        await firestore.collection('Users').doc(studentId).set({
          'enrolledCourses': enrolledCourses,
        }, SetOptions(merge: true));
      }

      // 6. Refresh local data
      await _fetchCourseLicenseInfo();

      return true;
    } catch (e) {
      print('Transaction failed: $e');
      // If anything fails, we should ideally roll back changes
      // This would require a true server-side transaction
      return false;
    }
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
