import 'package:a4m/Admin/Commonui/navButtons.dart';
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
                const SizedBox(
                  height: 10,
                ),
                Container(
                  height: 120,
                  width: 180,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(
                          'images/a4mLogo.png',
                        ),
                        fit: BoxFit.fill),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                NavButtons(
                  buttonText: 'Dashboard',
                  onTap: () {},
                ),
                const SizedBox(
                  height: 25,
                ),
                NavButtons(
                  buttonText: 'Courses',
                  onTap: () {},
                ),
                const SizedBox(
                  height: 25,
                ),
                NavButtons(
                  buttonText: 'Marketing',
                  onTap: () {},
                ),
                const SizedBox(
                  height: 25,
                ),
                NavButtons(
                  buttonText: 'A4M Members',
                  onTap: () {},
                ),
                const SizedBox(
                  height: 25,
                ),
                NavButtons(
                  buttonText: 'Certification',
                  onTap: () {},
                ),
                const SizedBox(
                  height: 25,
                ),
                NavButtons(
                  buttonText: 'Review Content',
                  onTap: () {},
                ),
                const Spacer(),
                Container(
                  width: 220,
                  height: 4,
                  color: Mycolors().green,
                ),
                const Spacer(),
                NavButtons(
                  buttonText: 'Complaints/Suggestions',
                  onTap: () {},
                ),
                const SizedBox(
                  height: 25,
                ),
                NavButtons(
                  buttonText: 'Messages',
                  onTap: () {},
                ),
                const SizedBox(
                  height: 25,
                ),
                NavButtons(
                  buttonText: 'Curriculum Vitae',
                  onTap: () {},
                ),
                const SizedBox(
                  height: 25,
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Image.asset('images/notification.png'),
                    const SizedBox(
                      width: 30,
                    ),
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.grey,
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                  ],
                ),
              ),
              widget.child
            ],
          ),
        ],
      ),
    );
  }
}
