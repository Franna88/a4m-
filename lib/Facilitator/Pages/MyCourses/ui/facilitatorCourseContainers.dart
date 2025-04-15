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
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Container(
              width: 450,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Assign Student',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Mycolors().green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Mycolors().green,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Mycolors().green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Available Licenses: ${courseInfo['availableLicenses']}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Mycolors().green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: selectedStudentId,
                    decoration: InputDecoration(
                      labelText: 'Select Student',
                      labelStyle: GoogleFonts.poppins(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey[300]!,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey[300]!,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Mycolors().green,
                        ),
                      ),
                    ),
                    items: students.map((student) {
                      return DropdownMenuItem<String>(
                        value: student['studentId'],
                        child: Text(
                          student['name'],
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                        ),
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
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (selectedStudentId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Please select a student'),
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
                              await licenseSnapshot.docs.first.reference
                                  .update({
                                'status': 'assigned',
                                'assignedTo': selectedStudentId,
                                'assignmentDate': FieldValue.serverTimestamp(),
                              });

                              // Update the course's available licenses count
                              await firestore
                                  .collection('Users')
                                  .doc(widget.facilitatorId)
                                  .update({
                                'facilitatorCourses':
                                    facilitatorCourses.map((course) {
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

                              Map<String, dynamic> courseData =
                                  courseDoc.data() as Map<String, dynamic>;
                              List<dynamic> currentStudents =
                                  courseData['students'] ?? [];

                              bool studentExists = currentStudents.any(
                                  (s) => s['studentId'] == selectedStudentId);

                              if (!studentExists) {
                                currentStudents.add({
                                  'studentId': selectedStudentId,
                                  'name': fullName,
                                  'registered': true,
                                });

                                await firestore
                                    .collection('courses')
                                    .doc(widget.courseId)
                                    .set({'students': currentStudents},
                                        SetOptions(merge: true));

                                DocumentReference studentRef = firestore
                                    .collection('Users')
                                    .doc(selectedStudentId);

                                DocumentSnapshot studentDoc =
                                    await studentRef.get();

                                if (!studentDoc.exists ||
                                    !(studentDoc.data() as Map<String, dynamic>)
                                        .containsKey('enrolledCourses')) {
                                  await studentRef.set({
                                    'enrolledCourses': [],
                                  }, SetOptions(merge: true));
                                }

                                await studentRef.update({
                                  'enrolledCourses': FieldValue.arrayUnion([
                                    {
                                      'courseId': widget.courseId,
                                      'courseName': widget.courseName,
                                      'facilitatorId': widget.facilitatorId,
                                      'licenseId':
                                          licenseSnapshot.docs.first.id,
                                      'enrollmentDate':
                                          DateTime.now().toIso8601String(),
                                    }
                                  ])
                                });

                                await _fetchCourseLicenseInfo();
                              }

                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Student assigned successfully'),
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
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Mycolors().green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          child: Text(
                            'Assign Student',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
