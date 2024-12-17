import 'package:a4m/Admin/CurriculumVitae/ui/cvStatus.dart';
import 'package:a4m/CommonComponents/buttons/ApprovalButton.dart';
import 'package:a4m/CommonComponents/buttons/deleteButton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:a4m/TableWidgets/tableStructure.dart';

class CvTable extends StatefulWidget {
  const CvTable({super.key});

  @override
  State<CvTable> createState() => applicants();
}

class applicants extends State<CvTable> {
  // Fetch aplicants
  Future<List<Map<String, dynamic>>> _fetchPendingCvList() async {
    List<Map<String, dynamic>> pendingCvList = [];

    try {
      // get 'pending' applicants
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('status', isEqualTo: 'pending')
          .get();

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
                          'Remove CV',
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

                              // Update status to 'seen' after clicking download
                              await FirebaseFirestore.instance
                                  .collection('Users')
                                  .doc(course['id'])
                                  .update({'status': 'seen'});
                              setState(
                                  () {}); // Refresh the table after updating status
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
                              ApprovalButton(
                                onPress: () async {
                                  // TO DO: Implement the logic to approve
                                  await FirebaseFirestore.instance
                                      .collection('Users')
                                      .doc(course['id'])
                                      .update({'status': 'approved'});
                                  setState(
                                      () {}); // Refresh the table after approval
                                },
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              DeleteButton(
                                onPress: () async {
                                  // TO DO: Implement the logic to delete
                                  await FirebaseFirestore.instance
                                      .collection('Users')
                                      .doc(course['id'])
                                      .delete();
                                  setState(
                                      () {}); // Refresh the table after deletion
                                },
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
