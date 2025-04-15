import 'package:a4m/CommonComponents/buttons/navButtons.dart';
import 'package:a4m/LandingPage/landingPageMain.dart';
import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';
import 'package:a4m/CommonComponents/EditProfile/EditProfileDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_network/image_network.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminMainNavBar extends StatefulWidget {
  final Function(int) changePage;
  final Widget child;
  const AdminMainNavBar({
    super.key,
    required this.child,
    required this.changePage,
  });

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
    widget.changePage(index);
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
      _fetchUserProfileImage();
    });
  }

  Widget _buildNavItem(IconData icon, String title, int index) {
    bool isSelected = activeIndex == index;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _handleItemClick(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? Mycolors().green.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Mycolors().green : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? Mycolors().green : Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Mycolors().green : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    // Define page names based on activeIndex
    String currentPageName = '';
    switch (activeIndex) {
      case 0:
        currentPageName = 'Dashboard';
        break;
      case 1:
        currentPageName = 'Assign Lecturer';
        break;
      case 2:
        currentPageName = 'Pricing';
        break;
      case 3:
        currentPageName = 'A4M Team';
        break;
      case 4:
        currentPageName = 'Certification';
        break;
      case 5:
        currentPageName = 'Course Management';
        break;
      case 6:
        currentPageName = 'Evaluations';
        break;
      case 7:
        currentPageName = 'Messages';
        break;
      case 8:
        currentPageName = 'Curriculum Vitae';
        break;
      default:
        currentPageName = '';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Admin',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      if (currentPageName.isNotEmpty) ...[
                        Text(
                          ' > ',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          currentPageName,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Mycolors().green,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Here\'s what\'s happening with your platform',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () {
                        // Handle notifications
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: _showEditProfileDialog,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Mycolors().green, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: _profileImageUrl != null
                        ? ImageNetwork(
                            image: _profileImageUrl!,
                            height: 40,
                            width: 40,
                            fitAndroidIos: BoxFit.cover,
                            fitWeb: BoxFitWeb.cover,
                            onLoading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Mycolors().green),
                                ),
                              ),
                            ),
                            onError: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person,
                                color: Colors.grey[400],
                                size: 24,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.person,
                            color: Mycolors().green,
                            size: 24,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Profile',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        'Edit your profile',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.edit,
                  size: 16,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _logout,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[300]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.logout,
                    size: 18,
                    color: Colors.red[400],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Logout',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.red[400],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Mycolors().offWhite,
      body: Row(
        children: [
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  height: 120,
                  width: 180,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/a4mLogo.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildNavItem(Icons.dashboard, 'Dashboard', 0),
                        _buildNavItem(Icons.description, 'Curriculum Vitae', 8),
                        _buildNavItem(
                            Icons.rate_review, 'Course Management', 5),
                        _buildNavItem(Icons.attach_money, 'Pricing', 2),
                        _buildNavItem(Icons.person_add, 'Assign Lecturer', 1),
                        _buildNavItem(Icons.rate_review, 'Evaluations', 6),
                        _buildNavItem(
                            Icons.card_membership, 'Certification', 4),
                        _buildNavItem(Icons.people, 'A4M Team', 3),
                        _buildNavItem(Icons.message, 'Messages', 7),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border(
                      top: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                  child: _buildProfileSection(),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: widget.child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
