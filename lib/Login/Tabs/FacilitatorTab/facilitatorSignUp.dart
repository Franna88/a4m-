import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../CommonComponents/buttons/CustomButton.dart';
import '../../../CommonComponents/inputFields/myTextFields.dart';
import '../../../Themes/Constants/myColors.dart';

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

  File? cvFile; // Mobile/Desktop
  Uint8List? cvFileBytes; // Web: store the file as bytes
  String? cvFileName;

  bool isLoading = false;

  Future<void> _pickCVFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.isNotEmpty) {
        if (kIsWeb) {
          final fileBytes = result.files.single.bytes;
          if (fileBytes != null) {
            setState(() {
              cvFileBytes = fileBytes;
              cvFileName =
                  result.files.single.name; // Save file name for reference
            });
            print('File picked successfully (web): $cvFileName');
          } else {
            _showErrorDialog('CV upload was cancelled or failed.');
          }
        } else {
          final filePath = result.files.single.path;
          if (filePath != null) {
            setState(() {
              cvFile = File(filePath);
            });
            print(
                'File picked successfully (mobile): ${result.files.single.name}');
          } else {
            _showErrorDialog('CV upload was cancelled or failed.');
          }
        }
      } else {
        _showErrorDialog('CV upload was cancelled or failed.');
      }
    } catch (e) {
      print('Error during file pick: $e');
      _showErrorDialog('An error occurred while picking the file.');
    }
  }

  Future<void> _signUpFacilitator() async {
    if ((!kIsWeb && cvFile == null) || (kIsWeb && cvFileBytes == null)) {
      _showErrorDialog('Please upload your CV before signing up.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String email = emailController.text.trim();
      String password = passwordController.text.trim();
      String name = nameController.text.trim();
      String phoneNumber = phoneNumController.text.trim();

      if (email.isEmpty ||
          password.isEmpty ||
          name.isEmpty ||
          phoneNumber.isEmpty) {
        _showErrorDialog('Please fill in all required fields');
        setState(() {
          isLoading = false;
        });
        return;
      }

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      String uid = userCredential.user!.uid;

      // Upload CV
      final fileName = '$uid.pdf';
      final storageRef = FirebaseStorage.instance.ref().child('CVs/$fileName');

      String cvUrl;
      if (kIsWeb) {
        // Web: Upload using bytes
        UploadTask uploadTask = storageRef.putData(cvFileBytes!);
        TaskSnapshot storageSnapshot = await uploadTask;
        cvUrl = await storageSnapshot.ref.getDownloadURL();
      } else {
        // Mobile/Desktop: Upload using file
        UploadTask uploadTask = storageRef.putFile(cvFile!);
        TaskSnapshot storageSnapshot = await uploadTask;
        cvUrl = await storageSnapshot.ref.getDownloadURL();
      }

      //submission date
      String submissionDate = DateTime.now().toIso8601String().split('T')[0];

      // Save facilitator profile
      await FirebaseFirestore.instance.collection('Users').doc(uid).set({
        'userType': 'facilitator',
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'cvUrl': cvUrl,
        'status': 'pending',
        'submissionDate': submissionDate,
      });

      _showSuccessDialog(
          'Registration successful. Please wait for admin approval.');
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
            SizedBox(
              width: 380,
              child: MyTextFields(
                inputController: nameController,
                headerText: "Full Name *",
                hintText: 'Name and surname',
                keyboardType: '',
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: 380,
              child: MyTextFields(
                inputController: phoneNumController,
                headerText: "Phone Number *",
                hintText: '082 222 959 332',
                keyboardType: 'intType',
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: 380,
              child: MyTextFields(
                inputController: emailController,
                headerText: "Email *",
                hintText: 'Enter your email',
                keyboardType: 'email',
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: 380,
              child: MyTextFields(
                inputController: passwordController,
                headerText: "Password *",
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
                    'Please Upload Your CV *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  InkWell(
                    onTap: _pickCVFile,
                    child: cvFile == null && cvFileBytes == null
                        ? Image.asset('images/upload.png')
                        : const Icon(Icons.check, color: Colors.green),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            isLoading
                ? CircularProgressIndicator()
                : CustomButton(
                    buttonText: 'Sign Up',
                    buttonColor: Mycolors().blue,
                    onPressed: _signUpFacilitator,
                    width: 120,
                  ),
          ],
        ),
      ),
    );
  }
}
