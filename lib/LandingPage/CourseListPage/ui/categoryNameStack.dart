import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../Themes/Constants/myColors.dart';

class CategoryNameStack extends StatelessWidget {
  final String text;
  const CategoryNameStack({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 410,
      height: 60,
      child: Stack(
        children: [
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 400,
              height: 50,
              decoration: BoxDecoration(
                color: Color.fromRGBO(113, 125, 150, 1),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 400,
              height: 50,
              decoration: BoxDecoration(
                color: Mycolors().darkGrey,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    text,
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
