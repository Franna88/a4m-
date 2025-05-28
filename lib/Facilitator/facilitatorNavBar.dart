import 'package:a4m/CommonComponents/buttons/navButtons.dart';
import 'package:a4m/Constants/myColors.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';
import 'package:a4m/LandingPage/LandingPageMain.dart'; // Import the LandingPageMain
import 'package:a4m/CommonComponents/EditProfile/EditProfileDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_network/image_network.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:a4m/CommonComponents/buttons/CustomButton.dart';
import 'package:a4m/Facilitator/Pages/Dashboard/ui/FacilitatorStudentPopup.dart';

class FacilitatorNavBar extends StatefulWidget {
  final Function(int) changePage;
  final Widget child;
  final int initialIndex;
  const FacilitatorNavBar({
    super.key,
    required this.child,
    required this.changePage,
    this.initialIndex = 0,
  });

  @override
  State<FacilitatorNavBar> createState() => _FacilitatorNavBarState();
}

class _FacilitatorNavBarState extends State<FacilitatorNavBar> {
  late int activeIndex;
  String? _profileImageUrl;
  final String _userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  final ScrollController _scrollController = ScrollController();

  // Add state variables for dashboard stats
  int _activeCourses = 0;
  int _totalStudents = 0;
  int _monthlyStudents = 0;
  int _completedModules = 0;
  double _studentPassRate = 0.0;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    activeIndex = widget.initialIndex;
    _fetchUserProfileImage();
    _fetchDashboardStats();
  }

  @override
  void didUpdateWidget(FacilitatorNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      activeIndex = widget.initialIndex;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

  Future<void> _fetchDashboardStats() async {
    if (_userId.isEmpty) return;

    try {
      setState(() => _isLoadingStats = true);

      // Get facilitator's document
      DocumentSnapshot facilitatorDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(_userId)
          .get();

      if (!facilitatorDoc.exists) {
        print('Facilitator document not found');
        return;
      }

      // Get facilitator's courses
      List<dynamic> facilitatorCourses =
          facilitatorDoc['facilitatorCourses'] ?? [];
      _activeCourses = facilitatorCourses.length;

      // Get total students and monthly students
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      QuerySnapshot studentsSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(_userId)
          .collection('facilitatorStudents')
          .get();

      QuerySnapshot monthlySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(_userId)
          .collection('facilitatorStudents')
          .where('createdAt', isGreaterThanOrEqualTo: startOfMonth)
          .get();

      _totalStudents = studentsSnapshot.docs.length;
      _monthlyStudents = monthlySnapshot.docs.length;

      // Calculate completed modules and pass rate
      int totalCompletedModules = 0;
      int totalPassedStudents = 0;

      for (var course in facilitatorCourses) {
        String courseId = course['courseId'];
        QuerySnapshot moduleSnapshot = await FirebaseFirestore.instance
            .collection('courses')
            .doc(courseId)
            .collection('modules')
            .get();

        for (var module in moduleSnapshot.docs) {
          var moduleData = module.data() as Map<String, dynamic>;
          if (moduleData['status'] == 'completed') {
            totalCompletedModules++;
          }
        }
      }

      // Calculate pass rate (for now using a placeholder calculation)
      _studentPassRate = _totalStudents > 0
          ? (totalPassedStudents / _totalStudents) * 100
          : 0.0;
      _completedModules = totalCompletedModules;

      setState(() => _isLoadingStats = false);
    } catch (e) {
      print('Error fetching dashboard stats: $e');
      setState(() => _isLoadingStats = false);
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
          userType: 'facilitator',
        );
      },
    ).then((_) {
      _fetchUserProfileImage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Mycolors().offWhite,
      body: Row(
        children: [
          // Modern Sidebar with ScrollView
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
                // Logo Container
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
                // Navigation Items in ScrollView
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildNavItem(Icons.dashboard, 'Dashboard', 0),
                        _buildNavItem(Icons.search, 'Purchase Courses', 2),
                        _buildNavItem(Icons.school, 'Students and Modules', 1),
                        Visibility(
                          visible: false, // Hide the Students tab
                          child: _buildNavItem(Icons.people, 'Students', 3),
                        ),
                        _buildNavItem(Icons.message, 'Messages', 4),
                        const SizedBox(height: 20),
                        const Divider(),
                      ],
                    ),
                  ),
                ),
                // Profile Section
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
          // Main Content Area with ScrollView
          Expanded(
            child: Column(
              children: [
                // Modern Top Bar with Quick Stats
                _buildTopBar(),
                // Main Content with ScrollView
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

  Widget _buildTopBar() {
    // Define page names based on activeIndex
    String currentPageName = '';
    switch (activeIndex) {
      case 0:
        currentPageName = 'Dashboard';
        break;
      case 1:
        currentPageName = 'My Courses';
        break;
      case 2:
        currentPageName = 'Browse Courses';
        break;
      case 3:
        currentPageName = 'Students';
        break;
      case 4:
        currentPageName = 'Messages';
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
                        'Facilitator',
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
                    'Here\'s what\'s happening with your courses',
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Mycolors().green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Mycolors().green,
                        width: 1,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        showStudentPopup(context, _userId);
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_add,
                            color: Mycolors().green,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Add Student',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Mycolors().green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.notifications_outlined,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Only show quick stats on Dashboard page (index 0)
          if (activeIndex == 0) ...[
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickStat(
                    'Active Courses',
                    _activeCourses.toString(),
                    Icons.school_outlined,
                  ),
                  const SizedBox(width: 16),
                  _buildQuickStat(
                    'Total Students',
                    _totalStudents.toString(),
                    Icons.people_outline,
                    subValue: _monthlyStudents.toString(),
                    subIcon: Icons.arrow_upward,
                  ),
                  const SizedBox(width: 16),
                  _buildQuickStat(
                    'Completed Modules',
                    _completedModules.toString(),
                    Icons.check_circle_outline,
                  ),
                  const SizedBox(width: 16),
                  _buildQuickStat(
                    'Student Pass Rate',
                    '${_studentPassRate.toStringAsFixed(1)}%',
                    Icons.trending_up,
                  ),
                ],
              ),
            ),
          ],
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
                        'Profile',
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

  Widget _buildQuickStat(String title, String value, IconData icon,
      {String? subValue, IconData? subIcon}) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Mycolors().green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Mycolors().green,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              _isLoadingStats
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Mycolors().green),
                      ),
                    )
                  : Row(
                      children: [
                        Text(
                          value,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        if (subValue != null) ...[
                          const SizedBox(width: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (subIcon != null)
                                Icon(
                                  subIcon,
                                  color: Mycolors().green,
                                  size: 14,
                                ),
                              if (subIcon != null) const SizedBox(width: 2),
                              Text(
                                subValue,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
