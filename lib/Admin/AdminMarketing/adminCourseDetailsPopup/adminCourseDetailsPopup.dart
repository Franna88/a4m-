import 'package:a4m/CommonComponents/buttons/CustomButton.dart';
import 'package:a4m/CommonComponents/inputFields/myDropDownMenu.dart';
import 'package:a4m/CommonComponents/inputFields/myTextFields.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_network/image_network.dart';

import '../../../Themes/Constants/myColors.dart';

class AdminCourseDetailsPopup extends StatefulWidget {
  final Map<String, dynamic> course;

  const AdminCourseDetailsPopup({super.key, required this.course});

  @override
  State<AdminCourseDetailsPopup> createState() =>
      _AdminCourseDetailsPopupState();
}

class _AdminCourseDetailsPopupState extends State<AdminCourseDetailsPopup> {
  @override
  Widget build(BuildContext context) {
    final changePrice =
        TextEditingController(text: widget.course['coursePrice']?.toString());
    final discountPrice = TextEditingController();

    return Container(
      height: 610,
      width: 800,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Container(
            width: 800,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: ImageNetwork(
                image: widget.course['courseImageUrl'] ??
                    'https://example.com/placeholder.png',
                height: 200,
                width: 800,
                fitWeb: BoxFitWeb.fill,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.course['courseName'] ?? 'Unknown',
                      style: GoogleFonts.kanit(fontSize: 25),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  widget.course['courseDescription'] ??
                      'No description available.',
                  style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  'R${widget.course['coursePrice']?.toString() ?? '0'}',
                  style: GoogleFonts.kanit(fontSize: 25),
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 300,
                      child: MyTextFields(
                          inputController: changePrice,
                          headerText: 'Change Price',
                          keyboardType: ''),
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                    MyDropDownMenu(
                        description: 'Discount Price',
                        customSize: 300,
                        items: ['5 %', '10 %', '15 %', '20 %', '25 %', '30 %'],
                        textfieldController: discountPrice)
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Image.asset('images/facebookIcon.png'),
                    const SizedBox(
                      width: 30,
                    ),
                    Image.asset('images/xIcon.png'),
                    const SizedBox(
                      width: 30,
                    ),
                    Image.asset('images/instagramIcon.png'),
                    const Spacer(),
                    CustomButton(
                      buttonText: 'Save',
                      buttonColor: Mycolors().darkGrey,
                      onPressed: () async {
                        String newPrice = changePrice.text;
                        String courseId = widget
                            .course['courseId']; // Ensure courseId is available

                        if (courseId == null || courseId.isEmpty) {
                          print("Error: No courseId provided!");
                          return;
                        }

                        try {
                          // Update the price in Firebase
                          await FirebaseFirestore.instance
                              .collection('courses')
                              .doc(courseId)
                              .update({'coursePrice': newPrice});

                          print("Course price updated successfully!");

                          // Refresh the parent screen
                          Navigator.pop(context,
                              true); // Return true to indicate an update
                        } catch (e) {
                          print("Error updating price: $e");
                        }
                      },
                      width: 80,
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
