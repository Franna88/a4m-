import 'package:a4m/Admin/CurriculumVitae/ui/cvStatus.dart';
import 'package:a4m/CommonComponents/buttons/ApprovalButton.dart';
import 'package:a4m/CommonComponents/buttons/deleteButton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:a4m/TableWidgets/tableStructure.dart';
import 'package:url_launcher/url_launcher.dart';

class CvTable extends StatefulWidget {
  final String? userType;

  const CvTable({
    super.key,
    this.userType,
  });

  @override
  State<CvTable> createState() => applicants();
}

class applicants extends State<CvTable> {
  // Fetch aplicants
  Future<List<Map<String, dynamic>>> _fetchPendingCvList() async {
    List<Map<String, dynamic>> pendingCvList = [];

    try {
      // Create base query
      Query query = FirebaseFirestore.instance
          .collection('Users')
          .where('status', isEqualTo: 'pending');

      // Add userType filter if specified
      if (widget.userType != null) {
        query = query.where('userType', isEqualTo: widget.userType);
      }

      // Execute query
      QuerySnapshot snapshot = await query.get();

      for (var doc in snapshot.docs) {
        pendingCvList.add({
          'id': doc.id,
          'name': doc['name'] ?? '',
          'dateAdded': doc['submissionDate'] ?? 'Unknown',
          'type': doc['userType'] ?? 'unknown',
          'cvUrl': doc['cvUrl'],
          'status': doc['status'] ?? 'pending',
        });
      }
    } catch (e) {
      print('Error fetching pending CVs: $e');
    }

    return pendingCvList;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchPendingCvList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading pending CVs.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No CVs pending for approval.'));
          } else {
            final cvList = snapshot.data!;
            // final List<Map<String, String>> cvList = [
            //   {
            //     'name': 'James Harmse',
            //     'dateAdded': '2024-02-01',
            //   },
            //   {
            //     'name': 'Carla Owens',
            //     'dateAdded': '2024-01-20',
            //   },
            //   {
            //     'name': 'Kurt Ames',
            //     'dateAdded': '2024-03-15',
            //   },
            // ];

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
                    TableStructure(
                      child: TableCell(
                        child: Text(
                          'Name',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    TableStructure(
                      child: TableCell(
                        child: Text(
                          'Submission Date',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    TableStructure(
                      child: TableCell(
                        child: Text(
                          'Status',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    TableStructure(
                      child: TableCell(
                        child: Text(
                          'Download CV',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    TableStructure(
                      child: TableCell(
                        child: Text(
                          'approve',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                ...List.generate(cvList.length, (index) {
                  final course = cvList[index];
                  return TableRow(
                    decoration: BoxDecoration(
                      color: index % 2 == 1
                          ? Colors.white
                          : Color.fromRGBO(209, 210, 146, 0.50),
                      border: Border(
                        bottom: BorderSide(width: 1, color: Colors.black),
                      ),
                    ),
                    children: [
                      TableStructure(
                        child: TableCell(
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Icon(
                                  course['type'] == 'contentDev'
                                      ? Icons.developer_board
                                      : Icons.book_outlined,
                                ),
                              ),
                              const SizedBox(
                                  width: 8), // Space between icon and name
                              Text(
                                course['name']!,
                                style: GoogleFonts.montserrat(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      TableStructure(
                        child: TableCell(
                          child: Text(
                            course['dateAdded']!,
                            style: GoogleFonts.montserrat(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      TableStructure(
                        child: TableCell(
                          child: CvStatus(
                            status: course['status'],
                          ),
                        ),
                      ),
                      TableStructure(
                        child: TableCell(
                          child: InkWell(
                            onTap: () async {
                              // download using course['cvUrl']
                              String cvUrl = course['cvUrl'];
                              print('Download CV from: $cvUrl');
                              // Open the CV in a new window/tab
                              if (await canLaunch(cvUrl)) {
                                await launch(cvUrl);
                              }
                            },
                            child: Image.asset('images/downloadIcon.png'),
                          ),
                        ),
                      ),
                      TableStructure(
                        child: TableCell(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Tooltip(
                                message: 'Approve user',
                                child: ApprovalButton(
                                  onPress: () async {
                                    // Update status to 'approved'
                                    await FirebaseFirestore.instance
                                        .collection('Users')
                                        .doc(course['id'])
                                        .update({
                                      'status': 'approved',
                                      'approvedAt': FieldValue.serverTimestamp()
                                    });
                                    setState(
                                        () {}); // Refresh the table after approval
                                  },
                                ),
                              ),
                              SizedBox(width: 10),
                              Tooltip(
                                message: 'Decline user',
                                child: DeleteButton(
                                  onPress: () async {
                                    // Show dialog to get decline reason
                                    final TextEditingController
                                        reasonController =
                                        TextEditingController();

                                    bool? dialogResult = await showDialog<bool>(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(
                                            'Decline CV',
                                            style: GoogleFonts.montserrat(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Please provide a reason for declining this user:',
                                                style: GoogleFonts.montserrat(),
                                              ),
                                              SizedBox(height: 16),
                                              TextField(
                                                controller: reasonController,
                                                decoration: InputDecoration(
                                                  hintText:
                                                      'Enter reason for declining...',
                                                  border: OutlineInputBorder(),
                                                ),
                                                maxLines: 3,
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              child: Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                if (reasonController.text
                                                    .trim()
                                                    .isEmpty) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                        content: Text(
                                                            'Please provide a reason for declining')),
                                                  );
                                                  return;
                                                }
                                                Navigator.of(context).pop(true);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Mycolors().red,
                                              ),
                                              child: Text('Decline'),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (dialogResult == true &&
                                        reasonController.text
                                            .trim()
                                            .isNotEmpty) {
                                      // Update status to 'declined' with reason
                                      await FirebaseFirestore.instance
                                          .collection('Users')
                                          .doc(course['id'])
                                          .update({
                                        'status': 'declined',
                                        'declineReason':
                                            reasonController.text.trim(),
                                        'declinedAt':
                                            FieldValue.serverTimestamp()
                                      });
                                      setState(
                                          () {}); // Refresh the table after declining
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            );
          }
        });
  }
}
