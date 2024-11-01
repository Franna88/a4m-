import 'package:a4m/CommonComponents/slimButtons.dart';
import 'package:a4m/Constants/myColors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpCards extends StatelessWidget {
  final Color buttonColor;
  final Function() onPressed;
  final String description;
  final String header;
  final String image;
  const SignUpCards(
      {super.key,
      required this.buttonColor,
      required this.onPressed,
      required this.description,
      required this.header,
      required this.image});

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(8),
      elevation: 10,
      child: Container(
        width: 280,
        height: 300,
        decoration: BoxDecoration(
            color: Color.fromRGBO(243, 243, 243, 1),
            borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 280,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                image: DecorationImage(
                  image: AssetImage(image),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                header,
                style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                description,
                style: GoogleFonts.montserrat(
                    color: Mycolors().darkGrey,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 15),
              child: Material(
                borderRadius: BorderRadius.circular(5),
                elevation: 5,
                child: SizedBox(
                  width: 105,
                  child: SlimButtons(
                      buttonText: 'Sign Up',
                      buttonColor: buttonColor,
                      onPressed: onPressed,
                      customWidth: 105),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
