import 'package:a4m/Constants/myColors.dart';
import 'package:a4m/LandingPage/LandingPageCategoryList/ui/landingCategoryCards.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LandingPageCategoryList extends StatefulWidget {
  const LandingPageCategoryList({super.key});

  @override
  State<LandingPageCategoryList> createState() =>
      _LandingPageCategoryListState();
}

class _LandingPageCategoryListState extends State<LandingPageCategoryList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      width: MyUtility(context).width,
      color: Mycolors().navyBlue,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: MyUtility(context).width * 0.70,
            child: Text(
              'Explore our comprehensive range of courses designed to equip you with the skills and knowledge needed in today\'s dynamic manufacturing industry. Whether you\'re a seasoned professional, a newcomer to the field, or looking to advance your career, our diverse learning paths have something for everyone.',
              style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 20),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LandingCategoryCards(
                image: 'images/categoryPlaceholder1.png',
                gradientColor: Mycolors().green,
                hoverColor: Mycolors().green,
              ),
              const SizedBox(
                width: 60,
              ),
              LandingCategoryCards(
                image: 'images/categoryPlaceholder2.png',
                gradientColor: Mycolors().blue,
                hoverColor: Mycolors().blue,
              ),
              const SizedBox(
                width: 60,
              ),
              LandingCategoryCards(
                image: 'images/categoryPlaceholder3.png',
                gradientColor: Mycolors().darkTeal,
                hoverColor: Mycolors().darkTeal,
              ),
            ],
          )
        ],
      ),
    );
  }
}
