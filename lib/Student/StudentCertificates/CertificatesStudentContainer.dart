import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'package:printing/printing.dart';
import 'package:image_network/image_network.dart';
import 'dart:html' as html;

import 'package:a4m/CommonComponents/displayCardIcons.dart';
import 'package:a4m/Themes/Constants/myColors.dart';
import 'package:a4m/services/certificate_service.dart';

class CertificatesStudentContainer extends StatefulWidget {
  final String imagePath;
  final String courseName;
  final String description;
  final String price;
  final int assessmentCount;
  final int moduleCount;
  final String completionDate;
  final String courseId;
  final String studentId;

  const CertificatesStudentContainer({
    super.key,
    required this.imagePath,
    required this.courseName,
    required this.description,
    required this.price,
    required this.assessmentCount,
    required this.moduleCount,
    required this.completionDate,
    required this.courseId,
    required this.studentId,
  });

  @override
  State<CertificatesStudentContainer> createState() =>
      _CertificatesStudentContainerState();
}

class _CertificatesStudentContainerState
    extends State<CertificatesStudentContainer> {
  bool _isGenerating = false;
  bool _hasGeneratedCertificate = false;

  @override
  void initState() {
    super.initState();
    _checkIfCertificateGenerated();
  }

  Future<void> _checkIfCertificateGenerated() async {
    try {
      DocumentSnapshot certificateDoc = await FirebaseFirestore.instance
          .collection('certificates')
          .doc('${widget.studentId}_${widget.courseId}')
          .get();

      if (mounted) {
        setState(() {
          _hasGeneratedCertificate = certificateDoc.exists;
        });
      }
    } catch (e) {
      print('Error checking for certificate: $e');
    }
  }

  Future<void> _downloadCertificate() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      // Get student details from Firestore
      DocumentSnapshot studentDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.studentId)
          .get();

      if (!studentDoc.exists) {
        _showErrorDialog('Could not find student details');
        return;
      }

      Map<String, dynamic> studentData =
          studentDoc.data() as Map<String, dynamic>;
      String studentName = studentData['name'] ?? 'Student';

      // Generate the certificate
      final Uint8List certificateBytes =
          await CertificateService.generateCertificate(
        studentName: studentName,
        courseName: widget.courseName,
        completionDate: DateTime.parse(widget.completionDate),
        studentId: widget.studentId,
      );

      // Create a blob and download
      final blob = html.Blob([certificateBytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', '${widget.courseName}_Certificate.pdf')
        ..click();

      html.Url.revokeObjectUrl(url);
    } catch (e) {
      print('Error downloading certificate: $e');
      _showErrorDialog('An error occurred while downloading your certificate.');
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  Future<void> _purchaseCertificate() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      // Get student details from Firestore
      DocumentSnapshot studentDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.studentId)
          .get();

      if (!studentDoc.exists) {
        _showErrorDialog('Could not find student details');
        setState(() {
          _isGenerating = false;
        });
        return;
      }

      Map<String, dynamic> studentData =
          studentDoc.data() as Map<String, dynamic>;
      String studentName = studentData['name'] ?? 'Student';
      String studentEmail = studentData['email'] ?? '';

      // Validate email address
      if (studentEmail.isEmpty) {
        _showErrorDialog(
            'Student email address is missing. Please contact support.');
        setState(() {
          _isGenerating = false;
        });
        return;
      }

      // Format date nicely for the certificate
      DateTime completionDate = DateTime.parse(widget.completionDate);
      String formattedDate = DateFormat('MMMM dd, yyyy').format(completionDate);

      // Show certificate preview option
      bool shouldProceed = await _showCertificatePreviewDialog(
        studentName: studentName,
        courseName: widget.courseName,
        completionDate: formattedDate,
      );

      if (!shouldProceed) {
        setState(() {
          _isGenerating = false;
        });
        return;
      }

      // Send confirmation email
      bool emailSent = await _sendConfirmationEmail(
        studentName: studentName,
        studentEmail: studentEmail,
        courseName: widget.courseName,
      );

      if (emailSent) {
        // Record the certificate in Firestore
        await FirebaseFirestore.instance
            .collection('certificates')
            .doc('${widget.studentId}_${widget.courseId}')
            .set({
          'studentId': widget.studentId,
          'studentName': studentName,
          'courseId': widget.courseId,
          'courseName': widget.courseName,
          'purchaseDate': FieldValue.serverTimestamp(),
          'completionDate': widget.completionDate,
          'price': widget.price,
        });

        // Show success dialog
        if (mounted) {
          _showSuccessDialog(studentEmail);
          setState(() {
            _hasGeneratedCertificate = true;
          });
        }
      } else {
        _showErrorDialog(
            'Failed to send confirmation email. Please try again later.');
      }
    } catch (e) {
      print('Error generating certificate: $e');
      _showErrorDialog('An error occurred while processing your certificate.');
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  Future<bool> _showCertificatePreviewDialog({
    required String studentName,
    required String courseName,
    required String completionDate,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Column(
              children: [
                Icon(
                  Icons.verified_outlined,
                  color: Mycolors().navyBlue,
                  size: 40,
                ),
                SizedBox(height: 10),
                Text(
                  'Certificate Details',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    color: Mycolors().navyBlue,
                  ),
                ),
              ],
            ),
            content: Container(
              width: 400,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _detailRow('Student', studentName),
                        const SizedBox(height: 12),
                        _detailRow('Course', courseName),
                        const SizedBox(height: 12),
                        _detailRow('Completion Date', completionDate),
                        const SizedBox(height: 12),
                        _detailRow('Price', widget.price),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _showFullScreenPreview(
                            studentName: studentName,
                            courseName: courseName,
                            completionDate: completionDate,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Mycolors().navyBlue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Preview Certificate',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Mycolors().green,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Purchase Certificate',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label:',
          style: GoogleFonts.montserrat(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            color: Mycolors().navyBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Future<void> _showFullScreenPreview({
    required String studentName,
    required String courseName,
    required String completionDate,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Mycolors().navyBlue,
            title: Text(
              'Certificate Preview',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Stack(
            children: [
              FutureBuilder<Uint8List>(
                future: CertificateService.generateCertificate(
                  studentName: studentName,
                  courseName: courseName,
                  completionDate:
                      DateFormat('MMMM dd, yyyy').parse(completionDate),
                  studentId: widget.studentId,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Mycolors().green,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Generating Certificate Preview...',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              size: 48, color: Colors.red),
                          SizedBox(height: 16),
                          Text(
                            'Error generating preview',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            snapshot.error.toString(),
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
                  if (!snapshot.hasData) {
                    return Center(child: Text('No preview available'));
                  }
                  return PdfPreview(
                    build: (format) => snapshot.data!,
                    maxPageWidth: 800,
                    canChangeOrientation: false,
                    canDebug: false,
                    canChangePageFormat: false,
                    allowPrinting: false,
                    allowSharing: false,
                    pdfFileName: 'certificate_preview.pdf',
                    scrollViewDecoration: BoxDecoration(
                      color: Colors.grey[200],
                    ),
                    previewPageMargin: EdgeInsets.all(20),
                    actions: [],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _sendConfirmationEmail({
    required String studentName,
    required String studentEmail,
    required String courseName,
  }) async {
    const String serviceId = "service_ynlurrg";
    const String templateId = "template_5mmpg1s";
    const String userId = "FvTQj4jEVeYqoPTei";

    try {
      final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': userId,
          'template_params': {
            'user_name': studentName,
            'user_email': studentEmail,
            'event_name': 'Certificate Purchase Confirmation - $courseName',
            'message_content': '''
              Congratulations on purchasing your certificate for $courseName!
              
              You can now download your certificate from the certificates section in your account.
              
              Thank you for choosing our platform for your learning journey.
            ''',
            'reply_to': 'noreply@a4m.com',
          },
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error sending confirmation email: $e');
      return false;
    }
  }

  void _showSuccessDialog(String email) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Mycolors().green,
              size: 50,
            ),
            SizedBox(height: 10),
            Text(
              'Certificate Purchase Successful!',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                color: Mycolors().navyBlue,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your certificate purchase has been confirmed.',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'A confirmation email has been sent to:',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 5),
            Text(
              email,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Mycolors().navyBlue,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 15),
            Text(
              'You can now download your certificate using the download button.',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Mycolors().green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Got it!',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(15),
      elevation: 5,
      child: Container(
        height: 340,
        width: 320,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Image
            Stack(
              children: [
                // Course Image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  child: ImageNetwork(
                    image: widget.imagePath,
                    height: 180,
                    width: 320,
                    fitAndroidIos: BoxFit.cover,
                    fitWeb: BoxFitWeb.cover,
                  ),
                ),
                // Green Gradient Overlay
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Mycolors().green,
                            const Color.fromARGB(0, 255, 255, 255),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                  ),
                ),
                // Price Tag
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
                      widget.price,
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
            // Course Name
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.courseName,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            // Completion Date
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 5),
              child: Text(
                'Completed on: ${widget.completionDate}',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Mycolors().navyBlue,
                ),
              ),
            ),
            // Description
            Padding(
              padding:
                  const EdgeInsets.only(left: 8, right: 5, bottom: 5, top: 5),
              child: Text(
                widget.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Certificate Actions
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Column(
                children: [
                  if (!_hasGeneratedCertificate)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isGenerating ? null : _purchaseCertificate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Mycolors().green,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isGenerating
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Purchase Certificate',
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed:
                                _isGenerating ? null : _downloadCertificate,
                            icon: Icon(Icons.download),
                            label: Text(
                              _isGenerating
                                  ? 'Generating...'
                                  : 'Download Certificate',
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Mycolors().green,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const Spacer(),
            // Divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                width: 300,
                height: 2,
                color: const Color.fromARGB(255, 189, 189, 189),
              ),
            ),
            // Icons Row
            Visibility(
              visible: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: DisplayCardIcons(
                      icon: Icons.format_list_numbered,
                      count: widget.assessmentCount.toString(),
                      tooltipText: 'Assessments',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: DisplayCardIcons(
                      icon: Icons.library_books,
                      count: widget.moduleCount.toString(),
                      tooltipText: 'Modules',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
