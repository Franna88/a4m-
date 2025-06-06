import 'package:a4m/Constants/myColors.dart';
import 'package:flutter/material.dart';
import 'package:a4m/LandingPage/LandingPageMain.dart';
import 'package:a4m/CommonComponents/EditProfile/EditProfileDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_network/image_network.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:a4m/services/messaging_service.dart';

class LectureNavbar extends StatefulWidget {
  final Function(int) changePage;
  final Widget child;
  final int initialIndex;
  const LectureNavbar({
    super.key,
    required this.child,
    required this.changePage,
    this.initialIndex = 0,
  });

  @override
  State<LectureNavbar> createState() => _LectureNavbarState();
}

class _LectureNavbarState extends State<LectureNavbar> {
  late int activeIndex;
  String? _profileImageUrl;
  final String _userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  int _totalStudents = 0;
  int _activeCourses = 0;
  int _pendingReviews = 0;
  int _monthlyStudents = 0;
  final MessagingService _messagingService = MessagingService();

  @override
  void initState() {
    super.initState();
    activeIndex = widget.initialIndex;
    _fetchUserProfileImage();
    _fetchMetrics();
  }

  @override
  void didUpdateWidget(LectureNavbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      activeIndex = widget.initialIndex;
    }
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

  Future<void> _fetchMetrics() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final coursesSnapshot =
          await FirebaseFirestore.instance.collection('courses').get();
      Set<String> uniqueStudentIds = {};
      Set<String> uniqueMonthlyStudentIds = {};
      int pendingReviews = 0;
      int activeCourses = 0;

      for (var courseDoc in coursesSnapshot.docs) {
        final courseData = courseDoc.data();
        final assignedLecturers =
            courseData['assignedLecturers'] as List<dynamic>?;

        if (assignedLecturers != null) {
          bool isAssigned = assignedLecturers.any((lecturer) =>
              lecturer is Map<String, dynamic> && lecturer['id'] == _userId);

          if (isAssigned) {
            activeCourses++;

            // Count unique students
            final students = courseData['students'] as List<dynamic>?;
            if (students != null) {
              for (var student in students) {
                if (student is Map<String, dynamic> &&
                    student['studentId'] != null) {
                  uniqueStudentIds.add(student['studentId'].toString());

                  // Count monthly new students
                  final registered = student['registered'];
                  if (registered != null) {
                    final registeredDate = registered is Timestamp
                        ? registered.toDate()
                        : registered is DateTime
                            ? registered
                            : null;

                    if (registeredDate != null &&
                        registeredDate.isAfter(startOfMonth)) {
                      uniqueMonthlyStudentIds
                          .add(student['studentId'].toString());
                    }
                  }
                }
              }
            }

            // Count pending reviews
            final moduleSnapshot = await FirebaseFirestore.instance
                .collection('courses')
                .doc(courseDoc.id)
                .collection('modules')
                .get();

            for (var moduleDoc in moduleSnapshot.docs) {
              final submissionsSnapshot =
                  await moduleDoc.reference.collection('submissions').get();

              for (var submission in submissionsSnapshot.docs) {
                final submissionData = submission.data();
                final assessments =
                    submissionData['submittedAssessments'] as List<dynamic>?;

                if (assessments != null) {
                  pendingReviews += assessments
                      .where((assessment) =>
                          assessment is Map<String, dynamic> &&
                          (!assessment.containsKey('mark') ||
                              assessment['mark'] == null))
                      .length;
                }
              }
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _totalStudents = uniqueStudentIds.length;
          _activeCourses = activeCourses;
          _pendingReviews = pendingReviews;
          _monthlyStudents = uniqueMonthlyStudentIds.length;
        });
      }
    } catch (e) {
      print('Error fetching metrics: $e');
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
          userType: 'lecturer',
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

  Widget _buildQuickStat(String title, String value, IconData icon,
      {String? subtitle, IconData? subtitleIcon, Color? subtitleColor}) {
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
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (subtitleIcon != null) ...[
                      Icon(
                        subtitleIcon,
                        size: 12,
                        color: subtitleColor ?? Mycolors().green,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: subtitleColor ?? Mycolors().green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
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
        currentPageName = 'Courses';
        break;
      case 2:
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
                        'Lecturer',
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
                  // Remove the subtitle text for lecturers only
                  // Text(
                  //   'Here\'s what\'s happening with your courses',
                  //   style: GoogleFonts.poppins(
                  //     fontSize: 14,
                  //     color: Colors.grey[600],
                  //   ),
                  // ),
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
                    child: StreamBuilder<int>(
                      stream: _messagingService.getUnreadCount(_userId),
                      builder: (context, snapshot) {
                        final unreadCount = snapshot.data ?? 0;
                        return Tooltip(
                          message: 'Notifications',
                          child: Stack(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.notifications_outlined),
                                onPressed: () {
                                  // Handle notifications
                                },
                              ),
                              if (unreadCount > 0)
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
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
                    subtitle:
                        _monthlyStudents > 0 ? '${_monthlyStudents} new' : null,
                    subtitleIcon:
                        _monthlyStudents > 0 ? Icons.arrow_upward : null,
                    subtitleColor: Mycolors().green,
                  ),
                  const SizedBox(width: 16),
                  _buildQuickStat(
                    'Pending Reviews',
                    _pendingReviews.toString(),
                    Icons.assignment_outlined,
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
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipOval(
                child: _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                    ? ImageNetwork(
                        image: _profileImageUrl!,
                        height: 40,
                        width: 40,
                        duration: 1500,
                        curve: Curves.easeIn,
                        onPointer: true,
                        debugPrint: false,
                        fitAndroidIos: BoxFit.cover,
                        fitWeb: BoxFitWeb.cover,
                        onError: Icon(Icons.person, color: Colors.grey[400]),
                        onLoading: CircularProgressIndicator(
                          color: Colors.grey[300],
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(Icons.person, color: Colors.grey[400]),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lecturer Profile',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  Text(
                    'Manage your account',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _showEditProfileDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.edit,
                    size: 18,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Edit Profile',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
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
                        _buildNavItem(Icons.school, 'Courses', 1),
                        // _buildNavItem(Icons.people, 'Students', 2),
                        // _buildNavItem(Icons.slideshow, 'Presentation', 3),
                        _buildNavItem(Icons.message, 'Messages', 4),
                        const SizedBox(height: 20),
                        const Divider(),
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
