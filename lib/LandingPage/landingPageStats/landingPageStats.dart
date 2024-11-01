import 'package:a4m/LandingPage/landingPageStats/ui/statContainers.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';

class LandingPageStats extends StatefulWidget {
  const LandingPageStats({super.key});

  @override
  State<LandingPageStats> createState() => _LandingPageStatsState();
}

class _LandingPageStatsState extends State<LandingPageStats> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      width: MyUtility(context).width,
      color: Colors.white,
      child: Row(mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //To DO : INCLUDE ACTUAL COUNT
          StatContainers(header: 'Online Courses', count: '3500+'),
          const SizedBox(
            width: 100,
          ),
          Container(
            height: 80,
            width: 6,
            color: const Color.fromARGB(255, 206, 206, 206),
          ),
          const SizedBox(
            width: 100,
          ),
          //To DO : INCLUDE ACTUAL COUNT
          StatContainers(header: 'Students', count: '8000+'),
        ],
      ),
    );
  }
}
