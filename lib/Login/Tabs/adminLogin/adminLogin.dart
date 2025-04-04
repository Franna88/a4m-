import 'package:a4m/CommonComponents/buttons/CustomButton.dart';
import 'package:a4m/CommonComponents/inputFields/myTextFields.dart';
import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:a4m/adminHome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final emailController = TextEditingController(text: "tertiuscva@gmail.com");
  final passwordController = TextEditingController(text: "test123");
  final adminCodeController = TextEditingController();

  bool isLoading = false;

  Future<void> _AdminLogin() async {
    setState(() {
      isLoading = true;
    });

    try {
      String email = emailController.text.trim();
      String password = passwordController.text.trim();
      //String adminCode = adminCodeController.text.trim();

      if (email.isEmpty || password.isEmpty /*|| adminCode.isEmpty*/) {
        _showErrorDialog('Please fill in all required fields');
        setState(() {
          isLoading = false;
        });
        return;
      }

      //Authenticate user
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // get user info
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;
        String userType = userData['userType'] ?? '';

        // Verify userType is 'admin' and adminCode matches
        if (userType == 'admin' /* && userData['adminCode'] == adminCode*/) {
          // Navigate to AdminHome
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => AdminHome()));
        } else {
          _showErrorDialog('Invalid credentials or you are not an admin');
        }
      } else {
        _showErrorDialog('User not found');
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

  // Method to show error dialogs
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
      child: Column(
        children: [
          Text(
            'Admin Log In',
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
              inputController: adminCodeController,
              headerText: "admin Code*",
              hintText: 'Enter your Admin code',
              keyboardType: 'intType',
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          CustomButton(
              buttonText: 'Login',
              buttonColor: Mycolors().green,
              onPressed: _AdminLogin,
              width: 100),
          const SizedBox(
            height: 25,
          ),
          Container(
            height: 180,
            width: 500,
            color: Mycolors().navyBlue,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [],
              ),
            ),
          )
        ],
      ),
    );
  }
}
