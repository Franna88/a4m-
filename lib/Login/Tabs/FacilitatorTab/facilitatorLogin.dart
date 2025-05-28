import 'package:a4m/Facilitator/facilitatorHome.dart';
import 'package:a4m/Login/Tabs/FacilitatorTab/facilitatorSignUp.dart';
import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../CommonComponents/buttons/CustomButton.dart';
import '../../../CommonComponents/inputFields/myTextFields.dart';

class FacilitatorLogin extends StatefulWidget {
  const FacilitatorLogin({super.key});
  @override
  State<FacilitatorLogin> createState() => _FacilitatorLoginState();
}

class _FacilitatorLoginState extends State<FacilitatorLogin> {
  bool isSignUp = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Display either the login or sign-up form based on `isSignUp`
        Expanded(
          child: isSignUp
              ? const FacilitatorSignUp()
              : const FacilitatorLoginView(),
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

class FacilitatorLoginView extends StatefulWidget {
  const FacilitatorLoginView({super.key});
  @override
  State<FacilitatorLoginView> createState() => _FacilitatorLoginViewState();
}

class _FacilitatorLoginViewState extends State<FacilitatorLoginView> {
  final emailController = TextEditingController(text: '');
  final passwordController = TextEditingController(text: '');
  final facilitatorCodeController = TextEditingController();
  bool isLoading = false;
  Future<void> _loginFacilitator() async {
    setState(() {
      isLoading = true;
    });
    try {
      String email = emailController.text.trim();
      String password = passwordController.text.trim();
      String facilitatorCode = facilitatorCodeController.text.trim();
      if (email.isEmpty || password.isEmpty) {
        _showErrorDialog('Please fill in all required fields.');
        setState(() {
          isLoading = false;
        });
        return;
      }
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      // Retrieve user details from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;
        String userType = userData['userType'] ?? '';
        String status = userData['status'] ?? '';
        String storedFacilitatorCode = userData['facilitatorCode'] ?? '';

        // Check if user is a facilitator and status is approved
        if (userType == 'facilitator') {
          // Navigate to FacilitatorHome after successful login
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) => FacilitatorHome(
                      facilitatorId: userCredential.user!.uid,
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
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        errorMessage = 'Email or password was incorrect.';
      } else {
        errorMessage = 'An unexpected error occurred. Please try again.';
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
            'Facilitator Log In',
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
                FirebaseAuth.instance
                    .sendPasswordResetEmail(email: emailController.text.trim())
                    .then((_) {
                  _showErrorDialog('Password reset email sent.');
                }).catchError((error) {
                  _showErrorDialog('Failed to send password reset email.');
                });
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
              inputController: facilitatorCodeController,
              headerText: "Facilitator Code (Optional)",
              hintText: 'Enter your facilitator code',
              keyboardType: 'intType',
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          isLoading
              ? const CircularProgressIndicator()
              : CustomButton(
                  buttonText: 'Login',
                  buttonColor: Mycolors().green,
                  onPressed: _loginFacilitator,
                  width: 100),
          const SizedBox(
            height: 25,
          ),
          const Spacer(),
        ]),
      ),
    );
  }
}
