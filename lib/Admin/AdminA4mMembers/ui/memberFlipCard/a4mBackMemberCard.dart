import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../CommonComponents/buttons/slimButtons.dart';
import '../../../../Themes/Constants/myColors.dart';

class A4mBackMemberCard extends StatefulWidget {
  const A4mBackMemberCard({super.key});

  @override
  State<A4mBackMemberCard> createState() => _A4mBackMemberCardState();
}

class _A4mBackMemberCardState extends State<A4mBackMemberCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 330,
        height: 560,
       color: Colors.white,
        child: Column(
          children: [
            Container(
              height: 140,
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
                        child: 
                        //Button to flip animation
                        InkWell(
                          onTap: () {
                            
                          },
                          child: Icon(Icons.double_arrow)),
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
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
                style: GoogleFonts.kanit(fontWeight: FontWeight.w500),
              ),
            ),
            const Spacer(),
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
      ),
    );
  }
}
