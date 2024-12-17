import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContentDevTextfields extends StatelessWidget {
  final String? hintText;
  final String? headerText;
  final String keyboardType;
  final TextEditingController inputController;
  final bool? isOptional;

  final int? maxLines; // New parameter for max lines

  const ContentDevTextfields({
    Key? key,
    required this.inputController,
    this.hintText,
    this.headerText,
    required this.keyboardType,
    this.isOptional,
    this.maxLines, // Add maxLines to the constructor
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
        if (headerText != null) // Check if headerText is not null
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                headerText!,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black),
              ),
              Visibility(
                visible: isOptional == true,
                child: Text(
                  'Optional',
                  style: GoogleFonts.inter(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                      fontSize: 12),
                ),
              )
            ],
          ),
        if (headerText != null)
          const SizedBox(height: 8), // Add spacing if headerText is not null
        Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
                offset: const Offset(12, 26),
                blurRadius: 50,
                spreadRadius: 0,
                color: Colors.grey.withOpacity(.1)),
          ]),
          child: TextField(
            controller: inputController,
            maxLines: maxLines ?? 1, // Default to 1 line if not provided
            keyboardType: keyboardType == 'email'
                ? TextInputType.emailAddress
                : keyboardType == 'intType'
                    ? TextInputType.number
                    : TextInputType.multiline,
            style: const TextStyle(fontSize: 12, color: Colors.black),
            decoration: InputDecoration(
              filled: true,
              fillColor: accentColor,
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.withOpacity(.75)),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
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
