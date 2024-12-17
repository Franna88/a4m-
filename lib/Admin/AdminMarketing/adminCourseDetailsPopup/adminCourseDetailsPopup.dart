import 'package:a4m/CommonComponents/buttons/CustomButton.dart';
import 'package:a4m/CommonComponents/inputFields/myDropDownMenu.dart';
import 'package:a4m/CommonComponents/inputFields/myTextFields.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../Themes/Constants/myColors.dart';

class AdminCourseDetailsPopup extends StatefulWidget {
  const AdminCourseDetailsPopup({super.key});

  @override
  State<AdminCourseDetailsPopup> createState() =>
      _AdminCourseDetailsPopupState();
}

class _AdminCourseDetailsPopupState extends State<AdminCourseDetailsPopup> {
  @override
  Widget build(BuildContext context) {
    final changePrice = TextEditingController();
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
              image: DecorationImage(
                image: AssetImage('images/course1.png'),
                fit: BoxFit.fitWidth,
              ),
            ),
            child: Column(
              children: [
                const Spacer(),
                Container(
                  height: 60,
                  width: 800,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Mycolors().green,
                        const Color.fromARGB(0, 255, 255, 255),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ],
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
                      'Manufacturing Level 1',
                      style: GoogleFonts.kanit(fontSize: 25),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  'This skills program provides learners with the range of learning and skills required to be able to perform a series of activities to support manufacturing, engineering and technology processes. Learners will acquire a range of skills in the identification of production parameters in manufacturing, engineering and technology industries and basic strategies to achieve them. ',
                  style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  'R239',
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
                        onPressed: () {},
                        width: 80)
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
