import 'package:a4m/CommonComponents/buttons/slimButtons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:a4m/TableWidgets/tableStructure.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ApproveNewContentTable extends StatefulWidget {
  final Function(int, [Map<String, dynamic>?]) changePage;
  final String status;

  const ApproveNewContentTable({
    super.key,
    required this.changePage,
    required this.status,
  });

  @override
  State<ApproveNewContentTable> createState() => _ApproveNewContentTableState();
}

class _ApproveNewContentTableState extends State<ApproveNewContentTable> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('courses')
          .where('status', isEqualTo: widget.status)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading data'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No Course available'));
        }

        final List<DocumentSnapshot> courses = snapshot.data!.docs;

        return Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                color: Mycolors().green,
                border: Border(
                  bottom: BorderSide(color: Colors.black),
                ),
              ),
              children: [
                TableCell(
                  child: TableStructure(
                    child: Text(
                      'Course/Module Name',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                TableCell(
                  child: TableStructure(
                    child: Text(
                      'Date',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                TableCell(
                  child: TableStructure(
                    child: Text(
                      'Review',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                TableCell(
                  child: TableStructure(
                    child: Text(
                      'Approve',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ...courses.map((course) {
              final courseName = course['courseName'] ?? 'Unknown';
              final createdAt = course['createdAt'] != null
                  ? DateFormat('yyyy-MM-dd')
                      .format((course['createdAt'] as Timestamp).toDate())
                  : 'Unknown Date';

              return TableRow(
                decoration: BoxDecoration(
                  color: courses.indexOf(course) % 2 == 1
                      ? Colors.white
                      : Color.fromRGBO(209, 210, 146, 0.50),
                  border: Border(
                    bottom: BorderSide(width: 1, color: Colors.black),
                  ),
                ),
                children: [
                  TableCell(
                    child: TableStructure(
                      child: Text(
                        courseName,
                        style: GoogleFonts.montserrat(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: TableStructure(
                      child: Text(
                        createdAt,
                        style: GoogleFonts.montserrat(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: TableStructure(
                      child: SizedBox(
                        width: 80,
                        child: SlimButtons(
                          buttonText: 'View',
                          buttonColor: Mycolors().peach,
                          onPressed: () {
                            print('Navigating with courseId: ${course.id}');
                            widget.changePage(9, {'courseId': course.id});
                          },
                          customWidth: 100,
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: TableStructure(
                      child: Container(
                        constraints: BoxConstraints(
                          minWidth: 350,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.status == 'pending_approval')
                              SizedBox(
                                width: 100,
                                child: SlimButtons(
                                  buttonText: 'Approve',
                                  buttonColor: Mycolors().blue,
                                  onPressed: () {
                                    _approveCourse(course.id);
                                  },
                                  customWidth: 100,
                                ),
                              ),
                            if (widget.status == 'pending_approval')
                              const SizedBox(width: 8),
                            if (widget.status == 'pending_approval')
                              SizedBox(
                                width: 100,
                                child: SlimButtons(
                                  buttonText: 'Decline',
                                  buttonColor: Mycolors().red,
                                  onPressed: () {
                                    _declineCourse(course.id);
                                  },
                                  customWidth: 100,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Future<void> _approveCourse(String courseId) async {
    try {
      await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .update({'status': 'approved'});
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Course approved successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to approve course: $e')));
    }
  }

  Future<void> _declineCourse(String courseId) async {
    try {
      await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .update({'status': 'declined'});
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Course declined successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to decline course: $e')));
    }
  }
}
