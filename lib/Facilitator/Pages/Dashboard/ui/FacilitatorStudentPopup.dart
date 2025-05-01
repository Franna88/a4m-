import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_network/image_network.dart';

void showStudentPopup(BuildContext context, String facilitatorId) {
  TextEditingController nameController = TextEditingController();
  TextEditingController surnameController = TextEditingController();
  TextEditingController idNumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  bool obscurePassword = true;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Container(
              width: 450,
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Add New Student",
                        style: GoogleFonts.montserrat(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  _buildTextField(nameController, "First Name *"),
                  SizedBox(height: 15),
                  _buildTextField(surnameController, "Surname *"),
                  SizedBox(height: 15),
                  _buildTextField(
                      idNumberController, "ID Number (for certificate)"),
                  SizedBox(height: 15),
                  _buildTextField(emailController, "Email Address *"),
                  SizedBox(height: 15),
                  TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Password *",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  _buildTextField(phoneController, "Phone Number"),
                  SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.isEmpty ||
                            surnameController.text.isEmpty ||
                            emailController.text.isEmpty ||
                            passwordController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Please fill in all required fields (*)'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        String fullName =
                            "${nameController.text.trim()} ${surnameController.text.trim()}";

                        try {
                          // Create the student first
                          UserCredential userCredential = await FirebaseAuth
                              .instance
                              .createUserWithEmailAndPassword(
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                          );

                          String studentUid = userCredential.user!.uid;

                          // Prepare student data
                          final studentData = {
                            'userType': 'student',
                            'name': fullName,
                            'email': emailController.text.trim(),
                            'phoneNumber': phoneController.text.trim(),
                            'idNumber': idNumberController.text.trim(),
                            'uid': studentUid,
                            'createdAt': FieldValue.serverTimestamp(),
                            'enrolledCourses': [],
                          };

                          // Add student data to the Users collection
                          await FirebaseFirestore.instance
                              .collection('Users')
                              .doc(studentUid)
                              .set(studentData);

                          // Add student data under the correct facilitator's document
                          await FirebaseFirestore.instance
                              .collection('Users')
                              .doc(facilitatorId)
                              .collection('facilitatorStudents')
                              .doc(studentUid)
                              .set(studentData);

                          // Close the current dialog
                          Navigator.of(context).pop();

                          // Show the course assignment dialog
                          showCourseAssignmentDialog(
                            context,
                            facilitatorId,
                            studentUid,
                            fullName,
                            idNumberController.text.trim(),
                          );
                        } catch (e) {
                          print('Error creating student: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Error creating student: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text(
                        "Add Student",
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

void showCourseAssignmentDialog(
  BuildContext context,
  String facilitatorId,
  String studentUid,
  String studentName,
  String idNumber,
) {
  List<Map<String, dynamic>> selectedCourses = [];
  List<Map<String, dynamic>> availableCourses = [];
  bool isLoadingCourses = true;
  bool isAssigningCourses = false;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          // Fetch available courses when dialog opens
          if (isLoadingCourses) {
            FirebaseFirestore.instance
                .collection('Users')
                .doc(facilitatorId)
                .get()
                .then((doc) async {
              if (doc.exists) {
                List<dynamic> facilitatorCourses =
                    doc['facilitatorCourses'] ?? [];
                List<Map<String, dynamic>> courses = [];

                // Fetch full course details for each course
                for (var course in facilitatorCourses) {
                  String courseId = course['courseId'];
                  DocumentSnapshot courseDoc = await FirebaseFirestore.instance
                      .collection('courses')
                      .doc(courseId)
                      .get();

                  if (courseDoc.exists) {
                    Map<String, dynamic> courseData =
                        courseDoc.data() as Map<String, dynamic>;
                    courses.add({
                      'courseId': courseId,
                      'courseName':
                          courseData['courseName'] ?? 'Unknown Course',
                      'courseImageUrl': courseData['courseImageUrl'] ??
                          'https://via.placeholder.com/150',
                      'availableLicenses': course['availableLicenses'] ?? 0,
                    });
                  }
                }

                setState(() {
                  availableCourses = courses;
                  isLoadingCourses = false;
                });
              } else {
                setState(() {
                  isLoadingCourses = false;
                });
              }
            }).catchError((error) {
              print('Error fetching courses: $error');
              setState(() {
                isLoadingCourses = false;
              });
            });
          }

          return WillPopScope(
            onWillPop: () async => !isAssigningCourses,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Container(
                width: 450,
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Assign Courses",
                          style: GoogleFonts.montserrat(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: isAssigningCourses
                              ? null
                              : () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Select courses for $studentName",
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 20),
                    if (isLoadingCourses)
                      Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                              "Loading available courses...",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    else if (availableCourses.isEmpty)
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.school_outlined,
                                size: 48, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              "No courses available to assign",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        height: 250,
                        child: ListView.builder(
                          itemCount: availableCourses.length,
                          itemBuilder: (context, index) {
                            final course = availableCourses[index];
                            final isSelected = selectedCourses.any(
                                (c) => c['courseId'] == course['courseId']);
                            return Container(
                              margin: EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.blue
                                      : Colors.grey[300]!,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: CheckboxListTile(
                                title: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: ImageNetwork(
                                        image: course['courseImageUrl'] ??
                                            'https://via.placeholder.com/150',
                                        height: 40,
                                        width: 40,
                                        duration: 1500,
                                        curve: Curves.easeIn,
                                        onPointer: true,
                                        debugPrint: false,
                                        fitAndroidIos: BoxFit.cover,
                                        fitWeb: BoxFitWeb.cover,
                                        onLoading: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.blue),
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        ),
                                        onError: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Icon(
                                            Icons.image_not_supported,
                                            color: Colors.grey[400],
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            course['courseName'] ??
                                                'Unknown Course',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            'Available Licenses: ${course['availableLicenses'] ?? 0}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                value: isSelected,
                                onChanged: isAssigningCourses ||
                                        (course['availableLicenses'] ?? 0) <= 0
                                    ? null
                                    : (bool? value) {
                                        setState(() {
                                          if (value == true) {
                                            selectedCourses.add(course);
                                          } else {
                                            selectedCourses.removeWhere((c) =>
                                                c['courseId'] ==
                                                course['courseId']);
                                          }
                                        });
                                      },
                              ),
                            );
                          },
                        ),
                      ),
                    SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isAssigningCourses
                            ? null
                            : () async {
                                if (selectedCourses.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Please select at least one course'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                setState(() {
                                  isAssigningCourses = true;
                                });

                                try {
                                  // Assign selected courses to the student
                                  for (var course in selectedCourses) {
                                    String courseId = course['courseId'] ?? '';
                                    String courseName = course['courseName'] ??
                                        'Unknown Course';

                                    if (courseId.isEmpty) {
                                      throw Exception('Invalid course ID');
                                    }

                                    // Find an available license
                                    QuerySnapshot licenseSnapshot =
                                        await FirebaseFirestore
                                            .instance
                                            .collection('courseLicenses')
                                            .where('courseId',
                                                isEqualTo: courseId)
                                            .where('facilitatorId',
                                                isEqualTo: facilitatorId)
                                            .where('status',
                                                isEqualTo: 'available')
                                            .limit(1)
                                            .get();

                                    if (licenseSnapshot.docs.isEmpty) {
                                      throw Exception(
                                          'No available licenses found for course: $courseName');
                                    }

                                    // Update the license
                                    await licenseSnapshot.docs.first.reference
                                        .update({
                                      'status': 'assigned',
                                      'assignedTo': studentUid,
                                      'assignmentDate':
                                          FieldValue.serverTimestamp(),
                                      'idNumber': idNumber,
                                    });

                                    // Update the course's available licenses count
                                    await FirebaseFirestore.instance
                                        .collection('Users')
                                        .doc(facilitatorId)
                                        .update({
                                      'facilitatorCourses':
                                          FieldValue.arrayRemove([course]),
                                    });

                                    // Add the course to student's enrolled courses
                                    await FirebaseFirestore.instance
                                        .collection('Users')
                                        .doc(studentUid)
                                        .update({
                                      'enrolledCourses': FieldValue.arrayUnion([
                                        {
                                          'courseId': courseId,
                                          'courseName': courseName,
                                          'facilitatorId': facilitatorId,
                                          'licenseId':
                                              licenseSnapshot.docs.first.id,
                                          'enrollmentDate':
                                              DateTime.now().toIso8601String(),
                                          'idNumber': idNumber,
                                        }
                                      ])
                                    });
                                  }

                                  // Show success message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Student created and courses assigned successfully'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );

                                  // Close the dialog
                                  Navigator.of(context).pop();
                                } catch (e) {
                                  print('Error assigning courses: $e');
                                  setState(() {
                                    isAssigningCourses = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Error assigning courses: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: isAssigningCourses
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    "Assigning Courses...",
                                    style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                "Assign Courses",
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _buildTextField(TextEditingController controller, String labelText) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}
