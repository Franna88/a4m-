import 'package:a4m/LandingPage/landingPageMain.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyAuBnb6FAMGp1Q-1TONFnXr31vlH_BqbM8",
          authDomain: "a-4-m-13d70.firebaseapp.com",
          projectId: "a-4-m-13d70",
          storageBucket: "a-4-m-13d70.firebasestorage.app",
          messagingSenderId: "1000734229320",
          appId: "1:1000734229320:web:f351c28b1be78a632d297d"),
    );
    print("Firebase initialized successfully");
  } catch (e) {
    print("Error initializing Firebase: $e");
  }
  runApp(
    const MaterialApp(
      home: Scaffold(
          body: /*StudentMain(
        studentId: '',
      )*/
              //ContentDevHome(),
              //CourseListPage()
              LandingPageMain()
          // AdminHome()
          // LoginPopup(),),
          ),
    ),
  );
}
