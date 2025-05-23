import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyTextStyles {
  BuildContext context;
  MyTextStyles(this.context);
  double get width => MediaQuery.of(context).size.width;
  TextStyle get headerWhite => GoogleFonts.kanit(
        fontWeight: FontWeight.w600,
        fontSize: MyUtility(context).width / 60,
        color: Colors.white,
      );

  TextStyle get subHeaderBlack => GoogleFonts.kanit(
        fontWeight: FontWeight.w600,
        fontSize: MyUtility(context).width / 70,
        color: Colors.black,
      );

  TextStyle get mediumBlack => GoogleFonts.kanit(
        fontWeight: FontWeight.w600,
        fontSize: MyUtility(context).width / 90,
        color: Colors.black,
      );

  TextStyle get smallBlack => GoogleFonts.kanit(
        fontWeight: FontWeight.normal,
        fontSize: MyUtility(context).width / 110,
        color: Colors.black,
      );

  TextStyle get caption => GoogleFonts.kanit(
        fontWeight: FontWeight.w600,
        fontSize: MyUtility(context).width < 1500 ? 12 : 14,
        color: Colors.grey,
      );
}
