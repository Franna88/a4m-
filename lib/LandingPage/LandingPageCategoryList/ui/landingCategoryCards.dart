import 'package:a4m/Constants/myColors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LandingCategoryCards extends StatefulWidget {
  final String image;
  final Color gradientColor;
  final Color hoverColor;
  const LandingCategoryCards(
      {super.key,
      required this.image,
      required this.gradientColor,
      required this.hoverColor});

  @override
  State<LandingCategoryCards> createState() => _LandingCategoryCardsState();
}

class _LandingCategoryCardsState extends State<LandingCategoryCards> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          isHovered = false;
        });
      },
      child: SizedBox(
        width: 320,
        height: 300,
        child: Stack(
          children: [
            // Container 1 (Static background)
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                width: 310,
                height: 290,
                decoration: BoxDecoration(
                  color: widget.hoverColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            // Container 2 (Hover Animated)
            AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              bottom: isHovered ? 7 : 0,
              left: isHovered ? 7 : 0,
              child: Container(
                width: 310,
                height: 290,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 170,
                      width: 310,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                        image: DecorationImage(
                          image: AssetImage(widget.image),
                          fit: BoxFit.fill,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const SizedBox(height: 10),
                          Container(
                            height: 60,
                            width: 310,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  widget.gradientColor,
                                  const Color.fromARGB(0, 255, 255, 255),
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Placeholder Category',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
