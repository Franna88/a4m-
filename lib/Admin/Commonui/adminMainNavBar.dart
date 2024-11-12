import 'package:a4m/CommonComponents/buttons/navButtons.dart';
import 'package:a4m/Constants/myColors.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';

class AdminMainNavBar extends StatefulWidget {
  final Function(int) changePage;
  final Widget child;
  const AdminMainNavBar(
      {super.key, required this.child, required this.changePage});

  @override
  State<AdminMainNavBar> createState() => _AdminMainNavBarState();
}

class _AdminMainNavBarState extends State<AdminMainNavBar> {
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
                  buttonText: 'Dashboard',
                  onTap: () => _handleItemClick(0),
                  isActive: activeIndex == 0,
                ),
                const SizedBox(
                  height: 25,
                ),
                NavButtons(
                  buttonText: 'Courses',
                   onTap: () => _handleItemClick(1),
                  isActive: activeIndex == 1,
                ),
                const SizedBox(
                  height: 25,
                ),
                NavButtons(
                  buttonText: 'Marketing',
                   onTap: () => _handleItemClick(2),
                  isActive: activeIndex == 2,
                ),
                const SizedBox(
                  height: 25,
                ),
                NavButtons(
                  buttonText: 'A4M Members',
                   onTap: () => _handleItemClick(3),
                  isActive: activeIndex == 3,
                ),
                const SizedBox(
                  height: 25,
                ),
                NavButtons(
                  buttonText: 'Certification',
                   onTap: () => _handleItemClick(4),
                  isActive: activeIndex == 4,
                ),
                const SizedBox(
                  height: 25,
                ),
                NavButtons(
                  buttonText: 'Review Content',
                  onTap: () => _handleItemClick(5),
                  isActive: activeIndex == 5,
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
                  onTap: () => _handleItemClick(6),
                  isActive: activeIndex == 6,
                ),
                const SizedBox(
                  height: 25,
                ),
                NavButtons(
                  buttonText: 'Messages',
                  onTap: () => _handleItemClick(7),
                  isActive: activeIndex == 7,
                ),
                const SizedBox(
                  height: 25,
                ),
                NavButtons(
                  buttonText: 'Curriculum Vitae',
                  onTap: () => _handleItemClick(8),
                  isActive: activeIndex == 8,
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
