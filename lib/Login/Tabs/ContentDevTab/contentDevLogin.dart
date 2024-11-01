import 'package:a4m/CommonComponents/CustomButton.dart';
import 'package:a4m/CommonComponents/myTextFields.dart';
import 'package:a4m/Constants/myColors.dart';
import 'package:a4m/Login/Tabs/ContentDevTab/contentDevSignUp.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContentDevLogin extends StatefulWidget {
  const ContentDevLogin({super.key});

  @override
  State<ContentDevLogin> createState() => _ContentDevLoginState();
}

class _ContentDevLoginState extends State<ContentDevLogin> {

   bool isSignUp = false; 


  @override
  Widget build(BuildContext context) {

    



    return 
        Column(
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
  @override
  Widget build(BuildContext context) {

    final email = TextEditingController();
    final password = TextEditingController();
    final contentDevCode = TextEditingController();




    return Column(
      children: [
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
            inputController: contentDevCode,
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
              //TO DO
            },
            width: 100),
        const SizedBox(
          height: 25,
        ),
        Spacer(),]);
  }
}