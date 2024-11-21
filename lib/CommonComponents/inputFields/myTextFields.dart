import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class MyTextFields extends StatelessWidget {
  final String? hintText;
  final String headerText;
  final String keyboardType;
  final TextEditingController inputController;
  final bool? isOptional;
  final bool? isNumberField;
  const MyTextFields({
    Key? key,
    required this.inputController,
    this.hintText,
    required this.headerText,
    required this.keyboardType,
    this.isOptional,
    this.isNumberField,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    const primaryColor = Color.fromRGBO(203, 210, 224, 1);
    const secondaryColor = Color.fromRGBO(72, 128, 255, 1);
    const accentColor = Color(0xffffffff);
    const errorColor = Color(0xffEF4444);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              headerText,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            Visibility(
              visible: isOptional == true,
              child: Text(
                'Optional',
                style: GoogleFonts.inter(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 50,
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              offset: const Offset(12, 26),
              blurRadius: 50,
              spreadRadius: 0,
              color: Colors.grey.withOpacity(.1),
            ),
          ]),
          child: TextField(
            controller: inputController,
            keyboardType: isNumberField == true
                ? TextInputType.number
                : keyboardType == 'email'
                    ? TextInputType.emailAddress
                    : TextInputType.text,
            inputFormatters: isNumberField == true
                ? [FilteringTextInputFormatter.digitsOnly]
                : [],
            style: const TextStyle(fontSize: 14, color: Colors.black),
            decoration: InputDecoration(
              filled: true,
              fillColor: accentColor,
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.withOpacity(.75)),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: primaryColor, width: 1.5),
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: secondaryColor, width: 1.5),
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              errorBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: errorColor, width: 1.5),
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: primaryColor, width: 1.5),
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
