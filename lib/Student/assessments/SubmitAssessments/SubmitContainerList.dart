import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart'; // Required for kIsWeb
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SubmitContainerList extends StatefulWidget {
  final String courseId;
  final String moduleId;
  final String studentId;

  const SubmitContainerList({
    super.key,
    required this.courseId,
    required this.moduleId,
    required this.studentId,
  });

  @override
  State<SubmitContainerList> createState() => _SubmitContainerListState();
}

class _SubmitContainerListState extends State<SubmitContainerList> {
  List<Map<String, dynamic>> submissions = [];
  String? studentName;
  bool isLoading = true;
  bool isUploading = false;
  String? uploadingFile;

  @override
  void initState() {
    super.initState();
    fetchStudentName();
    fetchStudentSubmissions();
  }

  Future<void> fetchStudentName() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.studentId)
          .get();

      if (userDoc.exists) {
        setState(() {
          studentName = userDoc['name'] ?? 'Unknown Student';
        });
      }
    } catch (e) {
      debugPrint('Error fetching student name: $e');
    }
  }

  Future<void> fetchStudentSubmissions() async {
    try {
      final moduleRef = FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('modules')
          .doc(widget.moduleId);

      final submissionRef =
          moduleRef.collection('submissions').doc(widget.studentId);

      final moduleDoc = await moduleRef.get();
      final submissionDoc =
          await submissionRef.get(); // Check student submission

      if (!moduleDoc.exists) {
        throw Exception("Module document does not exist!");
      }

      final moduleData = moduleDoc.data();
      List<dynamic> submittedFiles = submissionDoc.exists
          ? (submissionDoc.data()?['submittedAssessments'] ?? [])
          : [];

      // Extract submitted assessment names
      Set<String> submittedAssessments = submittedFiles
          .map<String>((file) => file['assessmentName'].toString())
          .toSet();

      if (moduleData != null) {
        setState(() {
          submissions = [
            if (moduleData['assessmentsPdfUrl'] != null)
              {
                'assessment': getFileName(moduleData['assessmentsPdfUrl']),
                'type': 'Assessment PDF',
                'status': submittedAssessments
                        .contains(getFileName(moduleData['assessmentsPdfUrl']))
                    ? 'Submitted'
                    : 'Pending',
              },
            if (moduleData['testSheetPdfUrl'] != null)
              {
                'assessment': getFileName(moduleData['testSheetPdfUrl']),
                'type': 'Test Sheet PDF',
                'status': submittedAssessments
                        .contains(getFileName(moduleData['testSheetPdfUrl']))
                    ? 'Submitted'
                    : 'Pending',
              },
          ];
        });
      }
    } catch (e) {
      debugPrint('Error fetching student submissions: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String getFileName(String url) {
    try {
      Uri uri = Uri.parse(url);
      return uri.pathSegments.last.split('?').first;
    } catch (e) {
      debugPrint('Error extracting filename: $e');
      return 'Unknown File.pdf';
    }
  }

  Future<void> pickAndUploadFile(Map<String, dynamic> submission) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: kIsWeb, // Get bytes on web
      );

      if (result != null) {
        setState(() {
          isUploading = true;
          uploadingFile = submission['assessment'];
        });

        String fileName =
            '${widget.studentId}_${submission['assessment']}'; // Unique file name
        Reference storageRef = FirebaseStorage.instance.ref().child(
            'submissions/${widget.courseId}/${widget.moduleId}/$fileName');

        TaskSnapshot snapshot;
        if (kIsWeb) {
          // Handle Web Upload (Use Bytes)
          Uint8List? fileBytes = result.files.single.bytes;
          if (fileBytes == null) throw Exception("File bytes are null!");

          snapshot = await storageRef.putData(fileBytes);
        } else {
          // Handle Mobile Upload (Use File)
          File file = File(result.files.single.path!);
          snapshot = await storageRef.putFile(file);
        }

        String downloadUrl = await snapshot.ref.getDownloadURL();
        await submitAssessment(submission, downloadUrl);
      } else {
        debugPrint('No file selected.');
      }
    } catch (e) {
      debugPrint('Error picking or uploading file: $e');
    } finally {
      setState(() {
        isUploading = false;
        uploadingFile = null;
      });
    }
  }

  Future<void> submitAssessment(
      Map<String, dynamic> submission, String downloadUrl) async {
    if (studentName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Student name not loaded.')),
      );
      return;
    }

    try {
      final moduleRef = FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('modules')
          .doc(widget.moduleId);

      final submissionRef =
          moduleRef.collection('submissions').doc(widget.studentId);

      DocumentSnapshot doc = await submissionRef.get();
      List<dynamic> existingFiles = [];

      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('submittedAssessments')) {
          existingFiles = List.from(data['submittedAssessments']);
        }
      }

      Map<String, dynamic> newSubmission = {
        'fileUrl': downloadUrl,
        'assessmentName': submission['assessment'],
        'submittedFile': submission['type'],
        'submittedDate': Timestamp.now(),
        'documentRef': submissionRef, // Store Document Reference
      };

      existingFiles.add(newSubmission);

      await submissionRef.set({
        'studentId': widget.studentId,
        'studentName': studentName,
        'submitted': Timestamp.now(),
        'submittedAssessments': existingFiles,
      }, SetOptions(merge: true));

      setState(() {
        // Change "Pending" to "Submitted"
        submissions = submissions.map((s) {
          if (s['assessment'] == submission['assessment']) {
            return {...s, 'status': 'Submitted'}; // Update status
          }
          return s;
        }).toList();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('${submission['assessment']} submitted successfully')),
      );
    } catch (e) {
      debugPrint('Error submitting assessment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Module 2: Production Technology',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: submissions.length,
                    itemBuilder: (context, index) {
                      final submission = submissions[index];
                      return _buildSubmissionCard(submission);
                    },
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildSubmissionCard(Map<String, dynamic> submission) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                submission['assessment'],
                style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black),
              ),
            ),
            Text(
              submission.containsKey('status') &&
                      submission['status'] == 'Submitted'
                  ? 'Submitted'
                  : 'Pending',
              style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: submission.containsKey('status') &&
                          submission['status'] == 'Submitted'
                      ? Colors.green
                      : Colors.orange),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Container(
                width: 5,
                height: 40,
                color: Colors.grey[400],
              ),
            ),
            isUploading && uploadingFile == submission['assessment']
                ? const CircularProgressIndicator()
                : Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: IconButton(
                      onPressed: () => pickAndUploadFile(submission),
                      icon: const Icon(Icons.upload, color: Colors.white),
                      iconSize: 20,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
