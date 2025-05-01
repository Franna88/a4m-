import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_network/image_network.dart';
import '../../Themes/Constants/myColors.dart';
import '../../CommonComponents/inputFields/myDropDownMenu.dart';
import '../../CommonComponents/inputFields/mySearchBar.dart';
import '../../CommonComponents/displayCardIcons.dart';
import '../../myutility.dart';
import '../studentMain.dart';
import '../BrowseCourse/CoursePreviewPdf.dart';
import 'PaymentPage.dart';
import 'dart:html' as html;

class StudentCourseBrowse extends StatefulWidget {
  const StudentCourseBrowse({super.key});

  @override
  State<StudentCourseBrowse> createState() => _StudentCourseBrowseState();
}

class _StudentCourseBrowseState extends State<StudentCourseBrowse> {
  final ScrollController _scrollController = ScrollController();
  final categoryController = TextEditingController();
  final courseSearchController = TextEditingController();
  final String studentId = FirebaseAuth.instance.currentUser?.uid ?? '';

  // Updated filter state
  String selectedCategory = 'All';
  String selectedSort = 'Newest';
  RangeValues priceRange = RangeValues(0, 5000);
  String searchQuery = '';
  bool showingFilters = false;

  List<Map<String, dynamic>> courses = [];
  String? currentPreviewPdfUrl;
  String? currentPreviewCourseName;

  // Add sort options
  final List<String> sortOptions = [
    'Newest',
    'Price: Low to High',
    'Price: High to Low',
    'Most Popular',
    'Most Rated'
  ];

