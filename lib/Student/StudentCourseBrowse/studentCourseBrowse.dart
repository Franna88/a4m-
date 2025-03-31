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
  String selectedCategory = 'All';
  String searchQuery = '';
  List<Map<String, dynamic>> courses = [];
  String? currentPreviewPdfUrl;
  String? currentPreviewCourseName;

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

      bool matchesCategory =
          selectedCategory == 'All' || category == selectedCategory;
      bool matchesSearch =
          searchQuery.isEmpty || title.contains(searchQuery.toLowerCase());

      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredCourses = getFilteredCourses();

    return Scaffold(
      backgroundColor: Mycolors().offWhite,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                const SizedBox(height: 100),
                Container(
                  width: MyUtility(context).width * 0.85,
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (currentPreviewPdfUrl != null)
                        Container(
                          width: double.infinity,
                          height: MyUtility(context).height - 200,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 0,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
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
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Browse Courses',
                                  style: GoogleFonts.poppins(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w600,
                                    color: Mycolors().navyBlue,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Mycolors().green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Available Courses: ${filteredCourses.length}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Mycolors().green,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                MyDropDownMenu(
                                  description: 'Category',
                                  customSize: 300,
                                  items: [
                                    'All',
                                    'Programming',
                                    'Design',
                                    'Business',
                                    'Marketing'
                                  ],
                                  textfieldController: categoryController,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedCategory = value ?? 'All';
                                    });
                                  },
                                ),
                                const SizedBox(width: 40),
                                SizedBox(
                                  width: 350,
                                  child: MySearchBar(
                                    textController: courseSearchController,
                                    hintText: 'Search Course',
                                    onChanged: (value) {
                                      setState(() {
                                        searchQuery = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),
                            if (courses.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: CircularProgressIndicator(
                                    color: Mycolors().green,
                                  ),
                                ),
                              )
                            else if (filteredCourses.isEmpty)
                              Center(
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
                              )
                            else
                              Wrap(
                                spacing: 30,
                                runSpacing: 30,
                                children: filteredCourses.map((course) {
                                  return Material(
                                    borderRadius: BorderRadius.circular(15),
                                    elevation: 2,
                                    child: InkWell(
                                      onTap: () => _showAddCourseDialog(
                                          course['id'], course),
                                      borderRadius: BorderRadius.circular(15),
                                      hoverColor:
                                          Mycolors().green.withOpacity(0.05),
                                      child: Container(
                                        height: 340,
                                        width: 320,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          border: Border.all(
                                            color: Colors.grey.withOpacity(0.2),
                                            width: 1,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Stack(
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(15),
                                                    topRight:
                                                        Radius.circular(15),
                                                  ),
                                                  child: ImageNetwork(
                                                    image: course[
                                                            'courseImageUrl'] ??
                                                        'images/course1.png',
                                                    height: 180,
                                                    width: 320,
                                                    fitAndroidIos: BoxFit.cover,
                                                    fitWeb: BoxFitWeb.cover,
                                                    onLoading: const Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    ),
                                                  ),
                                                ),
                                                Positioned.fill(
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(15),
                                                      topRight:
                                                          Radius.circular(15),
                                                    ),
                                                    child: Container(
                                                      decoration:
                                                          const BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          colors: [
                                                            Color(0x00ECF5DE),
                                                            Color(0x8F8AB747),
                                                          ],
                                                          begin: Alignment
                                                              .topCenter,
                                                          end: Alignment
                                                              .bottomCenter,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  bottom: 10,
                                                  left: 10,
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          vertical: 5,
                                                          horizontal: 10,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          color: Mycolors()
                                                              .darkTeal,
                                                        ),
                                                        child: Text(
                                                          'R ${course['coursePrice']?.toString() ?? "0"}',
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ),
                                                      if (course['previewPdfUrl'] !=
                                                              null &&
                                                          course['previewPdfUrl']
                                                              .isNotEmpty)
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 8.0),
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            child:
                                                                TextButton.icon(
                                                              onPressed: () {
                                                                setState(() {
                                                                  currentPreviewPdfUrl =
                                                                      course[
                                                                          'previewPdfUrl'];
                                                                  currentPreviewCourseName =
                                                                      course[
                                                                          'courseName'];
                                                                });
                                                              },
                                                              icon: const Icon(
                                                                  Icons
                                                                      .visibility,
                                                                  size: 16,
                                                                  color: Colors
                                                                      .black87),
                                                              label: Text(
                                                                'Preview',
                                                                style: GoogleFonts
                                                                    .montserrat(
                                                                  color: Colors
                                                                      .black87,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                              style: TextButton
                                                                  .styleFrom(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 2,
                                                                ),
                                                                minimumSize:
                                                                    Size.zero,
                                                                tapTargetSize:
                                                                    MaterialTapTargetSize
                                                                        .shrinkWrap,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              child: Text(
                                                course['courseName'] ??
                                                    'Untitled Course',
                                                style: GoogleFonts.montserrat(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Mycolors().navyBlue,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 12,
                                                  right: 12,
                                                  bottom: 12),
                                              child: Text(
                                                course['courseDescription'] ??
                                                    'No description available',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 13,
                                                  color: Colors.grey[700],
                                                  height: 1.5,
                                                ),
                                              ),
                                            ),
                                            const Spacer(),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12),
                                              child: Container(
                                                width: double.infinity,
                                                height: 1,
                                                color: Colors.grey
                                                    .withOpacity(0.2),
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            12),
                                                    child: DisplayCardIcons(
                                                      icon:
                                                          Icons.person_outline,
                                                      count:
                                                          course['studentCount']
                                                                  ?.toString() ??
                                                              '0',
                                                      tooltipText:
                                                          'Students Enrolled',
                                                      iconColor:
                                                          Mycolors().navyBlue,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  height: 24,
                                                  width: 1,
                                                  color: Colors.grey
                                                      .withOpacity(0.2),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            12),
                                                    child: DisplayCardIcons(
                                                      icon: Icons
                                                          .assignment_outlined,
                                                      count:
                                                          course['assessmentCount']
                                                                  ?.toString() ??
                                                              '0',
                                                      tooltipText:
                                                          'Course Assessments',
                                                      iconColor:
                                                          Mycolors().navyBlue,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  height: 24,
                                                  width: 1,
                                                  color: Colors.grey
                                                      .withOpacity(0.2),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            12),
                                                    child: DisplayCardIcons(
                                                      icon: Icons
                                                          .library_books_outlined,
                                                      count: course[
                                                                  'moduleCount']
                                                              ?.toString() ??
                                                          '0',
                                                      tooltipText:
                                                          'Course Modules',
                                                      iconColor:
                                                          Mycolors().navyBlue,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            if (currentPreviewPdfUrl == null)
                              Column(
                                children: [
                                  const SizedBox(height: 50),
                                  Center(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            spreadRadius: 0,
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => StudentMain(
                                                  studentId: studentId),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Mycolors().green,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 50,
                                            vertical: 20,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: Text(
                                          'Continue to Dashboard',
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 50),
                                ],
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCourseDialog(String courseId, Map<String, dynamic> courseData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
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
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                      child: ImageNetwork(
                        image: courseData['courseImageUrl'] ??
                            'images/course1.png',
                        height: 180,
                        width: 400,
                        fitAndroidIos: BoxFit.cover,
                        fitWeb: BoxFitWeb.cover,
                      ),
                    ),
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0x00ECF5DE),
                                Color(0x8F8AB747),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Mycolors().darkTeal,
                        ),
                        child: Text(
                          'R ${courseData['coursePrice']?.toString() ?? "0"}',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        courseData['courseName'] ?? 'Untitled Course',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        courseData['courseDescription'] ??
                            'No description available',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: 352,
                        height: 2,
                        color: const Color.fromARGB(255, 189, 189, 189),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          DisplayCardIcons(
                            icon: Icons.person_outline,
                            count:
                                courseData['studentCount']?.toString() ?? '0',
                            tooltipText: 'Students',
                            iconColor: Mycolors().navyBlue,
                          ),
                          DisplayCardIcons(
                            icon: Icons.assignment_outlined,
                            count: courseData['assessmentCount']?.toString() ??
                                '0',
                            tooltipText: 'Assessments',
                            iconColor: Mycolors().navyBlue,
                          ),
                          DisplayCardIcons(
                            icon: Icons.library_books_outlined,
                            count: courseData['moduleCount']?.toString() ?? '0',
                            tooltipText: 'Modules',
                            iconColor: Mycolors().navyBlue,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.montserrat(
                                color: Colors.grey[600],
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
                                      Navigator.of(context)
                                          .pop(); // Close payment page
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Successfully purchased ${courseData['courseName']}',
                                            style: GoogleFonts.montserrat(),
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
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Continue to Payment',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
    if (studentId.isNotEmpty) {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference studentRef =
          firestore.collection('Users').doc(studentId);
      DocumentReference courseRef =
          firestore.collection('courses').doc(courseId);

      try {
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
    } else {
      print('Invalid student ID!');
    }
  }
}
