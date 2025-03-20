import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      return StatefulBuilder(builder: (context, setState) {
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
                            content:
                                Text('Please fill in all required fields (*)'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      String fullName =
                          "${nameController.text.trim()} ${surnameController.text.trim()}";
                      await _addStudent(
                        facilitatorId: facilitatorId,
                        name: fullName,
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                        phoneNumber: phoneController.text.trim(),
                        idNumber: idNumberController.text.trim(),
                      );
                      Navigator.of(context).pop();
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
      });
    },
  );
}

Future<void> _addStudent({
  required String facilitatorId,
  required String name,
  required String email,
  required String password,
  required String phoneNumber,
  required String idNumber,
}) async {
  try {
    print("Creating student under facilitator ID: $facilitatorId");

    // Create the student in Firebase Auth
    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    String studentUid = userCredential.user!.uid;

    // Prepare student data
    final studentData = {
      'userType': 'student',
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'idNumber': idNumber,
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

    print('Student added successfully under facilitator.');
  } catch (e) {
    print('Error adding student: $e');
  }
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
