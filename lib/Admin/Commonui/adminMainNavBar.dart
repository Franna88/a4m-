import 'package:a4m/Constants/myColors.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';

class AdminMainNavBar extends StatefulWidget {
  final Widget child;
  const AdminMainNavBar({super.key, required this.child});

  @override
  State<AdminMainNavBar> createState() => _AdminMainNavBarState();
}

class _AdminMainNavBarState extends State<AdminMainNavBar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Mycolors().offWhite,
      body: Row(
        children: [
          Container(
            width: 280,
            height: MyUtility(context).height,
            color: Colors.white,
            child: Column(
              children: [
                Image.asset(
                  'images/a4mLogo.png',
                  height: 50,
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                color: Mycolors().darkGrey,
                height: 50,
                width: MyUtility(context).width - 280,
              ),
              widget.child
            ],
          ),
        ],
      ),
    );
  }
}
