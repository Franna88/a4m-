import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../myutility.dart';
import '../sendButton.dart';

class AdminInbox extends StatefulWidget {
  const AdminInbox({super.key});

  @override
  State<AdminInbox> createState() => _AdminInboxState();
}

class _AdminInboxState extends State<AdminInbox> {
  @override
  Widget build(BuildContext context) {
    return Container(
            width: MyUtility(context).width - 580,
            height: MyUtility(context).height - 110,
            color: Color.fromRGBO(217, 217, 217, 1),
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Row(
                    children: [
                      Text(
                        'Josh Bennet',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.error_outline),
                      const SizedBox(
                        width: 20,
                      ),
                      Icon(
                        Icons.delete_outline,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: MyUtility(context).width - 580,
                  height: MyUtility(context).height - 211,
                  
                ),
                Container(
                  height: 55,
                  width: MyUtility(context).width - 580,
                  color: Colors.white,
                  child: Row(
                    children: [
                      Container(
                        width: MyUtility(context).width - 800,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: TextField(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Write Message',
                              hintStyle: GoogleFonts.nunitoSans(
                                color: const Color.fromARGB(255, 185, 185, 185),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.attach_file,
                        color: const Color.fromARGB(255, 185, 185, 185),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Icon(
                        Icons.image,
                        color: const Color.fromARGB(255, 185, 185, 185),
                      ),
                      const Spacer(),
                      SendButton(
                        onTap: () {},
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}