import 'package:a4m/Constants/myColors.dart';
import 'package:a4m/Login/Tabs/ContentDevTab/contentDevLogin.dart';
import 'package:a4m/Login/Tabs/FacilitatorTab/facilitatorLogin.dart';
import 'package:a4m/Login/Tabs/FacilitatorTab/facilitatorSignUp.dart';
import 'package:a4m/Login/Tabs/LecturerTab/lecturerLogin.dart';
import 'package:a4m/Login/Tabs/LecturerTab/lecturerSignUp.dart';
import 'package:a4m/Login/Tabs/StudentTab/studentLoginTab.dart';
import 'package:a4m/Login/Tabs/StudentTab/studentSignUp.dart';
import 'package:a4m/Login/Tabs/adminLogin/adminLogin.dart';
import 'package:a4m/Login/Ui/headerStackSmall.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPopup extends StatefulWidget {
  const LoginPopup({super.key});

  @override
  State<LoginPopup> createState() => _LoginPopupState();
}

class _LoginPopupState extends State<LoginPopup> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: Colors.grey,
        body: Container(
          height: MyUtility(context).height,
          width: 500,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                height: 40,
                width: 500,
                color: Mycolors().navyBlue,
                child: Row(
                  children: [
                    Spacer(),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              HeaderStackSmall(text: 'Log In Select'),
              const SizedBox(
                height: 15,
              ),
              SizedBox(
                width: 500,
                child: TabBar(
                    indicatorColor: Mycolors().green,
                    indicatorWeight: 4,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.white,
                    tabs: [
                      Tab(
                        child: Text(
                          'Student',
                          style: GoogleFonts.montserrat(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 12),
                        ),
                      ),
                      Tab(
                        child: Text(
                          'Lecturer',
                          style: GoogleFonts.montserrat(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 12),
                        ),
                      ),
                      Tab(
                        child: Text(
                          'Content Dev',
                          style: GoogleFonts.montserrat(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 12),
                        ),
                      ),
                      Tab(
                        child: Text(
                          'Facilitator',
                          style: GoogleFonts.montserrat(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 12),
                        ),
                      ),
                      Tab(
                        child: Text(
                          'Admin',
                          style: GoogleFonts.montserrat(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 12),
                        ),
                      ),
                    ]),
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    StudentLoginTab(),
                    LecturerLogin(),
                    ContentDevLogin(),
                    FacilitatorLogin(),
                    AdminLogin()
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
