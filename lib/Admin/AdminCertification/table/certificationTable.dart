import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:a4m/TableWidgets/tableStructure.dart';
import 'package:a4m/CommonComponents/buttons/slimButtons.dart';

class CertificationTable extends StatefulWidget {
  const CertificationTable({super.key});

  @override
  State<CertificationTable> createState() => _CertificationTableState();
}

class _CertificationTableState extends State<CertificationTable> {
  bool isLoading = true;
  List<Map<String, dynamic>> purchasedCertificates = [];

  @override
  void initState() {
    super.initState();
    fetchPurchasedCertificates();
  }

  Future<void> fetchPurchasedCertificates() async {
    try {
      // Get all certificates
      QuerySnapshot certificatesSnapshot =
          await FirebaseFirestore.instance.collection('certificates').get();

      List<Map<String, dynamic>> certificates = [];

      for (var doc in certificatesSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        certificates.add({
          'courseId': data['courseId'] ?? '',
          'courseName': data['courseName'] ?? 'Unnamed Course',
          'studentName': data['studentName'] ?? 'Unknown Student',
          'studentId': data['studentId'] ?? '',
          'completionDate': data['completionDate'] ?? 'Unknown Date',
          'purchaseDate': data['purchaseDate'] != null
              ? (data['purchaseDate'] as Timestamp)
                  .toDate()
                  .toString()
                  .split('.')[0]
              : 'Unknown Date',
          'price': data['price'] ?? 'R 299',
          'status': data['status'] ?? 'pending',
        });
      }

      setState(() {
        purchasedCertificates = certificates;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching purchased certificates: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateCertificateStatus(
      String courseId, String studentId, String newStatus) async {
    try {
      // Find the certificate document with matching courseId and studentId
      QuerySnapshot certQuery = await FirebaseFirestore.instance
          .collection('certificates')
          .where('courseId', isEqualTo: courseId)
          .where('studentId', isEqualTo: studentId)
          .get();

      if (certQuery.docs.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('certificates')
            .doc(certQuery.docs.first.id)
            .update({'status': newStatus});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Certificate status updated successfully')),
        );

        // Refresh the table
        fetchPurchasedCertificates();
      }
    } catch (e) {
      print('Error updating certificate status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating certificate status')),
      );
    }
  }

  Future<List<Map<String, dynamic>>> fetchModuleSubmissions(
      String courseId, String studentId) async {
    try {
      final moduleSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('modules')
          .get();

      List<Map<String, dynamic>> allSubmissions = [];

      for (var moduleDoc in moduleSnapshot.docs) {
        final submissionDoc = await FirebaseFirestore.instance
            .collection('courses')
            .doc(courseId)
            .collection('modules')
            .doc(moduleDoc.id)
            .collection('submissions')
            .doc(studentId)
            .get();

        if (submissionDoc.exists && submissionDoc.data() != null) {
          final submissions =
              submissionDoc.data()!['submittedAssessments'] ?? [];

          for (var submission in submissions) {
            allSubmissions.add({
              'moduleName': moduleDoc.data()['moduleName'] ?? 'Unknown Module',
              'assessmentName': submission['assessmentName'] ?? '',
              'mark': submission['mark'] ?? 0,
              'comment': submission['comment'] ?? '',
              'submittedAt': submission['submittedAt'],
              'gradedAt': submission['gradedAt'],
              'markedPdfUrl': submission['markedPdfUrl'],
            });
          }
        }
      }

      return allSubmissions;
    } catch (e) {
      print('Error fetching module submissions: $e');
      return [];
    }
  }

  Widget formatDateTimeCell(dynamic timestamp) {
    if (timestamp == null)
      return Text(
        'Not available',
        style: GoogleFonts.montserrat(
          color: Colors.black,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      );

    DateTime date;
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else if (timestamp is String) {
      try {
        date = DateTime.parse(timestamp);
      } catch (e) {
        return Text(
          timestamp,
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        );
      }
    } else {
      return Text(
        'Invalid date',
        style: GoogleFonts.montserrat(
          color: Colors.black,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${date.hour}:${date.minute.toString().padLeft(2, '0')}',
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        Text(
          '${date.day}/${date.month}/${date.year}',
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  String formatDateTimeString(dynamic timestamp) {
    if (timestamp == null) return 'Not available';

    DateTime date;
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else if (timestamp is String) {
      try {
        date = DateTime.parse(timestamp);
      } catch (e) {
        return timestamp;
      }
    } else {
      return 'Invalid date';
    }

    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}\n${date.day}/${date.month}/${date.year}';
  }

  void showResultsSheet(Map<String, dynamic> cert) async {
    final submissions =
        await fetchModuleSubmissions(cert['courseId'], cert['studentId']);

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Results Sheet',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Container(
          width: 800,
          height: 600,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Student Info Header
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Student: ${cert['studentName']}',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500)),
                        Text('Course: ${cert['courseName']}',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                            'Completion: ${formatDateTimeString(cert['completionDate'])}',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500)),
                        Text('Certificate Status: ${cert['status']}',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Results Table
              Expanded(
                child: SingleChildScrollView(
                  child: Table(
                    border: TableBorder.all(color: Colors.grey[300]!),
                    columnWidths: {
                      0: FlexColumnWidth(2), // Module Name
                      1: FlexColumnWidth(2), // Assessment Type
                      2: FlexColumnWidth(1), // Mark
                      3: FlexColumnWidth(3), // Comments
                      4: FlexColumnWidth(1.5), // Submission Date
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: Mycolors().green),
                        children: [
                          _buildHeaderCell('Module'),
                          _buildHeaderCell('Assessment'),
                          _buildHeaderCell('Mark'),
                          _buildHeaderCell('Comments'),
                          _buildHeaderCell('Date'),
                        ],
                      ),
                      ...submissions
                          .map((submission) => TableRow(
                                children: [
                                  _buildCell(submission['moduleName']),
                                  _buildCell(submission['assessmentName']
                                      .toString()
                                      .split('/')
                                      .last),
                                  _buildCell('${submission['mark']}%'),
                                  _buildCell(submission['comment']),
                                  TableStructure(
                                    child: formatDateTimeCell(
                                        submission['gradedAt']),
                                  ),
                                ],
                              ))
                          .toList(),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Summary Section
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Overall Average: ${_calculateAverage(submissions)}%',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Implement PDF export of results sheet
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Mycolors().green,
                      ),
                      child: Text('Export Results',
                          style: GoogleFonts.poppins(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  String _calculateAverage(List<Map<String, dynamic>> submissions) {
    if (submissions.isEmpty) return '0';

    double total = 0;
    int count = 0;

    for (var submission in submissions) {
      if (submission['mark'] != null) {
        total += submission['mark'] as num;
        count++;
      }
    }

    if (count == 0) return '0';
    return (total / count).toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (purchasedCertificates.isEmpty) {
      return Center(child: Text('No certificates have been purchased yet.'));
    }

    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: Mycolors().green,
            border: Border(bottom: BorderSide(color: Colors.black)),
          ),
          children: [
            _buildHeaderCell('Course Name'),
            _buildHeaderCell('Student Name'),
            _buildHeaderCell('Completion Date'),
            _buildHeaderCell('Purchase Date'),
            _buildHeaderCell('Price'),
            _buildHeaderCell('Result Sheet'),
          ],
        ),
        ...purchasedCertificates.map((cert) {
          return TableRow(
            decoration: BoxDecoration(
              color: purchasedCertificates.indexOf(cert) % 2 == 0
                  ? Colors.white
                  : Color.fromRGBO(209, 210, 146, 0.50),
              border: Border(bottom: BorderSide(color: Colors.black)),
            ),
            children: [
              _buildCell(cert['courseName']),
              _buildCell(cert['studentName']),
              _buildCell(cert['completionDate']),
              _buildCell(cert['purchaseDate']),
              _buildCell(cert['price']),
              TableStructure(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SlimButtons(
                      buttonText: 'View',
                      buttonColor: Mycolors().green,
                      onPressed: () => showResultsSheet(cert),
                      customWidth: 120,
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

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

  Widget _buildCell(String text) {
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
}
