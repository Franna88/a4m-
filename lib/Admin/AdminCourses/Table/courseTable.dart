import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:a4m/TableWidgets/tableStructure.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CourseTable extends StatefulWidget {
  const CourseTable({super.key});

  @override
  State<CourseTable> createState() => _CourseTableState();
}

class _CourseTableState extends State<CourseTable> {
  String? selectedLecturer; // Holds the currently selected lecturer

  // Fetch approved courses from Firestore
  Future<List<Map<String, dynamic>>> fetchApprovedCourses() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .where('status', isEqualTo: 'approved')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'courseName': data['courseName'] ?? 'No Name',
          'dateAdded':
              data['createdAt']?.toDate().toString().split(' ')[0] ?? 'N/A',
          'currentPrice': 'R ${data['coursePrice'] ?? '0.00'}',
          'totalSales': data['totalSales']?.toString() ?? '0',
        };
      }).toList();
    } catch (e) {
      print('Error fetching courses: $e');
      return [];
    }
  }

  // Fetch approved lecturers
  Future<List<Map<String, String>>> fetchApprovedLecturers() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Users') // Query the Users collection
          .where('userType', isEqualTo: 'lecturer')
          .where('status', isEqualTo: 'approved')
          .get();

      // Safely convert to Map<String, String>
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id, // Document ID
          'name': data['name']?.toString() ?? 'Unknown',
          'email': data['email']?.toString() ?? 'No Email',
        };
      }).toList();
    } catch (e) {
      print('Error fetching approved lecturers: $e');
      return [];
    }
  }

  // Assign a lecturer to a course
  Future<void> assignLecturerToCourse(
      String courseId, String lecturerId, String lecturerName) async {
    try {
      final courseRef =
          FirebaseFirestore.instance.collection('courses').doc(courseId);

      // Add lecturer details to the assignedLecturers array
      await courseRef.update({
        'assignedLecturers': FieldValue.arrayUnion([
          {'id': lecturerId, 'name': lecturerName}
        ]),
      });

      print('Lecturer assigned to course successfully.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lecturer successfully assigned to the course')),
      );
    } catch (e) {
      print('Error assigning lecturer: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to assign lecturer')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchApprovedCourses(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No approved courses found.'));
        }

        final courses = snapshot.data!;

        return Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            // Header Row
            TableRow(
              decoration: BoxDecoration(
                color: Mycolors().green,
                border: Border(bottom: BorderSide(color: Colors.black)),
              ),
              children: [
                _buildHeaderCell('Course Name'),
                _buildHeaderCell('Date Added'),
                _buildHeaderCell('Current Price'),
                _buildHeaderCell('Total Sales'),
                _buildHeaderCell('Add Lecturer'),
              ],
            ),
            // Data Rows
            ...List.generate(courses.length, (index) {
              final course = courses[index];
              return TableRow(
                decoration: BoxDecoration(
                  color: index % 2 == 1
                      ? Colors.white
                      : Color.fromRGBO(209, 210, 146, 0.50),
                  border: Border(bottom: BorderSide(color: Colors.black)),
                ),
                children: [
                  _buildDataCell(course['courseName']),
                  _buildDataCell(course['dateAdded']),
                  _buildDataCell(course['currentPrice']),
                  _buildDataCell(course['totalSales']),
                  _buildAddLecturerButton(course['id'], course['courseName']),
                ],
              );
            }),
          ],
        );
      },
    );
  }

  // Helper to build header cells
  Widget _buildHeaderCell(String text) {
    return TableStructure(
      child: Text(
        text,
        style: GoogleFonts.montserrat(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDataCell(String text) {
    return TableStructure(
      child: Text(
        text,
        style: GoogleFonts.montserrat(
          color: Colors.black,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildAddLecturerButton(String courseId, String courseName) {
    return TableStructure(
      child: ElevatedButton(
        onPressed: () async {
          final lecturers = await fetchApprovedLecturers();
          if (lecturers.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No approved lecturers available')),
            );
            return;
          }
          showDialog(
            context: context,
            builder: (context) => _buildLecturerDialog(
              lecturers,
              courseId,
              courseName,
            ),
          );
        },
        style: ElevatedButton.styleFrom(backgroundColor: Mycolors().blue),
        child: Text(
          'Add Lecturer',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Dialog to select an approved lecturer
  Widget _buildLecturerDialog(
      List<Map<String, String>> lecturers, String courseId, String courseName) {
    return AlertDialog(
      title: Text('Assign Lecturer for $courseName'),
      content: DropdownButton<String>(
        isExpanded: true,
        value: selectedLecturer,
        items: lecturers.map((lecturer) {
          return DropdownMenuItem(
            value: lecturer['id'],
            child: Text(lecturer['name']!),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedLecturer = value;
          });
        },
        hint: Text('Select Lecturer'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (selectedLecturer != null) {
              final selectedLecturerDetails = lecturers
                  .firstWhere((lecturer) => lecturer['id'] == selectedLecturer);

              assignLecturerToCourse(
                courseId,
                selectedLecturerDetails['id']!,
                selectedLecturerDetails['name']!,
              );

              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please select a lecturer')),
              );
            }
          },
          child: Text('Assign'),
        ),
      ],
    );
  }
}
