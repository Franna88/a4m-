import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../CommonComponents/CustomButton.dart';
import '../../../CommonComponents/myTextFields.dart';
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

  bool isFirstStep = true;

  @override
  Widget build(BuildContext context) {
    return Column(
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
              inputController: phoneNumController,
              headerText: "Company Name",
              keyboardType: '',
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: 380,
            child: MyTextFields(
              inputController: phoneNumController,
              headerText: "Company Email",
              keyboardType: 'email',
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

        const SizedBox(height: 25),
        Container(
          height: 180,
          width: 500,
          color: Mycolors().navyBlue,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already Have an Account?',
                  style: GoogleFonts.kanit(color: Colors.white, fontSize: 12),
                ),
                const SizedBox(height: 25),
                CustomButton(
                  buttonText: 'Login',
                  buttonColor: Mycolors().green,
                  onPressed: () {
                    // TO DO: Navigate to login
                  },
                  width: 100,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
