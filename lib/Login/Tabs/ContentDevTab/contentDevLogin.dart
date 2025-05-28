import 'package:a4m/CommonComponents/buttons/CustomButton.dart';
import 'package:a4m/CommonComponents/inputFields/myTextFields.dart';
import 'package:a4m/ContentDev/ModuleAssessments/CourseModel.dart';
import 'package:a4m/ContentDev/content_dev_landing.dart';
import 'package:a4m/Login/Tabs/ContentDevTab/contentDevSignUp.dart';
import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ContentDevLogin extends StatefulWidget {
  const ContentDevLogin({super.key});
  @override
  State<ContentDevLogin> createState() => _ContentDevLoginState();
}

class _ContentDevLoginState extends State<ContentDevLogin> {
  bool isSignUp = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Display either the login or sign-up form based on `isSignUp`
        Expanded(
          child:
              isSignUp ? const ContentDevSignUp() : const ContentDevLoginView(),
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

class ContentDevLoginView extends StatefulWidget {
  const ContentDevLoginView({super.key});
  @override
  State<ContentDevLoginView> createState() => _ContentDevLoginViewState();
}

class _ContentDevLoginViewState extends State<ContentDevLoginView> {
  final emailController = TextEditingController(text: "");
  final passwordController = TextEditingController(text: "");
  final contentDevCodeController = TextEditingController();
  bool isLoading = false;
  Future<void> _loginContentDev() async {
    setState(() {
      isLoading = true;
    });
    try {
      String email = emailController.text.trim();
      String password = passwordController.text.trim();
      String contentDevCode = contentDevCodeController.text.trim();
      if (email.isEmpty || password.isEmpty) {
        _showErrorDialog('Please fill in all required fields.');
        setState(() {
          isLoading = false;
        });
        return;
      }
      // Authenticate user with Firebase
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      // getting the USerDetails for conformation and login
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userCredential.user!.uid)
          .get();
      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;
        String userType = userData['userType'] ?? '';
        String status = userData['status'] ?? '';
        String storedContentDevCode = userData['contentDevCode'] ?? '';
        // Check if user is a content developer and approved
        if (userType == 'contentDev' &&
            status == 'approved' &&
            storedContentDevCode == contentDevCode) {
          //Connect Navigation Logic here
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider(
                create: (context) =>
                    CourseModel(), // Provide the CourseModel state when navigating to ContentDevHome
                child: ContentDevHome(contentDevId: userCredential.user!.uid),
              ),
            ),
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
            'Content Dev Log In',
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

          // remember to remove logins from textfield
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
              inputController: contentDevCodeController,
              headerText: "Content Dev Code*",
              hintText: 'Enter your Content Dev code',
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
                _loginContentDev();
              },
              width: 100),
          const SizedBox(
            height: 25,
          ),
          Spacer(),
        ]),
      ),
    );
  }
}
