import 'package:a4m/CommonComponents/CustomButton.dart';
import 'package:a4m/CommonComponents/myTextFields.dart';
import 'package:a4m/Constants/myColors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentLoginTab extends StatefulWidget {
  const StudentLoginTab({super.key});

  @override
  State<StudentLoginTab> createState() => _StudentLoginTabState();
}

class _StudentLoginTabState extends State<StudentLoginTab> {
  bool isSignUp = false; // Toggle between login and sign-up

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Display either the login or sign-up form based on `isSignUp`
        Expanded(
          child:
              isSignUp ? const StudentSignUpView() : const StudentLoginView(),
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

// Student Login View
class StudentLoginView extends StatelessWidget {
  const StudentLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final studentCodeController = TextEditingController();

    return Column(
      children: [
        Text(
          'Student Log In',
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
        const SizedBox(height: 5),
        InkWell(
          onTap: () {
            // TO DO: Handle forgot password action
          },
          child: Text(
            'Forgot Password?',
            textAlign: TextAlign.right,
            style: GoogleFonts.kanit(color: Mycolors().blue, fontSize: 12),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          width: 380,
          child: MyTextFields(
            inputController: studentCodeController,
            headerText: "Student Code*",
            hintText: 'Enter your student code',
            keyboardType: 'intType',
          ),
        ),
        const SizedBox(height: 25),
        CustomButton(
          buttonText: 'Login',
          buttonColor: Mycolors().green,
          onPressed: () {
            // TO DO: Handle login action
          },
          width: 100,
        ),
      ],
    );
  }
}

// Student Sign Up View
class StudentSignUpView extends StatefulWidget {
  const StudentSignUpView({super.key});

  @override
  State<StudentSignUpView> createState() => _StudentSignUpViewState();
}

class _StudentSignUpViewState extends State<StudentSignUpView> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final facilitatorCodeController = TextEditingController();
  final nameController = TextEditingController();
  final phoneNumController = TextEditingController();

  bool isFirstStep = true;

  @override
  Widget build(BuildContext context) {
    return Column(
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
      ],
    );
  }
}
