import 'package:a4m/Constants/myColors.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class A4mAppBar extends StatefulWidget {
  final double opacity;
  final Function() onTapHome;
  final Function() onTapCourses;
  final Function() onTapContact;
  final Function() onTapLogin;
  const A4mAppBar(
      {super.key,
      required this.opacity,
      required this.onTapHome,
      required this.onTapCourses,
      required this.onTapContact,
      required this.onTapLogin});

  @override
  State<A4mAppBar> createState() => _A4mAppBarState();
}

class _A4mAppBarState extends State<A4mAppBar> {
  final List<bool> _isHovered = [false, false, false, false];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60, 
      width: MyUtility(context).width,
      color: Mycolors().navyBlue.withOpacity(widget.opacity),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Image.asset('images/a4mLogo.png'),
          ),
          const Spacer(),
          _buildNavItem('Home', 0, widget.onTapHome),
          const SizedBox(width: 60),
          _buildNavItem('Courses', 1, widget.onTapCourses),
          const SizedBox(width: 60),
          _buildNavItem('Contact Us', 2, widget.onTapContact),
          const SizedBox(width: 60),
          _buildNavItem('Login', 3, widget.onTapLogin),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildNavItem(String text, int index, Function() onTap) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered[index] = true),
      onExit: (_) => setState(() => _isHovered[index] = false),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onTap,
            child: Text(
              text,
              style: GoogleFonts.inter(
                color: _isHovered[index] ? Mycolors().green : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 2,
            width: _isHovered[index] ? 40 : 0,
            color: Mycolors().green,
            margin: const EdgeInsets.only(top: 4),
          ),
        ],
      ),
    );
  }
}
