import 'package:a4m/CommonComponents/buttons/navButtons.dart';
import 'package:a4m/LandingPage/landingPageMain.dart';
import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';
import 'package:a4m/CommonComponents/EditProfile/EditProfileDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_network/image_network.dart';

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
  String? _profileImageUrl;
  final String _userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _fetchUserProfileImage();
  }

  Future<void> _fetchUserProfileImage() async {
    if (_userId.isEmpty) return;

    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(_userId)
          .get();

      if (docSnapshot.exists && mounted) {
        final userData = docSnapshot.data();
        setState(() {
          _profileImageUrl = userData?['profileImageUrl'];
        });
      }
    } catch (e) {
      print('Error fetching user profile image: $e');
    }
  }

  void _handleItemClick(int index) {
    setState(() {
      activeIndex = index;
    });
    widget.changePage(index); // Notify the parent widget to change the page
  }

  void _logout() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LandingPageMain()),
    );
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return EditProfileDialog(
          userId: _userId,
          userType: 'admin',
        );
      },
    ).then((_) {
      // Refresh profile image after editing
      _fetchUserProfileImage();
    });
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
                  buttonText: 'Pricing',
                  onTap: () => _handleItemClick(2),
                  isActive: activeIndex == 2,
                ),
                const SizedBox(
                  height: 25,
                ),
                NavButtons(
                  buttonText: 'A4M Team',
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
                  buttonText: 'Review Courses',
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
                    PopupMenuButton(
                      icon: _profileImageUrl != null &&
                              _profileImageUrl!.isNotEmpty
                          ? SizedBox(
                              width: 36,
                              height: 36,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: ImageNetwork(
                                  image: _profileImageUrl!,
                                  height: 36,
                                  width: 36,
                                  duration: 1500,
                                  curve: Curves.easeIn,
                                  onPointer: true,
                                  debugPrint: false,
                                  fitAndroidIos: BoxFit.cover,
                                  fitWeb: BoxFitWeb.cover,
                                  onError: CircleAvatar(
                                    radius: 18,
                                    backgroundColor: Colors.grey,
                                    child: Icon(Icons.person,
                                        color: Colors.white, size: 18),
                                  ),
                                  onLoading: CircleAvatar(
                                    radius: 18,
                                    backgroundColor: Colors.grey[300],
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: CircularProgressIndicator(
                                        color: Colors.grey,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.grey,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit_profile',
                          child: Text('Edit Profile'),
                        ),
                        PopupMenuItem(
                          value: 'logout',
                          child: Text('Logout'),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'logout') {
                          _logout();
                        } else if (value == 'edit_profile') {
                          _showEditProfileDialog();
                        }
                      },
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SizedBox(
                  width: MyUtility(context).width - 280,
                  child: widget.child,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
