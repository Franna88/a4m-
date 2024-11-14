import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class A4mFooter extends StatefulWidget {
  const A4mFooter({super.key});

  @override
  State<A4mFooter> createState() => _A4mFooterState();
}

class _A4mFooterState extends State<A4mFooter> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      width: MyUtility(context).width,
      color: Mycolors().navyBlue,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 180,
            width: 260,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/a4mLogo.png'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          const SizedBox(width: 100),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ACADEMY 4 MANUFACTURING SOUTH AFRICA (PTY) LTD\n\n'
                'Established since 2008\nPO Box 1762 Welgemoed, Cape Town, '
                'Western Cape 7638\nMobile: 079 7780 499\ne-mail: info@academy4manufacturing.co.za',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),
              MouseRegion(
                onEnter: (_) => setState(() => isHovered = true),
                onExit: (_) => setState(() => isHovered = false),
                child: Column(
                  children: [
                    Text(
                      'www.academy4manufacturing.co.za',
                      style: GoogleFonts.inter(
                        color: isHovered ? Colors.green : Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 2,
                      width: isHovered ? 200 : 0,
                      color: Colors.green,
                      margin: const EdgeInsets.only(top: 4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
