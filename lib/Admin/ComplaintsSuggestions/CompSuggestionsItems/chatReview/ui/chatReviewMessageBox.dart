import 'package:a4m/Constants/myColors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../myutility.dart';

class ChatReviewMessageBox extends StatefulWidget {
  final String fromUserName;
  final String toUserName;
  const ChatReviewMessageBox(
      {super.key, required this.fromUserName, required this.toUserName});

  @override
  State<ChatReviewMessageBox> createState() => _ChatReviewMessageBoxState();
}

class _ChatReviewMessageBoxState extends State<ChatReviewMessageBox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MyUtility(context).width - 580,
      height: MyUtility(context).height - 110,
      color: Color.fromRGBO(217, 217, 217, 1),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: widget.fromUserName,
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      TextSpan(
                        text: ' Messages With : ',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      TextSpan(
                        text: widget.toUserName,
                        style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Mycolors().red),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          Container(
            width: MyUtility(context).width - 580,
            height: MyUtility(context).height - 211,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      width: MyUtility(context).width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      width: MyUtility(context).width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Mycolors().green),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 55,
            width: MyUtility(context).width - 580,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
