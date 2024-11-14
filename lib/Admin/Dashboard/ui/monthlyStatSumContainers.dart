import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../myutility.dart';

class MonthlyStatSumContainers extends StatefulWidget {
  final String header;
  final String totalSum;
  final String increasedAmount;
  const MonthlyStatSumContainers(
      {super.key,
      required this.header,
      required this.totalSum,
      required this.increasedAmount});

  @override
  State<MonthlyStatSumContainers> createState() =>
      _MonthlyStatSumContainersState();
}

class _MonthlyStatSumContainersState extends State<MonthlyStatSumContainers> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MyUtility(context).width < 1500
          ? EdgeInsets.symmetric(vertical: 10, horizontal: 8)
          : EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: Container(
        width: MyUtility(context).width < 1500 ? 290 : 380,
        height: MyUtility(context).width < 1500 ? 270 : 380,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.header,
                  style: GoogleFonts.kanit(
                      fontWeight: FontWeight.w600,
                      fontSize: MyUtility(context).width < 1500 ? 22 : 28),
                ),
              ),
              const Spacer(),
              Text(
                widget.totalSum,
                style: GoogleFonts.kanit(
                    fontWeight: FontWeight.w600,
                    fontSize: MyUtility(context).width < 1500 ? 45 : 55),
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.north,
                    color: Mycolors().green,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    widget.increasedAmount,
                    style: GoogleFonts.kanit(
                        fontWeight: FontWeight.w600,
                        fontSize: MyUtility(context).width < 1500 ? 20 : 22),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                'Current Month',
                style: GoogleFonts.kanit(
                    fontWeight: FontWeight.w600,
                    fontSize: MyUtility(context).width < 1500 ? 16 : 18,
                    color: const Color.fromARGB(255, 185, 185, 185)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
