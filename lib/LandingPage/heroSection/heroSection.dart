import 'package:a4m/LandingPage/heroSection/ui/onHoverSignUpButton.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeroSection extends StatelessWidget {
  final Function() onTap;
  const HeroSection({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MyUtility(context).height * 0.90,
      width: MyUtility(context).width,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/landingHero.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            textAlign: TextAlign.center,
            'CREATING BUSINESS\nEXELLENCE AND\nSUSTAINABILITY',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 60,
              fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Text(
            textAlign: TextAlign.center,
            'EQUIP YOURSELF TO MEET AND MAINTAIN THE HIGH\nSTANDARDS IN THE MANUFACTURING INDUSTRY.',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 30,
               fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(height: 30,),
          OnHoverSignUpButton(onTap: onTap,)
        ],
      ),
    );
  }
}
