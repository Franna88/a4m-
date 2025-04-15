import 'package:a4m/Facilitator/Pages/MyCourses/ui/facilitatorCourseContainers.dart';
import 'package:a4m/LandingPage/CourseListPage/ui/categoryNameStack.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:a4m/Constants/myColors.dart';

import '../../../CommonComponents/inputFields/myDropDownMenu.dart';
import '../../../CommonComponents/inputFields/mySearchBar.dart';

class FacilitatorBrowseCourses extends StatefulWidget {
  final String facilitatorId;
  const FacilitatorBrowseCourses({super.key, required this.facilitatorId});

  @override
  State<FacilitatorBrowseCourses> createState() =>
      _FacilitatorBrowseCoursesState();
}

class _FacilitatorBrowseCoursesState extends State<FacilitatorBrowseCourses> {
  final List<Map<String, String>> dummyCourses = List.generate(
    10,
    (index) => {
      'courseName': 'Course ${index + 1}',
      'courseDescription': 'This is a description for Course ${index + 1}',
      'totalStudents': '${(index + 1) * 10}',
      'totalAssesments': '${(index + 1) * 2}',
      'totalModules': '${(index + 1)}',
      'courseImage': 'images/course${(index % 3) + 1}.png',
      'coursePrice': '\$${(index + 1) * 50}',
    },
  );
  Future<void> _addCourseToFacilitator(
      Map<String, dynamic> course, int selectedLicenses) async {
    String facilitatorId = widget.facilitatorId;

    if (facilitatorId.isNotEmpty) {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference facilitatorRef =
          firestore.collection('Users').doc(facilitatorId);

      try {
        // Fetch facilitator data
        DocumentSnapshot facilitatorSnapshot = await facilitatorRef.get();
        if (!facilitatorSnapshot.exists) {
          print('Facilitator record not found!');
          return;
        }

        // Calculate total price
        double coursePrice = double.parse(course['coursePrice'].toString());
        double totalPrice = coursePrice * selectedLicenses;

        // Create license records
        List<Map<String, dynamic>> licenses = List.generate(
          selectedLicenses,
          (index) => {
            'courseId': course['courseId'],
            'facilitatorId': facilitatorId,
            'status': 'available', // available, assigned, expired
            'purchaseDate': FieldValue.serverTimestamp(),
            'assignedTo': null,
            'assignmentDate': null,
          },
        );

        // Add licenses to the courseLicenses collection
        for (var license in licenses) {
          await firestore.collection('courseLicenses').add(license);
        }

        // Get current facilitator courses
        List<dynamic> currentCourses =
            facilitatorSnapshot['facilitatorCourses'] ?? [];

        // Check if course already exists
        int existingIndex = currentCourses
            .indexWhere((c) => c['courseId'] == course['courseId']);

        if (existingIndex >= 0) {
          // Update existing course with null safety
          Map<String, dynamic> existingCourse = currentCourses[existingIndex];
          int currentTotalLicenses =
              (existingCourse['totalLicenses'] ?? 0) as int;
          int currentAvailableLicenses =
              (existingCourse['availableLicenses'] ?? 0) as int;

          currentCourses[existingIndex] = {
            ...existingCourse,
            'totalLicenses': currentTotalLicenses + selectedLicenses,
            'availableLicenses': currentAvailableLicenses + selectedLicenses,
          };
        } else {
          // Add new course with current timestamp
          currentCourses.add({
            'courseId': course['courseId'],
            'totalLicenses': selectedLicenses,
            'availableLicenses': selectedLicenses,
            'purchaseDate': DateTime.now().toIso8601String(),
          });
        }

        // Update facilitator document with new courses array
        await facilitatorRef.update({
          'facilitatorCourses': currentCourses,
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Successfully purchased $selectedLicenses licenses for ${course['courseName']}'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        print('Error adding course to facilitator: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error purchasing licenses: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      print('Invalid facilitator ID!');
    }
  }

  // Fetch approved courses from Firebase
  Future<List<Map<String, dynamic>>> fetchApprovedCourses() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('courses')
        .where('status', isEqualTo: 'approved') // Filter by status
        .get();

    List<Map<String, dynamic>> courses = [];
    for (var doc in snapshot.docs) {
      final courseData = doc.data() as Map<String, dynamic>;

      // Check if the course has assigned lecturers
      if (courseData['assignedLecturers'] == null ||
          (courseData['assignedLecturers'] as List).isEmpty) {
        continue; // Skip this course if no lecturers are assigned
      }

      // Fetch modules for the course
      QuerySnapshot moduleSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(doc.id)
          .collection('modules')
          .get();

      // Count the number of modules
      int moduleCount = moduleSnapshot.docs.length;

      // Count the total number of assessments based on `assessmentsPdfUrl`
      int assessmentCount = 0;
      for (var module in moduleSnapshot.docs) {
        final moduleData = module.data() as Map<String, dynamic>;
        if (moduleData['assessmentsPdfUrl'] != null &&
            moduleData['assessmentsPdfUrl'].isNotEmpty) {
          assessmentCount++;
        }
      }

      // Count the number of students
      int studentCount =
          (courseData['students'] as List<dynamic>? ?? []).length;

      // Add all dynamic values to the course data
      courses.add({
        ...courseData,
        'courseId': doc.id,
        'moduleCount': moduleCount,
        'assessmentCount': assessmentCount,
        'studentCount': studentCount,
      });
    }
    return courses;
  }

  void _showAddCourseDialog(Map<String, dynamic> course) {
    int tempLicenses = 0;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Container(
                width: 450,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Purchase Course Licenses',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Mycolors().green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Mycolors().green,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.school_outlined,
                            color: Mycolors().green,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            course['courseName'] ?? 'Unknown Course',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Mycolors().green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.attach_money,
                            color: Colors.grey[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Price per license: R ${course['coursePrice']}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Number of Licenses',
                        labelStyle: GoogleFonts.poppins(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey[300]!,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey[300]!,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Mycolors().green,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          tempLicenses = int.tryParse(value) ?? 0;
                        });
                      },
                    ),
                    if (tempLicenses > 0) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Mycolors().green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Mycolors().green,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calculate_outlined,
                              color: Mycolors().green,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Total Price: R ${(tempLicenses * double.parse(course['coursePrice'].toString())).toStringAsFixed(2)}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Mycolors().green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (tempLicenses > 0) {
                                Navigator.pop(context);
                                await _addCourseToFacilitator(
                                    course, tempLicenses);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Please enter a valid number of licenses'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Mycolors().green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            child: Text(
                              'Purchase',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final category = TextEditingController();
    final courseSearch = TextEditingController();
    final screenWidth = MyUtility(context).width - 280;

    // Decrease spacing by calculating tighter crossAxisCount
    int crossAxisCount =
        (screenWidth ~/ 300).clamp(1, 6); // Adjusted for tight layout

    return SizedBox(
      height: MyUtility(context).height - 50,
      width: screenWidth,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MyUtility(context).height * 0.78,
          ),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white, border: Border.all(width: 0.8)),
            width: MyUtility(context).width,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CategoryNameStack(text: 'Browse Courses'),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      MyDropDownMenu(
                          description: 'Category',
                          customSize: 300,
                          items: ['test1', 'test2'],
                          textfieldController: category),
                      const SizedBox(
                        width: 40,
                      ),
                      SizedBox(
                        width: 350,
                        child: MySearchBar(
                            textController: courseSearch,
                            hintText: 'Search Course'),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: fetchApprovedCourses(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(
                              child: Text('No approved courses available.'));
                        }

                        final courses = snapshot.data!;

                        return SingleChildScrollView(
                          child: LayoutGrid(
                            columnSizes: List.generate(
                              crossAxisCount,
                              (_) =>
                                  FlexibleTrackSize(1), // Flexible column sizes
                            ),
                            rowSizes: List.generate(
                              (courses.length / crossAxisCount).ceil(),
                              (_) => auto, // Auto height for rows
                            ),
                            rowGap: 20, // Space between rows
                            columnGap: 20, // Space between columns
                            children: [
                              for (var course in courses)
                                SizedBox(
                                  width: 320, // Fixed width
                                  height: 340, // Fixed height
                                  child: GestureDetector(
                                    onTap: () => _showAddCourseDialog(
                                        course), // Show dialog before adding course
                                    child: SizedBox(
                                      width: 320,
                                      height: 340,
                                      child: FacilitatorCourseContainers(
                                        courseImage: course['courseImageUrl'] ??
                                            'images/placeholder.png',
                                        courseName:
                                            course['courseName'] ?? 'No Name',
                                        courseDescription:
                                            course['courseDescription'] ??
                                                'No Description',
                                        coursePrice:
                                            'R ${course['coursePrice']?.toString() ?? '0'}',
                                        totalModules:
                                            course['moduleCount']?.toString() ??
                                                '0',
                                        totalAssesments:
                                            course['assessmentCount']
                                                    ?.toString() ??
                                                '0',
                                        totalStudents: course['studentCount']
                                                ?.toString() ??
                                            '0',
                                        isAssignStudent: false,
                                        facilitatorId: widget
                                            .facilitatorId, // Pass facilitatorId
                                        courseId:
                                            course['courseId'], // Pass courseId
                                      ),
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
            ),
          ),
        ),
      ),
    );
  }
}
