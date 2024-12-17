import 'package:a4m/CommonComponents/buttons/slimButtons.dart';
import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class A4mMembersCard extends StatefulWidget {
  const A4mMembersCard({super.key});

  @override
  State<A4mMembersCard> createState() => _A4mMembersCardState();
}

class _A4mMembersCardState extends State<A4mMembersCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 330,
        height: 560,
        color: Colors.white,
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  height: 200,
                  width: 330,
                  color: Mycolors().darkGrey,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 120,
                        width: 170,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('images/a4mLogo.png'),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                                onTap: () {}, child: Icon(Icons.double_arrow)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10, right: 15),
                            child: Text(
                              'Lecturer',
                              style: GoogleFonts.montserrat(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Spacer(),
                Container(
                  height: 45,
                  width: 330,
                  color: Mycolors().green,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SlimButtons(
                            buttonText: 'Message',
                            buttonColor: Mycolors().darkTeal,
                            onPressed: () {},
                            customWidth: 110),
                        SlimButtons(
                            buttonText: 'Remove',
                            buttonColor: Mycolors().peach,
                            onPressed: () {},
                            customWidth: 70)
                      ],
                    ),
                  ),
                )
              ],
            ),
            Positioned(
              bottom: 55,
              right: 30,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jesse Pikmon',
                    style: GoogleFonts.montserrat(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      Image.asset(
                        'images/hatIcon.png',
                        color: Mycolors().green,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        '1 Course',
                        style: GoogleFonts.kanit(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        color: Mycolors().green,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        '234 Student',
                        style: GoogleFonts.kanit(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Mycolors().green,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        '4.4 Rating',
                        style: GoogleFonts.kanit(fontWeight: FontWeight.w600),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Positioned(
              right: 15,
              top: 110,
              child: Container(
                height: 250,
                width: 180,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(
                        'images/person1.png',
                      ),
                      fit: BoxFit.cover),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    width: 1.5,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Positioned(
              left: -25,
              bottom: 170,
              child: Transform.rotate(
                angle: 80.1,
                child: Text(
                  'A4M MEMBER',
                  style: GoogleFonts.montserrat(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
