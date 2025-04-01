import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart'; // Required for kIsWeb
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../Constants/myColors.dart';

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
        withData: kIsWeb,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading file: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
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
        const SnackBar(
          content: Text('Error: Student name not loaded.'),
          backgroundColor: Colors.red,
        ),
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

      // Remove existing submission of the same file if it exists
      existingFiles.removeWhere(
        (file) => file['assessmentName'] == submission['assessment'],
      );

      // Add new submission with current timestamp
      existingFiles.add({
        'assessmentName': submission['assessment'],
        'fileUrl': downloadUrl,
        'submittedAt': Timestamp.now(),
        'studentName': studentName,
      });

      await submissionRef.set({
        'submittedAssessments': existingFiles,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully submitted ${submission['assessment']}'),
          backgroundColor: Mycolors().green,
        ),
      );

      // Refresh the submissions list
      await fetchStudentSubmissions();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting assessment: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (submissions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No assessments available',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: submissions.length,
      itemBuilder: (context, index) {
        final submission = submissions[index];
        final isUploadingThis =
            isUploading && uploadingFile == submission['assessment'];

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap:
                  isUploadingThis ? null : () => pickAndUploadFile(submission),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: submission['status'] == 'Submitted'
                            ? Mycolors().green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.description_outlined,
                        color: submission['status'] == 'Submitted'
                            ? Mycolors().green
                            : Colors.orange,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            submission['assessment'],
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            submission['type'],
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: submission['status'] == 'Submitted'
                            ? Mycolors().green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isUploadingThis)
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  submission['status'] == 'Submitted'
                                      ? Mycolors().green
                                      : Colors.orange,
                                ),
                              ),
                            )
                          else
                            Icon(
                              submission['status'] == 'Submitted'
                                  ? Icons.check_circle_outline
                                  : Icons.pending_outlined,
                              size: 16,
                              color: submission['status'] == 'Submitted'
                                  ? Mycolors().green
                                  : Colors.orange,
                            ),
                          const SizedBox(width: 4),
                          Text(
                            submission['status'],
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: submission['status'] == 'Submitted'
                                  ? Mycolors().green
                                  : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
