import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import 'package:printing/printing.dart' show PdfGoogleFonts;

class CertificateService {
  // Check if a student is eligible for a certificate for a specific course
  Future<bool> isEligibleForCertificate(
      String studentId, String courseId) async {
    try {
      QuerySnapshot moduleSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('modules')
          .get();

      if (moduleSnapshot.docs.isEmpty) {
        return false;
      }

      for (var module in moduleSnapshot.docs) {
        String moduleId = module.id;

        DocumentSnapshot submissionDoc = await FirebaseFirestore.instance
            .collection('courses')
            .doc(courseId)
            .collection('modules')
            .doc(moduleId)
            .collection('submissions')
            .doc(studentId)
            .get();

        if (!submissionDoc.exists) {
          return false;
        }

        List<dynamic> submittedAssessments =
            submissionDoc['submittedAssessments'] ?? [];

        if (submittedAssessments.any((assessment) =>
            !assessment.containsKey('mark') ||
            assessment['mark'] == null ||
            assessment['mark'].toString().isEmpty)) {
          return false;
        }
      }

      return true;
    } catch (e) {
      print('Error checking certificate eligibility: $e');
      return false;
    }
  }

  // Generate a certificate PDF for preview or download
  static Future<Uint8List> generateCertificate({
    required String studentName,
    required String courseName,
    required DateTime completionDate,
    required String studentId,
  }) async {
    final pdf = pw.Document();

    try {
      // Load the template image with the correct path
      final ByteData image =
          await rootBundle.load('images/certificates/certificate.png');
      print('Loading template from: images/certificates/certificate.png');
      final Uint8List imageBytes = image.buffer.asUint8List();
      print('Template loaded successfully! Size: ${imageBytes.length} bytes');

      // Load the Roboto font
      final font = await PdfGoogleFonts.robotoBold();
      final regularFont = await PdfGoogleFonts.robotoRegular();

      // Get user's actual ID from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(studentId)
          .get();

      String userId = userDoc['idNumber'] ?? 'N/A';

      // Define page format with specific dimensions
      final pageFormat = PdfPageFormat(
        21.0 * PdfPageFormat.cm, // A4 width
        29.7 * PdfPageFormat.cm, // A4 height
        marginAll: 0.0,
      );

      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat,
          build: (context) {
            return pw.Container(
              width: pageFormat.width,
              height: pageFormat.height,
              child: pw.Stack(
                children: [
                  // Background image
                  pw.Positioned.fill(
                    child: pw.Image(
                      pw.MemoryImage(imageBytes),
                      fit: pw.BoxFit.fill,
                    ),
                  ),
                  // Student Name
                  pw.Positioned(
                    top: pageFormat.height * 0.4, // 40% from top
                    left: 0,
                    right: 0,
                    child: pw.Column(
                      children: [
                        pw.Text(
                          studentName,
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 30,
                            color: PdfColors.black,
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          'ID: $userId',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            font: regularFont,
                            fontSize: 16,
                            color: PdfColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Course Name
                  pw.Positioned(
                    top: pageFormat.height * 0.5, // 50% from top
                    left: 0,
                    right: 0,
                    child: pw.Text(
                      courseName,
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 25,
                        color: PdfColors.black,
                      ),
                    ),
                  ),
                  // Date field (aligned with the line)
                  pw.Positioned(
                    bottom: pageFormat.height *
                        0.091, // Moved lower by adjusting bottom value
                    right: pageFormat.width *
                        0.15, // Align with the line in template
                    child: pw.Text(
                      DateFormat('MMMM dd, yyyy').format(completionDate),
                      style: pw.TextStyle(
                        font: regularFont,
                        fontSize: 12,
                        color: PdfColors.black,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      return await pdf.save();
    } catch (e) {
      print('Error generating certificate: $e');
      rethrow;
    }
  }

  // Get completion date for a course
  Future<String?> getCompletionDate(String studentId, String courseId) async {
    try {
      QuerySnapshot moduleSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('modules')
          .get();

      DateTime? latestSubmission;

      for (var module in moduleSnapshot.docs) {
        DocumentSnapshot submissionDoc = await FirebaseFirestore.instance
            .collection('courses')
            .doc(courseId)
            .collection('modules')
            .doc(module.id)
            .collection('submissions')
            .doc(studentId)
            .get();

        if (submissionDoc.exists) {
          Timestamp submitted = submissionDoc['submitted'] ?? Timestamp.now();
          DateTime submissionDate = submitted.toDate();

          if (latestSubmission == null ||
              submissionDate.isAfter(latestSubmission)) {
            latestSubmission = submissionDate;
          }
        }
      }

      if (latestSubmission != null) {
        return DateFormat('dd MMMM yyyy').format(latestSubmission);
      }
      return null;
    } catch (e) {
      print('Error getting completion date: $e');
      return null;
    }
  }

  // Store certificate purchase info in Firestore
  Future<void> recordCertificatePurchase({
    required String studentId,
    required String studentName,
    required String courseId,
    required String courseName,
    required String completionDate,
    required String price,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('certificates')
          .doc('${studentId}_$courseId')
          .set({
        'studentId': studentId,
        'studentName': studentName,
        'courseId': courseId,
        'courseName': courseName,
        'purchaseDate': FieldValue.serverTimestamp(),
        'completionDate': completionDate,
        'price': price,
      });
      print('Certificate purchase recorded successfully');
    } catch (e) {
      print('Error recording certificate purchase: $e');
      rethrow;
    }
  }
}