  // Add category options
  final List<String> categoryOptions = [
    'All',
    'Programming',
    'Design',
    'Business',
    'Marketing',
    'Finance',
    'Personal Development'
  ];

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    categoryController.dispose();
    courseSearchController.dispose();
    super.dispose();
  }

  Future<void> _fetchCourses() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('courses')
          .where('status', isEqualTo: 'approved')
          .get();

      List<Map<String, dynamic>> approvedCourses = [];

      for (var doc in snapshot.docs) {
        final courseData = doc.data() as Map<String, dynamic>;

        // Only include courses with assigned lecturers
        if (courseData['assignedLecturers'] != null &&
            (courseData['assignedLecturers'] as List).isNotEmpty) {
          // Fetch modules for the course
          QuerySnapshot moduleSnapshot = await FirebaseFirestore.instance
              .collection('courses')
              .doc(doc.id)
              .collection('modules')
              .get();

          // Count modules and assessments
          int moduleCount = moduleSnapshot.docs.length;
          int assessmentCount = 0;

          for (var module in moduleSnapshot.docs) {
            final moduleData = module.data() as Map<String, dynamic>;
            if (moduleData['assessmentsPdfUrl'] != null &&
                moduleData['assessmentsPdfUrl'].isNotEmpty) {
              assessmentCount++;
            }
          }

          // Count students
          int studentCount =
              (courseData['students'] as List<dynamic>? ?? []).length;

          // Add the course with its counts
          approvedCourses.add({
            ...courseData,
            'id': doc.id,
            'moduleCount': moduleCount,
            'assessmentCount': assessmentCount,
            'studentCount': studentCount,
          });
        }
      }

      setState(() {
        courses = approvedCourses;
      });
    } catch (e) {
      print('Error fetching courses: $e');
    }
  }

  List<Map<String, dynamic>> getFilteredCourses() {
    return courses.where((course) {
      final title = course['courseName']?.toString().toLowerCase() ?? '';
      final category = course['category']?.toString() ?? '';
      final price = _parsePrice(course['coursePrice']);

      bool matchesCategory =
          selectedCategory == 'All' || category == selectedCategory;
      bool matchesSearch =
          searchQuery.isEmpty || title.contains(searchQuery.toLowerCase());
      bool matchesPrice = price >= priceRange.start && price <= priceRange.end;

      return matchesCategory && matchesSearch && matchesPrice;
    }).toList()
      ..sort((a, b) {
        switch (selectedSort) {
          case 'Price: Low to High':
            return _parsePrice(a['coursePrice'])
                .compareTo(_parsePrice(b['coursePrice']));
          case 'Price: High to Low':
            return _parsePrice(b['coursePrice'])
                .compareTo(_parsePrice(a['coursePrice']));
          case 'Most Popular':
            return (b['studentCount'] ?? 0).compareTo(a['studentCount'] ?? 0);
          case 'Most Rated':
            return ((b['ratings']?.length ?? 0))
                .compareTo((a['ratings']?.length ?? 0));
          default: // 'Newest'
            return (b['createdAt'] ?? Timestamp.now())
                .compareTo(a['createdAt'] ?? Timestamp.now());
        }
      });
  }

  double _parsePrice(dynamic price) {
    if (price == null) return 0.0;
    if (price is num) return price.toDouble();
    if (price is String) {
      return double.tryParse(price) ?? 0.0;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final filteredCourses = getFilteredCourses();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (currentPreviewPdfUrl != null)
                      _buildPdfPreview()
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSearchSection(filteredCourses.length),
                          const SizedBox(height: 24),
                          _buildCourseGrid(filteredCourses),
                          if (filteredCourses.isNotEmpty)
                            _buildDashboardButton(),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
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
        children: [
          Text(
            'Browse Courses',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Discover and enroll in new courses to expand your knowledge',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection(int courseCount) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Mycolors().green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Available Courses: $courseCount',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Mycolors().green,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    showingFilters = !showingFilters;
                  });
                },
                icon: Icon(
                  showingFilters ? Icons.filter_list_off : Icons.filter_list,
                  color: Mycolors().green,
                ),
                label: Text(
                  showingFilters ? 'Hide Filters' : 'Show Filters',
                  style: GoogleFonts.poppins(
                    color: Mycolors().green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (showingFilters) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Category',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: categoryOptions.length,
                          itemBuilder: (context, index) {
                            final category = categoryOptions[index];
                            final isSelected = category == selectedCategory;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                selected: isSelected,
                                label: Text(category),
                                onSelected: (selected) {
                                  setState(() {
                                    selectedCategory = category;
                                  });
                                },
                                selectedColor: Mycolors().green,
                                labelStyle: GoogleFonts.poppins(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price Range',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      RangeSlider(
                        values: priceRange,
                        min: 0,
                        max: 5000,
                        divisions: 50,
                        activeColor: Mycolors().green,
                        inactiveColor: Mycolors().green.withOpacity(0.2),
                        labels: RangeLabels(
                          'R${priceRange.start.round()}',
                          'R${priceRange.end.round()}',
                        ),
                        onChanged: (RangeValues values) {
                          setState(() {
                            priceRange = values;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sort By',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: sortOptions.length,
                          itemBuilder: (context, index) {
                            final sort = sortOptions[index];
                            final isSelected = sort == selectedSort;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                selected: isSelected,
                                label: Text(sort),
                                onSelected: (selected) {
                                  setState(() {
                                    selectedSort = sort;
                                  });
                                },
                                selectedColor: Mycolors().green,
                                labelStyle: GoogleFonts.poppins(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          MySearchBar(
            textController: courseSearchController,
            hintText: 'Search courses by name, description, or skills...',
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCourseGrid(List<Map<String, dynamic>> filteredCourses) {
    if (courses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: CircularProgressIndicator(
            color: Mycolors().green,
          ),
        ),
      );
    }

    if (filteredCourses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'No courses found matching your criteria',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200
            ? 3
            : constraints.maxWidth > 800
                ? 2
                : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 24,
            crossAxisSpacing: 24,
            childAspectRatio: 0.8,
          ),
          itemCount: filteredCourses.length,
          itemBuilder: (context, index) =>
              _buildCourseCard(filteredCourses[index]),
        );
      },
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showAddCourseDialog(course['id'], course),
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ImageNetwork(
                        image: course['courseImageUrl'] ?? 'images/course1.png',
                        height: 220,
                        width: 400,
                        fitAndroidIos: BoxFit.cover,
                        fitWeb: BoxFitWeb.cover,
                        onLoading: Container(
                          color: Mycolors().green.withOpacity(0.1),
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Mycolors().green),
                            ),
                          ),
                        ),
                        onError: Container(
                          color: Mycolors().green.withOpacity(0.1),
                          child: Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 48,
                              color: Mycolors().green,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Mycolors().green.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        left: 12,
                        right: 12,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Mycolors().darkTeal,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'R ${(course['coursePrice'] is String ? double.tryParse(course['coursePrice']) ?? 0 : course['coursePrice'] ?? 0).toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            if (course['previewPdfUrl'] != null &&
                                course['previewPdfUrl'].isNotEmpty)
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    currentPreviewPdfUrl =
                                        course['previewPdfUrl'];
                                    currentPreviewCourseName =
                                        course['courseName'];
                                  });
                                },
                                icon: const Icon(Icons.visibility,
                                    color: Colors.white, size: 16),
                                label: Text(
                                  'Preview',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      Mycolors().green.withOpacity(0.3),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course['courseName'] ?? 'Untitled Course',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      course['courseDescription'] ?? 'No description available',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          Icons.person_outline,
                          course['studentCount']?.toString() ?? '0',
                          'Students',
                        ),
                        _buildStatItem(
                          Icons.assignment_outlined,
                          course['assessmentCount']?.toString() ?? '0',
                          'Assessments',
                        ),
                        _buildStatItem(
                          Icons.library_books_outlined,
                          course['moduleCount']?.toString() ?? '0',
                          'Modules',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String count, String label) {
    return Column(
      children: [
        Icon(icon, color: Mycolors().navyBlue, size: 20),
        const SizedBox(height: 4),
        Text(
          count,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildPdfPreview() {
    return Container(
      height: MediaQuery.of(context).size.height - 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: CoursePreviewPdf(
        pdfUrl: currentPreviewPdfUrl!,
        courseName: currentPreviewCourseName ?? '',
        onBack: () {
          setState(() {
            currentPreviewPdfUrl = null;
            currentPreviewCourseName = null;
          });
        },
      ),
    );
  }

  Widget _buildDashboardButton() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StudentMain(studentId: studentId),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Mycolors().green,
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Continue to Dashboard',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _showAddCourseDialog(String courseId, Map<String, dynamic> courseData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
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
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: ImageNetwork(
                        image: courseData['courseImageUrl'] ??
                            'images/course1.png',
                        height: 200,
                        width: 400,
                        fitAndroidIos: BoxFit.cover,
                        fitWeb: BoxFitWeb.cover,
                        onLoading: Container(
                          color: Mycolors().green.withOpacity(0.1),
                          height: 200,
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Mycolors().green),
                            ),
                          ),
                        ),
                        onError: Container(
                          color: Mycolors().green.withOpacity(0.1),
                          height: 200,
                          child: Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 48,
                              color: Mycolors().green,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Mycolors().green.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Mycolors().darkTeal,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'R ${(courseData['coursePrice'] is String ? double.tryParse(courseData['coursePrice']) ?? 0 : courseData['coursePrice'] ?? 0).toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  courseData['courseName'] ?? 'Untitled Course',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  courseData['courseDescription'] ?? 'No description available',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      Icons.person_outline,
                      courseData['studentCount']?.toString() ?? '0',
                      'Students',
                    ),
                    _buildStatItem(
                      Icons.assignment_outlined,
                      courseData['assessmentCount']?.toString() ?? '0',
                      'Assessments',
                    ),
                    _buildStatItem(
                      Icons.library_books_outlined,
                      courseData['moduleCount']?.toString() ?? '0',
                      'Modules',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PaymentPage(
                              courseData: courseData,
                              onPaymentComplete: () {
                                _addCourseToStudent(courseId, courseData);
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Successfully purchased ${courseData['courseName']}',
                                      style: GoogleFonts.poppins(),
                                    ),
                                    backgroundColor: Mycolors().darkTeal,
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Mycolors().darkTeal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Continue to Payment',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _addCourseToStudent(
      String courseId, Map<String, dynamic> courseData) async {
    if (studentId.isEmpty) {
      print('Invalid student ID!');
      return;
    }

    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference studentRef =
          firestore.collection('Users').doc(studentId);
      DocumentReference courseRef =
          firestore.collection('courses').doc(courseId);

      DocumentSnapshot studentSnapshot = await studentRef.get();
      if (!studentSnapshot.exists) {
        print('Student record not found!');
        return;
      }

      Map<String, dynamic> studentData =
          studentSnapshot.data() as Map<String, dynamic>;

      await studentRef.update({
        'courses': FieldValue.arrayUnion([courseId]),
      });

      await courseRef.update({
        'students': FieldValue.arrayUnion([
          {
            'studentId': studentId,
            'name': studentData['name'] ?? 'Unknown',
            'registered': true,
          }
        ]),
      });

      print('Course successfully added for student!');
    } catch (e) {
      print('Error adding course: $e');
    }
  }
}
