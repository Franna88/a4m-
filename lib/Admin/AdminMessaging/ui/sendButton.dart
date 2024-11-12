import 'package:a4m/Constants/myColors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SendButton extends StatefulWidget {
  final Function() onTap;
  const SendButton({super.key, required this.onTap});

  @override
  State<SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<SendButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: widget.onTap,
      child: Container(
        width: 110,
        
        decoration: BoxDecoration(
          color: Mycolors().blue,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Send',
                style: GoogleFonts.nunitoSans(
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Image.asset('images/sendIcon.png')
            ],
          ),
        ),
      ),
    );
  }
}
