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

  @override
  void initState() {
    super.initState();
    _fetchFacilitatorStudents();
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

  Future<void> _assignStudentToCourse() async {
    if (selectedStudentId == null) {
      print("No student selected.");
      return;
    }

    try {
      // Get selected student details
      Map<String, dynamic>? selectedStudent =
          students.firstWhere((s) => s['studentId'] == selectedStudentId);

      // Update course document to add student
      await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .update({
        'students': FieldValue.arrayUnion([
          {
            'studentId': selectedStudentId,
            'name': selectedStudent['name'],
            'registered': Timestamp.now(), // ✅ Store as Firestore Timestamp
          }
        ])
      });

      print("Student assigned successfully.");
      setState(() {
        selectedStudentId = null; // Reset dropdown after assignment
      });
    } catch (e) {
      print("Error assigning student: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Print the course image URL to the console
    print("Course Image URL: ${widget.courseImage}");

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
                            child: GestureDetector(
                              onTap: () => _showAssignStudentDialog(context),
                              child: Container(
                                height: 30,
                                width: widget.isAssignStudent ? 150 : 80,
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
                                        fontSize: 12),
                                  ),
                                ),
                              ),
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

  void _showAssignStudentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Assign Student"),
          content: DropdownButtonFormField<String>(
            value: selectedStudentId,
            onChanged: (value) {
              setState(() {
                selectedStudentId = value;
              });
            },
            items: students.map((student) {
              return DropdownMenuItem<String>(
                value: student['studentId'],
                child: Text(student['name']),
              );
            }).toList(),
            decoration: InputDecoration(
              hintText: "Select a student",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await _assignStudentToCourse();
                Navigator.of(context).pop();
              },
              child: Text("Assign"),
            ),
          ],
        );
      },
    );
  }
}
