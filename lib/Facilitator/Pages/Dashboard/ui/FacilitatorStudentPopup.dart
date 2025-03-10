import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void showStudentPopup(BuildContext context, String facilitatorId) {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        backgroundColor: const Color.fromARGB(255, 247, 247, 247),
        title: Text(
          "Add Student",
          style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(nameController, "Student Name"),
            const SizedBox(height: 10),
            _buildTextField(emailController, "Student Email"),
            const SizedBox(height: 10),
            _buildTextField(passwordController, "Student Password",
                isPassword: true),
            const SizedBox(height: 10),
            _buildTextField(phoneController, "Phone Number"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              "Cancel",
              style: GoogleFonts.montserrat(
                  fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (facilitatorId.isNotEmpty) {
                await _addStudent(
                  facilitatorId: facilitatorId,
                  name: nameController.text.trim(),
                  email: emailController.text.trim(),
                  password: passwordController.text.trim(),
                  phoneNumber: phoneController.text.trim(),
                );
                Navigator.of(context).pop();
              } else {
                print("Error: Facilitator ID is empty.");
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Text(
              "Add",
              style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
            ),
          ),
        ],
      );
    },
  );
}

Future<void> _addStudent({
  required String facilitatorId,
  required String name,
  required String email,
  required String password,
  required String phoneNumber,
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
      'uid': studentUid,
    };

    // Add student data to the Users collection
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(studentUid)
        .set(studentData);

    // Add student data under the correct facilitator's document
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(facilitatorId) // Ensure it's under the facilitator
        .collection('facilitatorStudents')
        .doc(studentUid)
        .set(studentData);

    print('Student added successfully under facilitator.');
  } catch (e) {
    print('Error adding student: $e');
  }
}

Widget _buildTextField(TextEditingController controller, String hintText,
    {bool isPassword = false}) {
  return TextField(
    controller: controller,
    obscureText: isPassword,
    decoration: InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.montserrat(fontSize: 14, color: Colors.grey[600]),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    ),
  );
}
