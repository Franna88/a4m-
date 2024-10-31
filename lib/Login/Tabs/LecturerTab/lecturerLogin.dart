import 'package:a4m/CommonComponents/CustomButton.dart';
import 'package:a4m/CommonComponents/myTextFields.dart';
import 'package:a4m/Constants/myColors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LecturerLogin extends StatefulWidget {
  const LecturerLogin({super.key});

  @override
  State<LecturerLogin> createState() => _LecturerLoginState();
}

class _LecturerLoginState extends State<LecturerLogin> {
  @override
  Widget build(BuildContext context) {

    final email = TextEditingController();
    final password = TextEditingController();
    final lecturerCode = TextEditingController();



    return Column(
      children: [
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
            inputController: email,
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
            inputController: password,
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
            inputController: lecturerCode,
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
              //TO DO
            },
            width: 100),
        const SizedBox(
          height: 25,
        ),Spacer(),
        Container(
          height: 180,
          width: 500,
          color: Mycolors().navyBlue,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Dont have an Account ?',
                  style: GoogleFonts.kanit(color: Colors.white, fontSize: 12),
                ),
                const SizedBox(
                  height: 25,
                ),
                CustomButton(
                    buttonText: 'Sign Up',
                    buttonColor: Mycolors().blue,
                    onPressed: () {
                      //TO DO
                    },
                    width: 120),
              ],
            ),
          ),
        )
      ],
    );
  }
}
