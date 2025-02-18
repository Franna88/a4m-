import 'package:a4m/CommonComponents/buttons/navButtons.dart';
import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';

class StudentNavBar extends StatefulWidget {
  final Function(int) changePage;
  final Widget child;
  const StudentNavBar(
      {super.key, required this.child, required this.changePage});

  @override
  State<StudentNavBar> createState() => _StudentNavBarState();
}

class _StudentNavBarState extends State<StudentNavBar> {
  int activeIndex = 0;

  void _handleItemClick(int index) {
    setState(() {
      activeIndex = index;
    });
    widget.changePage(index); // Notify the parent widget to change the page
  }

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
                  buttonText: 'My Course',
                  onTap: () => _handleItemClick(0),
                  isActive: activeIndex == 0,
                ),
                const SizedBox(
                  height: 25,
                ),
                NavButtons(
                  buttonText: 'Browse Courses',
                  onTap: () => _handleItemClick(1),
                  isActive: activeIndex == 1,
                ),
                const SizedBox(
                  height: 25,
                ),
                NavButtons(
                  buttonText: 'Assessments',
                  onTap: () => _handleItemClick(2),
                  isActive: activeIndex == 2,
                ),
                const SizedBox(
                  height: 25,
                ),
                NavButtons(
                  buttonText: 'Review Assessments',
                  onTap: () => _handleItemClick(3),
                  isActive: activeIndex == 3,
                ),
                const SizedBox(
                  height: 25,
                ),
                NavButtons(
                  buttonText: 'My Certificates',
                  onTap: () => _handleItemClick(4),
                  isActive: activeIndex == 4,
                ),
                const SizedBox(
                  height: 25,
                ),
                
                const Spacer(),
                Container(
                  width: 220,
                  height: 4,
                  color: Mycolors().green,
                ),
                const Spacer(),
               NavButtons(
                  buttonText: 'Messages',
                  onTap: () => _handleItemClick(5),
                  isActive: activeIndex == 5,
                ),
                const SizedBox(
                  height: 25,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
