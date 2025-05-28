import 'package:a4m/CommonComponents/buttons/CustomButton.dart';
import 'package:a4m/CommonComponents/inputFields/myTextFields.dart';
import 'package:a4m/Lecturers/lecture_home_page.dart';
import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:a4m/Login/Tabs/LecturerTab/lecturerSignUp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LecturerLogin extends StatefulWidget {
  const LecturerLogin({super.key});

  @override
  State<LecturerLogin> createState() => _LecturerLoginState();
}

class _LecturerLoginState extends State<LecturerLogin> {
  bool isSignUp = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Display either the login or sign-up form based on `isSignUp`
        Expanded(
          child: isSignUp ? const LecturerSignUp() : const LecturerLoginView(),
        ),

        // Footer section: This stays consistent for both views
        Container(
          height: 180,
          width: 500,
          color: Mycolors().navyBlue,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isSignUp
                      ? 'Already Have an Account?'
                      : 'Don’t have an Account?',
                  style: GoogleFonts.kanit(color: Colors.white, fontSize: 12),
                ),
                const SizedBox(height: 25),
                CustomButton(
                  buttonText: isSignUp ? 'Login' : 'Sign Up',
                  buttonColor: isSignUp ? Mycolors().green : Mycolors().blue,
                  onPressed: () {
                    setState(() {
                      isSignUp = !isSignUp; // Toggle the view
                    });
                  },
                  width: 120,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class LecturerLoginView extends StatefulWidget {
  const LecturerLoginView({super.key});

  @override
  State<LecturerLoginView> createState() => _LecturerLoginViewState();
}

class _LecturerLoginViewState extends State<LecturerLoginView> {
  final emailController = TextEditingController(text: '');
  final passwordController = TextEditingController(text: '');
  final lecturerCodeController = TextEditingController();

  bool isLoading = false;

  Future<void> _loginLecturer() async {
    setState(() {
      isLoading = true;
    });

    try {
      String email = emailController.text.trim();
      String password = passwordController.text.trim();
      String lecturerCode = lecturerCodeController.text.trim();

      if (email.isEmpty || password.isEmpty /*|| lecturerCode.isEmpty*/) {
        _showErrorDialog('Please fill in all required fields.');
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Authenticate user with Firebase
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Retrieve user details from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;
        String userType = userData['userType'] ?? '';
        String status = userData['status'] ?? '';
        String storedLecturerCode = userData['lecturerCode'] ?? '';

        // Check if user is a lecturer and status is approved
        if (userType == 'lecturer' &&
            status == 'approved' &&
            storedLecturerCode == lecturerCode) {
          // Navigate to lecturer's dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => LectureHomePage(
                      lecturerId: userCredential.user!.uid,
                    )),
          );
        } else if (status == 'pending') {
          _showErrorDialog(
              'Your account is still pending approval. Please wait for admin verification.');
        } else {
          _showErrorDialog(
              'Invalid credentials or your account is not verified.');
        }
      } else {
        _showErrorDialog('User not found.');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided.';
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Login Failed'),
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
      child: SizedBox(
        height: 500,
        child: Column(children: [
          Text(
            'Lecturer Log In',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            'Please Enter your Details',
            style: GoogleFonts.kanit(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          SizedBox(
            width: 380,
            child: MyTextFields(
              inputController: emailController,
              headerText: "Email*",
              hintText: 'Enter your email',
              keyboardType: 'email',
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          SizedBox(
            width: 380,
            child: MyTextFields(
              inputController: passwordController,
              headerText: "Password*",
              hintText: 'Enter your password',
              keyboardType: '',
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          SizedBox(
            width: 380,
            child: InkWell(
              onTap: () {
                //TO DO
              },
              child: Text(
                textAlign: TextAlign.right,
                'Forgot Password?',
                style: GoogleFonts.kanit(color: Mycolors().blue, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          SizedBox(
            width: 380,
            child: MyTextFields(
              inputController: lecturerCodeController,
              headerText: "Lecturer Code*",
              hintText: 'Enter your lecturer code',
              keyboardType: 'intType',
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          CustomButton(
            buttonText: 'Login',
            buttonColor: Mycolors().green,
            onPressed: () {
              _loginLecturer();
            },
            width: 100,
          ),
          const SizedBox(
            height: 25,
          ),
          Spacer(),
        ]),
      ),
    );
  }
}
