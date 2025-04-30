import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:a4m/Themes/Constants/myColors.dart';

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
          SnackBar(
            content: Text('Certificate status updated successfully'),
            backgroundColor: Mycolors().green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        // Refresh the table
        fetchPurchasedCertificates();
      }
    } catch (e) {
      print('Error updating certificate status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating certificate status'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
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
        style: GoogleFonts.poppins(
          color: Colors.grey[800],
          fontWeight: FontWeight.w500,
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
          style: GoogleFonts.poppins(
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        );
      }
    } else {
      return Text(
        'Invalid date',
        style: GoogleFonts.poppins(
          color: Colors.grey[800],
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      );
    }

    return Text(
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
      style: GoogleFonts.poppins(
        color: Colors.grey[800],
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
    );
  }

  String formatDateString(dynamic timestamp) {
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

    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void showResultsSheet(Map<String, dynamic> cert) async {
    final submissions =
        await fetchModuleSubmissions(cert['courseId'], cert['studentId']);

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 800,
          height: 600,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Mycolors().green.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.school,
                      color: Mycolors().green,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Results Sheet',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      splashRadius: 24,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),

              // Student Info
              Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(
                              Icons.person,
                              'Student',
                              cert['studentName'],
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              Icons.book,
                              'Course',
                              cert['courseName'],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 50,
                        width: 1,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(
                              Icons.calendar_today,
                              'Completion Date',
                              formatDateString(cert['completionDate']),
                            ),
                            const SizedBox(height: 12),
                            _buildStatusBadge(cert['status']),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Results Table
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assessment Results',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: submissions.isEmpty
                            ? Center(
                                child: Text(
                                  'No assessment results found',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[200]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: SingleChildScrollView(
                                    child: DataTable(
                                      headingRowColor:
                                          MaterialStateProperty.all(
                                        Mycolors().green.withOpacity(0.1),
                                      ),
                                      dataRowMaxHeight: 70,
                                      dataRowMinHeight: 60,
                                      columns: [
                                        _buildDataColumn('Module'),
                                        _buildDataColumn('Assessment'),
                                        _buildDataColumn('Mark'),
                                        _buildDataColumn('Comments'),
                                        _buildDataColumn('Date'),
                                      ],
                                      rows: submissions.map((submission) {
                                        return DataRow(
                                          cells: [
                                            _buildDataCell(
                                                submission['moduleName']),
                                            _buildDataCell(
                                                submission['assessmentName']
                                                    .toString()
                                                    .split('/')
                                                    .last),
                                            _buildDataCell(
                                              '${submission['mark']}%',
                                              align: TextAlign.center,
                                              color: _getMarkColor(
                                                  submission['mark']),
                                            ),
                                            _buildDataCell(
                                                submission['comment']),
                                            DataCell(formatDateTimeCell(
                                                submission['gradedAt'])),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),

              // Summary Section
              Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Mycolors().green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Overall Average: ${_calculateAverage(submissions)}%',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Mycolors().green,
                          ),
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Implement PDF export
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('Results report'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Mycolors().green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String statusText;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'approved':
        bgColor = Colors.green[50]!;
        textColor = Colors.green[700]!;
        statusText = 'Approved';
        icon = Icons.check_circle;
        break;
      case 'rejected':
        bgColor = Colors.red[50]!;
        textColor = Colors.red[700]!;
        statusText = 'Rejected';
        icon = Icons.cancel;
        break;
      case 'pending':
      default:
        bgColor = Colors.orange[50]!;
        textColor = Colors.orange[700]!;
        statusText = 'Pending';
        icon = Icons.access_time;
        break;
    }

    return Row(
      children: [
        Icon(
          Icons.shield,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Certificate Status',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 14,
                    color: textColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    statusText,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  DataColumn _buildDataColumn(String label) {
    return DataColumn(
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Mycolors().green,
          ),
        ),
      ),
    );
  }

  DataCell _buildDataCell(String text,
      {TextAlign align = TextAlign.left, Color? color}) {
    return DataCell(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          text,
          textAlign: align,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: color ?? Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Color _getMarkColor(dynamic mark) {
    int markValue = 0;

    if (mark is int) {
      markValue = mark;
    } else if (mark is double) {
      markValue = mark.toInt();
    } else if (mark is String) {
      markValue = int.tryParse(mark) ?? 0;
    }

    if (markValue >= 75) return Colors.green[700]!;
    if (markValue >= 50) return Colors.blue[700]!;
    return Colors.red[700]!;
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
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Mycolors().green),
        ),
      );
    }

    if (purchasedCertificates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.card_membership,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No certificates found',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No students have purchased certificates yet',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2), // Course Name
        1: FlexColumnWidth(1.5), // Student Name
        2: FlexColumnWidth(1.2), // Completion Date
        3: FlexColumnWidth(1.5), // Purchase Date
        4: FlexColumnWidth(0.8), // Price
        5: FlexColumnWidth(1.5), // Results Sheet
      },
      border: TableBorder(
        horizontalInside: BorderSide(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      children: [
        // Header Row
        TableRow(
          decoration: BoxDecoration(
            color: Color(0xFFF7FAF0),
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          children: [
            _buildHeaderCell('Course Name'),
            _buildHeaderCell('Student Name'),
            _buildHeaderCell('Completion Date'),
            _buildHeaderCell('Purchase Date'),
            _buildHeaderCell('Price'),
            _buildHeaderCell('Results Sheet'),
          ],
        ),
        ...purchasedCertificates.map((cert) {
          return TableRow(
            children: [
              _buildTableCell(cert['courseName']),
              _buildTableCell(cert['studentName']),
              _buildTableCell(formatDateString(cert['completionDate'])),
              _buildTableCell(cert['purchaseDate']),
              _buildTableCell(cert['price']),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                child: _buildViewButton(() => showResultsSheet(cert)),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Mycolors().green,
        ),
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildViewButton(VoidCallback onPressed) {
    return Container(
      width: 120,
      height: 40,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(Icons.visibility, size: 16),
        label: Text('View'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Mycolors().green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }
}
