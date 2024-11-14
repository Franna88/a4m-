import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../CommonComponents/buttons/CustomButton.dart';
import '../../../CommonComponents/inputFields/myTextFields.dart';
import '../../../Constants/myColors.dart';
class StudentSignUp extends StatefulWidget {
  const StudentSignUp({super.key});
  @override
  State<StudentSignUp> createState() => _StudentSignUpState();
}
class _StudentSignUpState extends State<StudentSignUp> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final facilitatorCodeController = TextEditingController();
  final nameController = TextEditingController();
  final phoneNumController = TextEditingController();
  bool isFirstStep = true;
  bool isLoading = false;
  // Sign-up process to handle user registration with Firebase
  Future<void> _signUpProcess() async {
    setState(() {
      isLoading = true;
    });
    try {
      String email = emailController.text.trim();
      String password = passwordController.text.trim();
      String name = nameController.text.trim();
      String phoneNumber = phoneNumController.text.trim();
      String facilitatorCode = facilitatorCodeController.text.trim();
      // Validation
      if (email.isEmpty ||
          password.isEmpty ||
          name.isEmpty ||
          phoneNumber.isEmpty) {
        _showErrorDialog('Please fill in all required fields');
        setState(() {
          isLoading = false;
        });
        return;
      }
      // Create user with Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      // Save additional data to Firestore
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userCredential.user!.uid)
          .set({
        'userType': 'student',
        'email': email,
        'name': name,
        'phoneNumber': phoneNumber,
        'facilitatorCode': facilitatorCode.isEmpty ? null : facilitatorCode,
      });
      // Navigate to the student dashboard or show success message
      Navigator.pushReplacementNamed(context, '/studentDashboard');
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'email-already-in-use') {
        errorMessage = 'The email is already in use by another account.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'The password is too weak.';
      } else {
        errorMessage = 'An error occurred. Please try again.';
      }
      _showErrorDialog(errorMessage);
    } catch (e) {
      _showErrorDialog('An unexpected error occurred. Please try again.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  // Method to show error dialogs
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Up Failed'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            'Student Sign Up',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Please Enter your Details',
            style: GoogleFonts.kanit(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 25),
          // First Step: Full Name and Phone Number
          if (isFirstStep) ...[
            SizedBox(
              width: 380,
              child: MyTextFields(
                inputController: nameController,
                headerText: "Full Name",
                hintText: 'Name and surname',
                keyboardType: '',
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: 380,
              child: MyTextFields(
                inputController: phoneNumController,
                headerText: "Phone Number",
                hintText: '082 222 959 332',
                keyboardType: 'intType',
              ),
            ),
          ] else ...[
            // Second Step: Email, Password, and Facilitator Code
            SizedBox(
              width: 380,
              child: MyTextFields(
                inputController: emailController,
                headerText: "Email*",
                hintText: 'Enter your email',
                keyboardType: 'email',
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: 380,
              child: MyTextFields(
                inputController: passwordController,
                headerText: "Password*",
                hintText: 'Enter your password',
                keyboardType: '',
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: 380,
              child: MyTextFields(
                inputController: facilitatorCodeController,
                headerText: "Facilitator Code",
                hintText: 'Enter facilitator code',
                keyboardType: 'intType',
                isOptional: true,
              ),
            ),
          ],
          const SizedBox(height: 25),
          // "Next" or "Sign Up" Button
          isLoading
              ? CircularProgressIndicator()
              : CustomButton(
                  buttonText: isFirstStep ? 'Next' : 'Sign Up',
                  buttonColor: Mycolors().blue,
                  onPressed: () {
                    if (isFirstStep) {
                      setState(() {
                        isFirstStep = false; // Move to the next step
                      });
                    } else {
                      _signUpProcess(); // Handle sign-up submission
                    }
                  },
                  width: 120,
                ),
        ],
      ),
    );
  }
}