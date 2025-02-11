import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:flutter/material.dart';

class OnHoverButton extends StatefulWidget {
  final String buttonText;
  final Function() onTap;
  const OnHoverButton({super.key, required this.onTap, required this.buttonText});

  @override
  _OnHoverButtonState createState() => _OnHoverButtonState();
}

class _OnHoverButtonState extends State<OnHoverButton> {
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
            border:
                isHovered ? Border.all(color: Mycolors().green, width: 2) : Border.all(color: Colors.black, width: 2),
            
          ),
          child: Text(
            widget.buttonText,
            style: TextStyle(
              color: isHovered ? Colors.white : Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
