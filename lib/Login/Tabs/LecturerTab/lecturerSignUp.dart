import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../CommonComponents/buttons/CustomButton.dart';
import '../../../CommonComponents/inputFields/myTextFields.dart';
import '../../../Themes/Constants/myColors.dart';

class LecturerSignUp extends StatefulWidget {
  const LecturerSignUp({super.key});

  @override
  State<LecturerSignUp> createState() => _LecturerSignUpState();
}

class _LecturerSignUpState extends State<LecturerSignUp> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneNumController = TextEditingController();

  bool isFirstStep = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Lecturer Sign Up',
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
          // Second Step: Email, Password, and CV Upload
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Please Upload Your CV*',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                ),
                InkWell(
                  onTap: () {
                    // TO DO: Handle CV upload
                  },
                  child: Image.asset('images/upload.png'),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 25),
        // "Next" or "Sign Up" Button
        CustomButton(
          buttonText: isFirstStep ? 'Next' : 'Sign Up',
          buttonColor: Mycolors().blue,
          onPressed: () {
            if (isFirstStep) {
              setState(() {
                isFirstStep = false; // Move to the next step
              });
            } else {
              // TO DO: Handle sign-up submission
            }
          },
          width: 120,
        ),
      ],
    );
  }
}
