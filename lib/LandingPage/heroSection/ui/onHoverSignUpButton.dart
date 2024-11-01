import 'package:a4m/Constants/myColors.dart';
import 'package:flutter/material.dart';

class OnHoverSignUpButton extends StatefulWidget {
  final Function() onTap;
  const OnHoverSignUpButton({super.key, required this.onTap});

  @override
  _OnHoverSignUpButtonState createState() => _OnHoverSignUpButtonState();
}

class _OnHoverSignUpButtonState extends State<OnHoverSignUpButton> {
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
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          decoration: BoxDecoration(
            color: isHovered ? Mycolors().green : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isHovered ? null : Border.all(color: Colors.white, width: 2),
            boxShadow: isHovered
                ? [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(2, 4), 
                      blurRadius: 6,
                    ),
                  ]
                : [],
          ),
          child: Text(
            "Sign Up Now",
            style: TextStyle(
              color: isHovered ? Colors.white : Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
