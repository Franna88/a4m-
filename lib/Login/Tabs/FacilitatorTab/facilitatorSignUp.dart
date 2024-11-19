import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../CommonComponents/buttons/CustomButton.dart';
import '../../../CommonComponents/inputFields/myTextFields.dart';
import '../../../Constants/myColors.dart';

class FacilitatorSignUp extends StatefulWidget {
  const FacilitatorSignUp({super.key});

  @override
  State<FacilitatorSignUp> createState() => _FacilitatorSignUpState();
}

class _FacilitatorSignUpState extends State<FacilitatorSignUp> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneNumController = TextEditingController();
  final companyNameController = TextEditingController();
  final companyEmailController = TextEditingController();

  bool isFirstStep = true;
  bool isLoading = false;

  Future<void> _signUpFacilitator() async {
    setState(() {
      isLoading = true;
    });

    try {
      String email = emailController.text.trim();
      String password = passwordController.text.trim();
      String name = nameController.text.trim();
      String phoneNumber = phoneNumController.text.trim();
      String companyName = companyNameController.text.trim();
      String companyEmail = companyEmailController.text.trim();

      if (email.isEmpty ||
          password.isEmpty ||
          phoneNumber.isEmpty ||
          companyName.isEmpty ||
          companyEmail.isEmpty) {
        _showErrorDialog('please fill in all required fields');
        setState(
          () {
            isLoading = false;
          },
        );
        return;
      }

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      String uid = userCredential.user!.uid;

      // save facilitator profile
      await FirebaseFirestore.instance.collection('Users').doc(uid).set({
        'userType': 'facilitator',
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'companyName': companyName,
        'companyEmail': companyEmail,
      });

      _showSuccessDialog('Registration successful.');
    } catch (e) {
      print('Error during signup: $e');
      _showErrorDialog('An error occurred. Please try again.');
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
        title: const Text('Error'),
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

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
              // Optionally navigate to login or some other page
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
        height: 600,
        child: Column(
          children: [
            Text(
              'Facilitator Sign Up',
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
              const SizedBox(height: 15),
              SizedBox(
                width: 380,
                child: MyTextFields(
                  inputController: emailController,
                  headerText: "Email",
                  hintText: 'Enter your email',
                  keyboardType: 'email',
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: 380,
                child: MyTextFields(
                  inputController: passwordController,
                  headerText: "Password",
                  hintText: 'Enter your password',
                  keyboardType: '',
                ),
              ),
              const SizedBox(height: 15),
            ] else ...[
              SizedBox(
                width: 380,
                child: MyTextFields(
                  inputController: companyNameController,
                  headerText: "Company Name",
                  keyboardType: '',
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: 380,
                child: MyTextFields(
                  inputController: companyEmailController,
                  headerText: "Company Email",
                  keyboardType: 'email',
                ),
              ),
            ],

            const SizedBox(height: 25),
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
                        _signUpFacilitator(); // Handle sign-up submission
                      }
                    },
                    width: 120,
                  ),
          ],
        ),
      ),
    );
  }
}
